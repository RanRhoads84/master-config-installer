#!/usr/bin/env bash
# setup/cargo.sh — install cargo packages from packages/cargo.txt
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

do_cargo() {
    local cargo_file="packages/cargo.txt"
    [ -f "$cargo_file" ] || return
    mapfile -t cargo_pkgs < <(grep -E -v '^\s*#' "$cargo_file" | sed '/^$/d')
    [ ${#cargo_pkgs[@]} -eq 0 ] && return
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=y
    else
        read -r -p "Install cargo packages? (${#cargo_pkgs[@]}) [Y/n] " ans || true
        ans=${ans:-y}
    fi
    if [[ "$ans" =~ ^[Yy] ]]; then
        for p in "${cargo_pkgs[@]}"; do
            run_cmd "cargo install $p || true"
        done
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && do_cargo
