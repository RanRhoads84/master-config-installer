#!/usr/bin/env bash
# FZF configuration and functions

command -v fzf >/dev/null 2>&1 || return 0 2>/dev/null || exit 0

# Use bat for preview if available, otherwise fall back to cat
__fzf_preview_cmd() {
    if command -v bat >/dev/null 2>&1; then
        printf '%s' "bat --style=numbers --color=always --line-range=:300 {} 2>/dev/null || cat {}"
    else
        printf '%s' "cat {} 2>/dev/null"
    fi
}

# Open file(s) in editor with fzf
__fzf_editor() {
    if [ -n "$EDITOR" ]; then
        printf '%s' "$EDITOR"
    elif command -v nvim >/dev/null 2>&1; then
        printf '%s' "nvim"
    else
        printf '%s' "vim"
    fi
}

vf() {
    local -a files
    mapfile -t files < <(
        fzf -m \
            --preview "$(__fzf_preview_cmd)" \
            --preview-window='right:60%:wrap'
    )
    ((${#files[@]})) || return 0
    "$(__fzf_editor)" -- "${files[@]}"
}

# Kill process(es) with fzf
# Usage: fkill [signal]   (default: 15, use 9 if you really mean it)
fkill() {
    local sig="${1:-15}"
    local -a pids

    mapfile -t pids < <(
        ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu |
        sed 1d |
        fzf -m --prompt="kill($sig)> " \
            --preview 'echo {} | awk "{print \$1}" | xargs -r ps -fp' \
            --preview-window='down:60%:wrap' |
        awk '{print $1}'
    )

    ((${#pids[@]})) || return 0
    printf '%s\n' "${pids[@]}" | xargs -r kill "-$sig"
}

# FZF default options
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"

# Use fd if available for faster searching
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Source fzf key bindings if available
[ -f "/usr/share/fzf/key-bindings.bash" ] && source "/usr/share/fzf/key-bindings.bash"
[ -f "/usr/share/fzf/completion.bash" ] && source "/usr/share/fzf/completion.bash"
[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"

