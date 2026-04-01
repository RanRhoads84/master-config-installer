#!/usr/bin/env bash
# setup/flatpak.sh — install Flatpak and add Flathub remote
# Sourceable by install.sh or runnable standalone.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    DRY_RUN=0
    ASSUME_YES=0
    PM=$(
        if command -v apt >/dev/null 2>&1; then echo apt
        elif command -v dnf >/dev/null 2>&1; then echo dnf
        elif command -v pacman >/dev/null 2>&1; then echo pacman
        elif command -v zypper >/dev/null 2>&1; then echo zypper
        else echo unknown; fi
    )
    case "$PM" in
        apt)    PM_INSTALL_CMD="sudo apt install -y" ;;
        dnf)    PM_INSTALL_CMD="sudo dnf install -y" ;;
        pacman) PM_INSTALL_CMD="sudo pacman -Syu --noconfirm" ;;
        zypper) PM_INSTALL_CMD="sudo zypper install -y" ;;
        *)      PM_INSTALL_CMD="" ;;
    esac
    log() { printf "%s %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1"; }
    run_cmd() {
        log "RUN: $*"
        [[ "$DRY_RUN" -eq 1 ]] && { log "DRY-RUN: $*"; return 0; }
        bash -c "$*"
    }
fi

do_flatpak_setup() {
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=y
    else
        read -r -p "Set up Flatpak (install + add Flathub remote)? [Y/n] " ans || true
        ans=${ans:-y}
    fi
    if [[ ! "$ans" =~ ^[Yy] ]]; then
        log "Skipped Flatpak setup"
        return
    fi
    if ! command -v flatpak >/dev/null 2>&1; then
        if [ -n "$PM_INSTALL_CMD" ]; then
            log "Installing Flatpak via $PM_INSTALL_CMD"
            run_cmd "$PM_INSTALL_CMD flatpak"
        else
            echo "Flatpak is not installed and there is no configured package manager. See https://flatpak.org/setup/ for manual steps."
            return
        fi
    fi
    log "Configuring Flatpak remote"
    run_cmd "flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo"
    run_cmd "flatpak update --assumeyes"
    echo "Flatpak is ready. See https://flatpak.org/setup/ for distro-specific guidance."
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && do_flatpak_setup
