# ~/.config/bash/fzf.bash – load FZF key‑bindings, completion and extra functions

command -v fzf >/dev/null 2>&1 || return 0

# Use bat for preview in vf()
_fzf_preview_cmd() {
  if command -v bat >/dev/null 2>&1; then
    printf '%s' "bat --style=numbers --color=always --line-range=:300 {} 2>/dev/null || cat {}"
  else
    printf '%s' "cat {} 2>/dev/null"
  fi
}

# Choose editor for vf()
_fzf_editor() {
  if [ -n "$EDITOR" ]; then
    printf '%s' "$EDITOR"
  elif command -v nvim >/dev/null; then
    printf '%s' nvim
  else
    printf '%s' vim
  fi
}

# Fuzzy‑open files in $EDITOR
vf() {
  local -a files
  mapfile -t files < <(
    fzf -m --preview "$(_fzf_preview_cmd)" --preview-window='right:60%:wrap'
  )
  ((${#files[@]})) || return 0
  "$(_fzf_editor)" -- "${files[@]}"
}

# Fuzzy‑kill process(es)
fkill() {
  local sig="${1:-15}" pids
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

# Default options and fd integration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Load key bindings and completion:
if fzf --bash > /dev/null 2>&1; then
  # fzf ≥ 0.48.0 provides --bash / --zsh / --fish integration:contentReference[oaicite:1]{index=1}.
  eval "$(fzf --bash)"
else
  # Fall back to legacy scripts for older fzf or unusual installations:contentReference[oaicite:2]{index=2}.
  [ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
  [ -f /usr/share/fzf/completion.bash ]   && source /usr/share/fzf/completion.bash
  [ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"
fi
