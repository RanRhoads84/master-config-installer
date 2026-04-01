#!/usr/bin/env bash
# setup/npm.sh — install global npm packages from packages/npm.txt
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

do_npm() {
    local npm_file="packages/npm.txt"
    [ -f "$npm_file" ] || return
    mapfile -t npm_pkgs < <(grep -E -v '^\s*#' "$npm_file" | sed '/^$/d')
    [ ${#npm_pkgs[@]} -eq 0 ] && return
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=y
    else
        read -r -p "Install npm global packages? (${#npm_pkgs[@]}) [Y/n] " ans || true
        ans=${ans:-y}
    fi
    if [[ "$ans" =~ ^[Yy] ]]; then
        for p in "${npm_pkgs[@]}"; do
            run_cmd "npm install -g $p"
        done
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && do_npm
