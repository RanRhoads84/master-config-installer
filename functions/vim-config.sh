#!/usr/bin/env bash
# setup/vim-config.sh — install vim configuration from vim-config/
# Sourceable by install.sh or runnable standalone.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    DRY_RUN=0
    ASSUME_YES=0
    log() { printf "%s %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1"; }
    run_cmd() {
        log "RUN: $*"
        [[ "$DRY_RUN" -eq 1 ]] && { log "DRY-RUN: $*"; return 0; }
        bash -c "$*"
    }
    cd "$_REPO_ROOT"
fi

do_vim_config() {
    local vim_config_dir="vim-config"
    [ -d "$vim_config_dir" ] || return
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=y
    else
        read -r -p "Install vim configuration? [Y/n] " ans || true
        ans=${ans:-y}
    fi
    if [[ "$ans" =~ ^[Yy] ]]; then
        log "Installing vim configuration"
        run_cmd "cd $vim_config_dir && ./depends.sh"
        run_cmd "cd $vim_config_dir && ./install.sh"
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "Vim config" "installed"
    else
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "Vim config" "skipped"
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && do_vim_config
