#!/usr/bin/env bash
# bat / bat-extras configuration
# Deployed by the installer only when bat is confirmed present.
# Guard handles the edge case where bat is removed after install.
# command -v bat >/dev/null 2>&1 || return 0

# ============================================================================
# THEME
# ============================================================================

# Active theme — run `bat --list-themes` to browse.
# Override in ~/.bashrc.local; uncomment the DARK/LIGHT pair and set
# BAT_THEME=auto to use terminal-based dark/light auto-detection instead.
export BAT_THEME="${BAT_THEME:-AyuDark}"
# export BAT_THEME="auto"
# export BAT_THEME_DARK="${BAT_THEME_DARK:-TwoDark}"
# export BAT_THEME_LIGHT="${BAT_THEME_LIGHT:-GitHub}"

# ============================================================================
# STYLE AND PAGER
# ============================================================================

# Display components — comma-separated; use +comp/-comp to add/remove from
# a preset rather than rewriting the full list (e.g. "default,-grid,+snip").
# Components: numbers changes header header-filename header-filesize
#             grid rule snip
# Presets:    full  plain  auto  default
export BAT_STYLE="${BAT_STYLE:-numbers,changes,header-filename,grid,snip}"

# Pager command — set to empty string ("") to globally disable paging.
# bat passes -RFKX to less by default; explicit args here override that.
export BAT_PAGER="${BAT_PAGER:-less -RFiKX}"
export MANWIDTH=$(tput cols)

# ============================================================================
# BATMAN — coloured man pages
# ============================================================================

eval "$(batman --export-env)"   # exports MANPAGER and MANROFFOPT

#if command -v batman >/dev/null 2>&1; then
#    eval "$(batman --export-env)"   # exports MANPAGER and MANROFFOPT
#fi


# ============================================================================
# BATPIPE — bat as a preprocessor inside less
# ============================================================================
if command -v batpipe >/dev/null 2>&1; then
    eval "$(batpipe)"
    export BATPIPE="color"          # enable colours when previewing inside less
fi

# ============================================================================
# FZF INTEGRATION
# ============================================================================
if command -v fzf >/dev/null 2>&1; then
    # CTRL+T file picker: preview files with bat
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
fi

# ============================================================================
# CORE ALIASES
# ============================================================================

# cat replacement — decorations auto-off when output is piped (bat detects TTY)
alias cat='bat --paging=auto'

# Plain cat-like output — no decorations, safe for copy-paste or scripting
alias catp='bat --style=plain --paging=auto'

# Full decorations with pager (like coloured less)
alias bless='bat --style=full'

# Line numbers only, no pager — quick reference view
alias bn='bat --style=numbers --paging=auto'

# Reveal non-printable characters: tabs, trailing spaces, newlines
alias bshow='bat --show-all --paging=auto'

# Live file following with syntax highlighting (pipe to this from tail -f)
# Usage: tail -f /var/log/pacman.log | batlog
alias batlog='bat --paging=auto --style=plain -f'

# ============================================================================
# HELP TEXT COLORIZER
# ============================================================================

# Render a command's --help output with bat syntax highlighting.
# Usage: bhelp grep    bhelp git commit    bhelp ffmpeg
help() {
    "$@" --help 2>&1 | bat --plain --language=help
}

# ============================================================================
# BAT-EXTRAS ALIASES (each conditional on its binary being present)
# ============================================================================

# batman — coloured man pages (also wired via MANPAGER above)
# command -v batman   >/dev/null 2>&1 && alias man='batman'

# batdiff — syntax-highlighted diff against git index or between two files
# Set BATDIFF_USE_DELTA=true in ~/.bashrc.local to use delta as the renderer
command -v batdiff  >/dev/null 2>&1 && alias bd='batdiff'

# batgrep — ripgrep results displayed through bat with context highlighting
command -v batgrep  >/dev/null 2>&1 && alias bgrep='batgrep'

# batwatch — re-render a file with bat each time it changes
command -v batwatch >/dev/null 2>&1 && alias bwatch='batwatch'

# prettybat — auto-format a source file then display it with bat
command -v prettybat >/dev/null 2>&1 && alias pbat='prettybat'
