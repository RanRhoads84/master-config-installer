#!/usr/bin/env bash
# setup/vscode.sh — install Visual Studio Code
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
        pacman) PM_INSTALL_CMD="sudo pacman -Syu" ;;
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

do_vscode_setup() {
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=y
    else
        read -r -p "Set up Visual Studio Code and install code? [Y/n] " ans || true
        ans=${ans:-y}
    fi
    if [[ ! "$ans" =~ ^[Yy] ]]; then
        log "Skipped VS Code setup"
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "skipped"
        return
    fi
    if command -v code >/dev/null 2>&1; then
        log "VS Code already installed; skipping"
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "already_installed"
        return
    fi
    case "$PM" in
        apt)
            run_cmd "sudo apt-get install -y wget gpg"
            local keyring="/usr/share/keyrings/microsoft-vscode.gpg"
            if [ ! -f "$keyring" ]; then
                local tmp_key
                tmp_key=$(mktemp)
                run_cmd "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > $tmp_key"
                run_cmd "sudo install -D -o root -g root -m 644 $tmp_key $keyring"
                run_cmd "rm -f $tmp_key"
            fi
            local sources="/etc/apt/sources.list.d/vscode.sources"
            if [ ! -f "$sources" ]; then
                run_cmd "printf '%s\n' 'Types: deb' 'URIs: https://packages.microsoft.com/repos/code' 'Suites: stable' 'Components: main' 'Architectures: amd64,arm64,armhf' \"Signed-By: $keyring\" | sudo tee \"$sources\" > /dev/null"
            fi
            run_cmd "sudo apt update"
            run_cmd "$PM_INSTALL_CMD code"
            declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "installed" "apt"
            ;;
        dnf)
            run_cmd "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
            local repo_file="/etc/yum.repos.d/vscode.repo"
            if [ ! -f "$repo_file" ]; then
                run_cmd "printf '%s\n' '[code]' 'name=Visual Studio Code' 'baseurl=https://packages.microsoft.com/yumrepos/vscode' 'enabled=1' 'autorefresh=1' 'type=rpm-md' 'gpgcheck=1' 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee \"$repo_file\" > /dev/null"
            fi
            run_cmd "sudo dnf check-update"
            run_cmd "sudo dnf install -y code"
            declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "installed" "dnf"
            ;;
        zypper)
            run_cmd "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
            local repo_file="/etc/zypp/repos.d/vscode.repo"
            if [ ! -f "$repo_file" ]; then
                run_cmd "printf '%s\n' '[code]' 'name=Visual Studio Code' 'baseurl=https://packages.microsoft.com/yumrepos/vscode' 'enabled=1' 'autorefresh=1' 'type=rpm-md' 'gpgcheck=1' 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee \"$repo_file\" > /dev/null"
            fi
            run_cmd "sudo zypper refresh"
            run_cmd "sudo zypper install -y code"
            declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "installed" "zypper"
            ;;
        pacman)
            echo "  1) visual-studio-code-bin (AUR) — full Microsoft build with marketplace and all features (recommended)"
            echo "  2) code (official repos)        — open-source build, lacks Microsoft marketplace and proprietary features"
            echo "  3) skip"
            local vscode_choice
            read -r -p "Which VS Code build would you like to install? [1/2/3] (default: 1): " vscode_choice || true
            vscode_choice=${vscode_choice:-1}
            case "$vscode_choice" in
                1)
                    if command -v yay >/dev/null 2>&1; then
                        local yay_ans
                        read -r -p "Install 'visual-studio-code-bin' from AUR via yay? [y/N] " yay_ans || true
                        yay_ans=${yay_ans:-n}
                        if [[ "$yay_ans" =~ ^[Yy] ]]; then
                            run_cmd "yay -S --noconfirm visual-studio-code-bin"
                            declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "installed" "visual-studio-code-bin (AUR)"
                        else
                            log "Skipped VS Code AUR install"
                            declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "skipped"
                        fi
                    else
                        log "yay not available; cannot install from AUR"
                        echo "yay is not installed. Install yay first to get visual-studio-code-bin from AUR."
                        declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "failed" "yay not installed"
                    fi
                    ;;
                2)
                    run_cmd "sudo pacman -S --noconfirm code"
                    declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "installed" "code (OSS, pacman)"
                    ;;
                *)
                    log "Skipped VS Code install"
                    declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "skipped"
                    ;;
            esac
            ;;
        *)
            log "VS Code setup is only wired for apt/dnf/zypper/pacman; skipping for $PM"
            declare -f _summary_record >/dev/null 2>&1 && _summary_record "VS Code" "skipped" "unsupported PM: $PM"
            ;;
    esac
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && do_vscode_setup
