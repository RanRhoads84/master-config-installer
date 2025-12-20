#!/usr/bin/env bash
# Modular .bashrc configuration

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ============================================================================
# Colors
# ============================================================================
RED="\e[1;31m" 
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
BLUE="\e[38;5;24m"
MAGENTA="\e[1;35m"
CYAN="\e[1;36m"
WHITE="\e[1;37m"
GRAY="\e[1;90m"
TEAL='\e[38;5;30m'
TEAL_DARK='\e[38;5;29m'
ORANGE='\e[38;5;208m' 

BOLD='\e[1m'
UNDERLINE='\e[4m'
RESET='\e[0m'

# ============================================================================
# SHELL OPTIONS
# ============================================================================

# Disable ctrl-s and ctrl-q (terminal pause)
stty -ixon

# Better history management
shopt -s histappend              # Append to history, don't overwrite
shopt -s checkwinsize            # Check window size after each command
shopt -s cdspell                 # Autocorrect typos in path names when using cd
shopt -s dirspell                # Correct directory name typos
shopt -s autocd                  # Type directory name to cd
shopt -s globstar                # Allow ** for recursive matching
shopt -s nocaseglob              # Case-insensitive globbing
shopt -s extglob                 # Extended pattern matching

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================

export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:cd:pwd:exit:clear:history"
export HISTTIMEFORMAT="%F %T "

# Write history after each command prompt (fast + sane)
# Append without duplicating if re-sourced
case ";$PROMPT_COMMAND;" in
  *";history -a;"*) : ;;
  *)
    PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    ;;
esac

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Path configuration
export PATH="$HOME/scripts:$HOME/.local/bin:/usr/local/go/bin:$HOME/.cargo/bin:$PATH"

# Default editors
export EDITOR=$(command -v nvim || command -v vim || command -v micro || echo nano)
export VISUAL="$EDITOR"

# Better less defaults
export LESS='-R -F -X -i -P %f (%i/%m) '
export LESSHISTFILE=/dev/null

# Locale - set to en_US.UTF-8 if available, otherwise fall back to C.UTF-8
if locale -a 2>/dev/null | grep -qi "en_US.utf"; then
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
elif locale -a 2>/dev/null | grep -qi "C.UTF"; then
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
fi

# ============================================================================
# LOAD MODULAR CONFIGURATIONS
# ============================================================================

BASH_CONFIG_DIR="$HOME/.config/bash"

if [ -d "$BASH_CONFIG_DIR" ]; then
    # Load functions FIRST
    if [ -d "$BASH_CONFIG_DIR/functions" ]; then
        for func in "$BASH_CONFIG_DIR/functions"/*.bash; do
            [ -f "$func" ] || continue
            if ! source "$func" 2>/dev/null; then
                echo -e "\e[1;31m⚠ Warning: Error loading Functions: $(basename "$func")\e[0m" >&2
            fi
        done
    fi

    # Load main config files
    for config in "$BASH_CONFIG_DIR"/*.bash; do
        [ -f "$config" ] || continue
        if ! source "$config" 2>/dev/null; then
            echo -e "\e[1;31m⚠ Warning: Error loading Main: $(basename "$config")\e[0m" >&2
        fi
    done
fi

# ============================================================================
# COMPLETION
# ============================================================================

# Enable programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

[ -f /usr/share/bash-completion/completions/git ] && . /usr/share/bash-completion/completions/git



# ============================================================================
# LOCAL OVERRIDES
# ============================================================================
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"


# ============================================================================
# WELCOME MESSAGE
# ============================================================================

# Display system info on login (optional - comment out if not wanted)
#if [ -n "$PS1" ]; then
#    echo -e "\e[38;5;24m=== Welcome back, $USER! ===\e[0m"
#    echo -e "Date: $(date '+%A, %B %d, %Y - %H:%M:%S')"
#    echo -e "Uptime:$(uptime | sed 's/up //')"
#    echo -e "Load: $(uptime | awk -F'load average:' '{print $2}')"
#    echo
#fi
# End of .bashrc

