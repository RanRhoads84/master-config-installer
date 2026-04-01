#!/usr/bin/env bash

# Envitroment Variables for Bash

# set bat as manpager
eval "$(batman --export-env)"

# Bash completion with 'uv'
. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion bash)"

# Python is Python3 and Maybe pip too...
alias python="python3"
# alias pip="pip3"

# Neovim Path
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

export PATH="$HOME/.opencode/bin:$PATH"

# Cargo Just Path
export PATH="$HOME/.cargo/bin:$PATH"

. "$HOME/.local/share/../bin/env"

