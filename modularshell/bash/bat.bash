#!/usr/bin/env bash
# bat / bat-extras configuration
# Deployed by the installer only when bat is confirmed present.
# Guard handles the edge case where bat is removed after install.
command -v bat >/dev/null 2>&1 || return 0

# ============================================================================
# ENVIRONMENT
# ============================================================================

# Color theme — override in ~/.bashrc.local (bat --list-themes to browse)
export BAT_THEME="${BAT_THEME:-Dracula}"

# Display components — override in ~/.bashrc.local
# Options: full, plain, changes, header, header-filename, header-filesize,
#          grid, rule, numbers, snip  (comma-separated or "full" / "plain")
export BAT_STYLE="${BAT_STYLE:-numbers,changes,header-filename}"

# Always use 24-bit color when the terminal supports it
export BAT_COLOR="${BAT_COLOR:-always}"

# ============================================================================
# BATMAN — man pages rendered through bat
# ============================================================================
if command -v batman >/dev/null 2>&1; then
    eval "$(batman --export-env)"   # sets MANPAGER + MANROFFOPT
fi

# ============================================================================
# BATPIPE — bat as a pager inside less / lesspipe
# ============================================================================
if command -v batpipe >/dev/null 2>&1; then
    eval "$(batpipe)"               # sets LESSOPEN, LESS, BATPIPE
fi

# ============================================================================
# CORE ALIASES
# ============================================================================

# cat replacement — decorations auto-disabled when output is piped
alias cat='bat --pager=never'

# Plain cat-like output with no decorations (safe for copy-paste / scripting)
alias catp='bat --style=plain --pager=never'

# Full decorations + pager (like less, but syntax-highlighted)
alias bless='bat --style=full'

# Quick syntax preview with just line numbers (minimal noise)
alias bn='bat --style=numbers --pager=never'

# ============================================================================
# BAT-EXTRAS ALIASES (conditional on each binary)
# ============================================================================

# batman — coloured man pages
command -v batman >/dev/null 2>&1 && alias man='batman'

# batdiff — syntax-highlighted diff (wraps git diff / diff)
command -v batdiff >/dev/null 2>&1 && alias bd='batdiff'

# batgrep — ripgrep results displayed through bat
command -v batgrep >/dev/null 2>&1 && alias bgrep='batgrep'

# batwatch — watch a file and re-render with bat on each change
command -v batwatch >/dev/null 2>&1 && alias bwatch='batwatch'

# prettybat — auto-format source files then display with bat
command -v prettybat >/dev/null 2>&1 && alias pbat='prettybat'
