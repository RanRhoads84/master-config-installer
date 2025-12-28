#!/usr/bin/env bash
# Prompt configuration

# =========================
# Color definitions
# =========================
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$script_dir/libs/text_mods.bash" ]; then
  source "$script_dir/libs/text_mods.bash"
elif [ -f "$script_dir/../../libs/text_mods.bash" ]; then
  source "$script_dir/../../libs/text_mods.bash"
else
  echo "ERROR: failed to source text_mods.bash" >&2
  exit 2
fi

#RED="\[\e[1;31m\]"            # SSH msg
#GREEN="\[\e[1;32m\]"          # user/host
#YELLOW="\[\e[1;33m\]"         # git branch
#BLUE="\[\e[38;5;24m\]"        # date
#TEAL="\[\e[38;5;30m\]"        # wrappers
#TEAL_DARK="\[\e[38;5;29m\]"   # braces
#ORANGE="\[\e[38;5;208m\]"     # path
#GREEN_PROMPT="\[\e[38;5;34m\]"
#BOLD="\[\e[1m\]"
#UNDERLINE="\[\e[4m\]"
#RESET="\[\e[0m\]"

# =========================
# Git prompt helper
# =========================
parse_git_branch() {
    # Fast path: only run git if we're in/under a repo
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

    # Branch name (or detached HEAD short sha)
    local ref
    ref="$(git symbolic-ref --quiet --short HEAD 2>/dev/null \
        || git rev-parse --short HEAD 2>/dev/null)" || return 0

    # Optional: dirty marker
    local dirty=""
    git diff --quiet --ignore-submodules -- 2>/dev/null || dirty="*"

    printf ' (%s%s)' "$ref" "$dirty"
}

# =========================
# SSH marker
# =========================
if [[ -n "${SSH_CLIENT:-}" ]]; then
    ssh_message="${RED}-ssh${RESET}"
else
    ssh_message=""
fi

# =========================
# Prompt
# NOTE: the backslash before $(...) is REQUIRED so it runs at prompt-time.
# =========================
PS1="${BLUE}[\d](\T)${RESET}${BOLD}${UNDERLINE}>>${RESET}\
${TEAL}(${GREEN}\u${ssh_message}${RESET}${TEAL})\
${TEAL_DARK}{${GREEN}\h${RESET}${TEAL_DARK}}${RESET}\
\n${ORANGE}\w${YELLOW}\$(parse_git_branch)${RESET}\
\n${GREEN_PROMPT}\$ ${RESET}"
