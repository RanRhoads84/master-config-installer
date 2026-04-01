#!/usr/bin/env bash
# setup/git-config.sh — interactive git global configuration
# Can be sourced by install.sh (uses DRY_RUN, ASSUME_YES, run_cmd, log from parent)
# or run standalone.

_git_cfg_standalone=0
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _git_cfg_standalone=1
    set -euo pipefail
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$script_dir/../libs/text_mods.bash"
    DRY_RUN=0
    ASSUME_YES=0
    log() { printf "%s %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1"; }
    run_cmd() {
        log "RUN: $*"
        [[ "$DRY_RUN" -eq 1 ]] && { log "DRY-RUN: $*"; return 0; }
        bash -c "$*"
    }
fi

_gcfg_ask() {
    local prompt="$1" default="${2:-}" result
    if [[ -n "$default" ]]; then
        read -rp "$(printf "${CYAN}%s${NC} [${default}]: " "$prompt")" result
        echo "${result:-$default}"
    else
        read -rp "$(printf "${CYAN}%s${NC}: " "$prompt")" result
        echo "$result"
    fi
}

_gcfg_ask_yn() {
    local prompt="$1" default="${2:-n}" result
    read -rp "$(printf "${CYAN}%s${NC} [y/N]: " "$prompt")" result
    result="${result:-$default}"
    [[ "$result" =~ ^[Yy]$ ]]
}

_gcfg_header() {
    printf "\n${BOLD}${GREEN}=== %s ===${NC}\n" "$1"
}

