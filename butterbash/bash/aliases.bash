#!/usr/bin/env bash
# Bash aliases

# ============================================================================
# NAVIGATION
# ============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ============================================================================
# LS VARIANTS
# ============================================================================
if command -v eza >/dev/null 2>&1; then
    alias l='eza -ll --color=always --group-directories-first'
    alias ls='eza -al --header --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias lt='eza --tree --level=2 --icons'
    alias lh='eza -la --sort=modified --reverse'
elif command -v exa >/dev/null 2>&1; then
    alias l='exa -l --color=always --group-directories-first'
    alias ls='exa -a --icons --group-directories-first'
    alias ll='exa -la --icons --group-directories-first'
    alias la='exa -la --icons --group-directories-first'
    alias lt='exa --tree --level=2 --icons'
    alias lh='exa -la --sort=modified --reverse'
else
    alias l='ls -lF'
    alias ll='ls -lahX'
    alias la='ls -A'
    alias lt='tree -L 2'
    alias lh='ls -lath'
fi

# ============================================================================
# FILE OPERATIONS
# ============================================================================
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -p'

# ============================================================================
# SYSTEM INFO
# ============================================================================
alias df='df -h'
alias du='du -h'
alias free='free -h'
#alias ps='ps auxf'
#alias top='btop || htop || top'
alias mem='free -h && echo && ps aux | head -1 && ps aux | sort -rnk 4 | head -5'
alias cpu='ps aux | head -1 && ps aux | sort -rnk 3 | head -5'

# ============================================================================
# NETWORK
# ============================================================================
alias myip="hostname -I | awk '{print \$1}' && echo -n 'External: ' && curl -s ifconfig.me && echo"
alias ports='ss -tulanp'
alias listening='lsof -P -i -n'

# ============================================================================
# GIT
# ============================================================================
alias g='git'
alias gs='git status'
alias gaa='git add'
alias ga='git add -A'
alias gcm='git commit'
alias gc='git commit -m'
alias gp='git push'
alias gpu='git push -u origin main'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gclone='git clone'

# ============================================================================
# EDITORS AND CONFIG
# ============================================================================

# Config files
alias bashrc='${EDITOR} ~/.bashrc'
alias config-bash='${EDITOR} ~/.config/bash .'
alias reload-bash='source ~/.bashrc && echo "Reloaded .bashrc"'
alias config-vim='${EDITOR} ~/.vim .'
#alias tmuxconf='${EDITOR} ~/.tmux.conf'

# ============================================================================
# DIRECTORY SHORTCUTS
# ============================================================================
alias gconf='cd ~/.config'
alias gdown='cd ~/Downloads'
alias gdoc='cd ~/Documents'
alias gvid='cd ~/Videos'

# ============================================================================
# UTILITIES
# ============================================================================

# Terminal shortcuts
alias x='exit'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias now='date +"%Y-%m-%d %T"'
alias week='date +%V'

# File search and grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Disk usage
alias biggest='du -h --max-depth=1 | sort -h'

# Process management
alias k9='kill -9'
alias killall='killall -v'

# Misc
alias ff='fastfetch || neofetch'
alias hi='(pgrep -x dunst >/dev/null || pgrep -x swaync >/dev/null) && notify-send "Hi there!" "Welcome to ${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-Linux}}! 🍃" -i ""'
