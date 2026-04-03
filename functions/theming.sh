#!/usr/bin/env bash
# setup/theming.sh — install Nerd Fonts and wallpapers via theming/
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

do_theming_assets() {
    local script="theming/install_fonts-wallpapers.sh"
    [ -f "$script" ] || return
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=y
    else
        read -r -p "Install Nerd Fonts and wallpapers? [Y/n] " ans || true
        ans=${ans:-y}
    fi
    if [[ "$ans" =~ ^[Yy] ]]; then
        log "Running theming assets installer"
        run_cmd "cd \"theming\" && ./install_fonts-wallpapers.sh"
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "Theming assets" "installed" "fonts + wallpapers"
    else
        log "Skipped theming assets installer"
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "Theming assets" "skipped"
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && do_theming_assets
