#!/usr/bin/env bash
# functions/modularshell.sh — install ModularShell bash configuration
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
else
    _REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

_ms_backup_existing() {
    local config_dir="$HOME/.config/bash"
    local backup_dir="$HOME/.config/bash.backup.$(date +%Y%m%d_%H%M%S)"
    local bashrc_backup="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"

    if [ -f "$HOME/.bashrc" ]; then
        run_cmd "cp \"$HOME/.bashrc\" \"$bashrc_backup\""
        log "Backed up .bashrc to $bashrc_backup"
    fi
    if [ -d "$config_dir" ]; then
        run_cmd "cp -a \"$config_dir\" \"$backup_dir\""
        run_cmd "rm -rf \"$config_dir\""
        log "Backed up existing bash config to $backup_dir"
    fi
}

_ms_install_files() {
    local src_bash="$_REPO_ROOT/modularshell/bash"
    local src_libs="$_REPO_ROOT/libs"
    local src_bashrc="$_REPO_ROOT/modularshell/bashrc.example"
    local config_dir="$HOME/.config/bash"

    if [ ! -d "$src_bash" ] || [ ! -f "$src_bashrc" ]; then
        log "ModularShell source files not found at $_REPO_ROOT/modularshell"
        echo "Error: ModularShell source files not found." >&2
        return 1
    fi

    run_cmd "mkdir -p \"$config_dir/functions\" \"$config_dir/libs\""
    run_cmd "cp -r \"$src_bash/.\" \"$config_dir/\""
    log "Copied bash config files to $config_dir"

    if [ -d "$src_libs" ]; then
        run_cmd "cp -r \"$src_libs/.\" \"$config_dir/libs/\""
        log "Copied library files to $config_dir/libs"
    else
        log "libs/ not found; skipping library copy"
    fi

    run_cmd "cp \"$src_bashrc\" \"$HOME/.bashrc\""
    log "Installed .bashrc"
}

_ms_install_man_page() {
    local man_source="$_REPO_ROOT/modularshell/man/man7/modularshell.7"
    local man_dir="$HOME/.local/share/man/man7"

    if [ ! -f "$man_source" ]; then
        log "ModularShell man page not found: $man_source"
        return
    fi

    run_cmd "mkdir -p \"$man_dir\""
    run_cmd "cp \"$man_source\" \"$man_dir/\""
    log "Installed ModularShell man page"

    if command -v mandb >/dev/null 2>&1; then
        run_cmd "mandb -q \"$HOME/.local/share/man\" >/dev/null 2>&1 || true"
    fi
}

_ms_install_deps() {
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=n
    else
        read -r -p "Install recommended tools for ModularShell? (fzf, ripgrep, eza) [y/N] " ans || true
        ans=${ans:-n}
    fi
    [[ "$ans" =~ ^[Yy] ]] || return

    local tools=(fzf ripgrep)
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log "Already installed: $tool"
        else
            run_cmd "$PM_INSTALL_CMD $tool"
        fi
    done

    # eza — try eza then exa as fallback
    if ! command -v eza >/dev/null 2>&1 && ! command -v exa >/dev/null 2>&1; then
        if [ "$PM" = "pacman" ]; then
            # eza is in official Arch repos
            run_cmd "$PM_INSTALL_CMD eza"
        else
            run_cmd "$PM_INSTALL_CMD eza 2>/dev/null || $PM_INSTALL_CMD exa 2>/dev/null || true"
        fi
    else
        log "Already installed: eza/exa"
    fi
}

do_modularshell() {
    local ans
    if [ "$ASSUME_YES" -eq 1 ]; then
        ans=y
    else
        read -r -p "Install ModularShell bash configuration? [Y/n] " ans || true
        ans=${ans:-y}
    fi
    if [[ ! "$ans" =~ ^[Yy] ]]; then
        log "Skipped ModularShell install"
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "ModularShell" "skipped"
        return
    fi

    if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
        echo "Warning: Bash 4+ recommended (you have $BASH_VERSION)"
    fi

    _ms_backup_existing
    if ! _ms_install_files; then
        declare -f _summary_record >/dev/null 2>&1 && _summary_record "ModularShell" "failed" "source files not found"
        return
    fi
    _ms_install_man_page
    _ms_install_deps

    log "ModularShell install complete"
    echo "ModularShell installed. Reload your shell with: source ~/.bashrc"
    declare -f _summary_record >/dev/null 2>&1 && _summary_record "ModularShell" "installed"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && do_modularshell