do_git_config() {
    local ans
    if [[ "$ASSUME_YES" -eq 1 ]]; then
        ans=n
    else
        read -r -p "Configure global git settings? [Y/n] " ans || true
        ans=${ans:-y}
    fi
    [[ "$ans" =~ ^[Yy] ]] || { log "Skipped git config setup"; return; }

    # ── Identity ──────────────────────────────────────────────────────────────
    _gcfg_header "Identity"
    local current_name current_email
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")
    local name email
    name=$(_gcfg_ask "Full name" "$current_name")
    email=$(_gcfg_ask "Email address" "$current_email")
    run_cmd "git config --global user.name \"$name\""
    run_cmd "git config --global user.email \"$email\""

    # ── Editor ────────────────────────────────────────────────────────────────
    _gcfg_header "Editor"
    local current_editor
    current_editor=$(git config --global core.editor 2>/dev/null || echo "vim")
    local editor
    editor=$(_gcfg_ask "Default editor (vim/nano/nvim/code --wait/etc.)" "$current_editor")
    run_cmd "git config --global core.editor \"$editor\""

    # ── Default branch ────────────────────────────────────────────────────────
    _gcfg_header "Default branch"
    local current_branch
    current_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "main")
    local default_branch
    default_branch=$(_gcfg_ask "Default branch name for new repos" "$current_branch")
    run_cmd "git config --global init.defaultBranch \"$default_branch\""

    # ── Pull / merge strategy ─────────────────────────────────────────────────
    _gcfg_header "Merge / Rebase strategy"
    echo "  1) merge  (default)"
    echo "  2) rebase"
    echo "  3) fast-forward only"
    local strategy_choice
    read -rp "$(printf "${CYAN}Choose [1-3]${NC} [1]: ")" strategy_choice
    case "${strategy_choice:-1}" in
        2) run_cmd "git config --global pull.rebase true"
           printf "${YELLOW}Set: pull.rebase = true${NC}\n" ;;
        3) run_cmd "git config --global pull.ff only"
           printf "${YELLOW}Set: pull.ff = only${NC}\n" ;;
        *) run_cmd "git config --global pull.rebase false"
           printf "${YELLOW}Set: pull.rebase = false (merge)${NC}\n" ;;
    esac

    # ── Signing ───────────────────────────────────────────────────────────────
    _gcfg_header "Commit Signing"
    if _gcfg_ask_yn "Sign commits with an SSH key?"; then
        local ssh_key
        ssh_key=$(_gcfg_ask "Path to SSH public key" "$HOME/.ssh/id_ed25519.pub")
        run_cmd "git config --global gpg.format ssh"
        run_cmd "git config --global user.signingKey \"$ssh_key\""
        run_cmd "git config --global commit.gpgSign true"
        run_cmd "git config --global tag.gpgSign true"
        printf "${YELLOW}SSH signing enabled: %s${NC}\n" "$ssh_key"
    elif _gcfg_ask_yn "Sign commits with a GPG key instead?"; then
        local gpg_keys
        gpg_keys=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null \
                   | grep sec | awk '{print $2}' | cut -d/ -f2 || true)
        [[ -n "$gpg_keys" ]] && { echo "Available GPG keys:"; echo "$gpg_keys"; }
        local gpg_key
        gpg_key=$(_gcfg_ask "GPG key ID")
        run_cmd "git config --global gpg.format openpgp"
        run_cmd "git config --global user.signingKey \"$gpg_key\""
        run_cmd "git config --global commit.gpgSign true"
        run_cmd "git config --global tag.gpgSign true"
        printf "${YELLOW}GPG signing enabled: %s${NC}\n" "$gpg_key"
    else
        run_cmd "git config --global commit.gpgSign false"
        run_cmd "git config --global tag.gpgSign false"
        printf "${YELLOW}Commit signing disabled.${NC}\n"
    fi

    # ── Credential helper ─────────────────────────────────────────────────────
    _gcfg_header "Credential helper"
    if _gcfg_ask_yn "Set a global credential helper? (useful for HTTPS remotes)"; then
        echo "  1) store   (plaintext)"
        echo "  2) cache   (in-memory, 15 min)"
        echo "  3) manager (git-credential-manager)"
        echo "  4) skip"
        local cred_choice
        read -rp "$(printf "${CYAN}Choose [1-4]${NC} [4]: ")" cred_choice
        case "${cred_choice:-4}" in
            1) run_cmd "git config --global credential.helper store" ;;
            2) run_cmd "git config --global credential.helper 'cache --timeout=900'" ;;
            3) run_cmd "git config --global credential.helper manager" ;;
            *) printf "${YELLOW}Skipped.${NC}\n" ;;
        esac
    fi

    # ── Remotes ───────────────────────────────────────────────────────────────
    _gcfg_header "Remotes"
    if _gcfg_ask_yn "Set up git remotes for a repository?"; then
        local repo_path
        repo_path=$(_gcfg_ask "Path to repository" "$(pwd)")
        if [[ ! -d "$repo_path/.git" ]]; then
            printf "${YELLOW}No git repository found at %s — skipping remotes.${NC}\n" "$repo_path"
        else
            local adding_remotes=1
            while [[ "$adding_remotes" -eq 1 ]]; do
                echo
                echo "Current remotes:"
                git -C "$repo_path" remote -v 2>/dev/null || echo "  (none)"
                echo
                echo "  1) Add remote"
                echo "  2) Remove remote"
                echo "  3) Rename remote"
                echo "  4) Done"
                local remote_choice
                read -rp "$(printf "${CYAN}Choose [1-4]${NC} [4]: ")" remote_choice
                case "${remote_choice:-4}" in
                    1)
                        local rname rurl
                        rname=$(_gcfg_ask "Remote name" "origin")
                        rurl=$(_gcfg_ask "Remote URL (SSH or HTTPS)")
                        if git -C "$repo_path" remote get-url "$rname" &>/dev/null; then
                            printf "${YELLOW}Remote '%s' already exists. Updating URL.${NC}\n" "$rname"
                            run_cmd "git -C \"$repo_path\" remote set-url \"$rname\" \"$rurl\""
                        else
                            run_cmd "git -C \"$repo_path\" remote add \"$rname\" \"$rurl\""
                        fi
                        ;;
                    2)
                        local rremove
                        rremove=$(_gcfg_ask "Remote name to remove")
                        run_cmd "git -C \"$repo_path\" remote remove \"$rremove\""
                        ;;
                    3)
                        local rold rnew
                        rold=$(_gcfg_ask "Current remote name")
                        rnew=$(_gcfg_ask "New remote name")
                        run_cmd "git -C \"$repo_path\" remote rename \"$rold\" \"$rnew\""
                        ;;
                    *)
                        adding_remotes=0
                        ;;
                esac
            done
            echo
            echo "Final remotes:"
            git -C "$repo_path" remote -v 2>/dev/null || echo "  (none)"
        fi
    fi

    # ── Quality-of-life ───────────────────────────────────────────────────────
    _gcfg_header "Quality-of-life defaults"
    _gcfg_ask_yn "Enable autocorrect for mistyped commands?" \
        && run_cmd "git config --global help.autocorrect 10"
    _gcfg_ask_yn "Use color UI always?" \
        && run_cmd "git config --global color.ui always"
    _gcfg_ask_yn "Set push.default to 'current'?" \
        && run_cmd "git config --global push.default current"

    _gcfg_header "Done — current global git config"
    git config --global --list
    log "Git config setup complete"
}

# Run directly if executed as a standalone script
[[ "$_git_cfg_standalone" -eq 1 ]] && do_git_config
