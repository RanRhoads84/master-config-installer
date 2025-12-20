####################################
## System-related functions
###################################

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect package manager
detect_pkg_mgr() {
    # Prefer the “real” system managers first.
    for pm in apt-get dnf zypper pacman apk xbps-install emerge nix-env; do
        if command_exists "$pm"; then
            PKG_MGR="$pm"
            export PKG_MGR
            return 0
        fi
    done
    PKG_MGR="unknown"
    export PKG_MGR
    return 1
}

pkg_init() {
    detect_pkg_mgr >/dev/null 2>&1 || return 1

    case "$PKG_MGR" in
        apk)
            pkg_install()   { sudo apk add "$@"; }
            pkg_search()    { apk search "$@"; }
            pkg_update()    { sudo apk update; }
            pkg_upgrade()   { sudo apk upgrade; }
            pkg_remove()    { sudo apk del "$@"; }
            pkg_uplist()    { apk list -u; }
            pkg_autoremove(){ echo "apk: no direct autoremove equivalent"; return 1; }
            ;;
        apt-get)
            pkg_install()   { sudo apt-get install -y "$@"; }
            pkg_search()    { apt-cache search "$@"; }
            pkg_update()    { sudo apt-get update; }
            pkg_upgrade()   { sudo apt-get update && sudo apt-get upgrade -y; }
            pkg_remove()    { sudo apt-get remove -y "$@"; }
            pkg_uplist()    { apt list --upgradable; }
            pkg_autoremove(){ sudo apt-get autoremove -y --purge; }
            ;;
        dnf)
            pkg_install()   { sudo dnf install -y "$@"; }
            pkg_search()    { dnf search "$@"; }
            pkg_update()    { sudo dnf check-update || true; }
            pkg_upgrade()   { sudo dnf upgrade -y; }
            pkg_remove()    { sudo dnf remove -y "$@"; }
            pkg_uplist()    { dnf list --upgrades; }
            pkg_autoremove(){ sudo dnf autoremove -y; }
            ;;
        pacman)
            pkg_install()   { sudo pacman -S --noconfirm "$@"; }
            pkg_search()    { pacman -Ss "$@"; }
            pkg_update()    { sudo pacman -Sy; }
            pkg_upgrade()   { sudo pacman -Syu --noconfirm; }
            pkg_remove()    { sudo pacman -R --noconfirm "$@"; }
            pkg_uplist()    { pacman -Qu; }
            pkg_autoremove(){ sudo pacman -Rns --noconfirm $(pacman -Qtdq 2>/dev/null) 2>/dev/null || true; }
            ;;
        xbps-install)
            pkg_install()   { sudo xbps-install -y "$@"; }
            pkg_search()    { xbps-query -Rs "$@"; }
            pkg_update()    { sudo xbps-install -S; }
            pkg_upgrade()   { sudo xbps-install -Su; }
            pkg_remove()    { sudo xbps-remove -y "$@"; }
            pkg_uplist()    { xbps-install -Mun; }
            pkg_autoremove(){ echo "xbps: autoremove is manual"; return 1; }
            ;;
        zypper)
            # Sudo Required 
            pkg_install()   { sudo zypper install "$@"; }
            pkg_remove()    { sudo zypper remove "$@"; }
            pkg_update()    { sudo zypper up; } # Updates pkgs

            # Zypper Exclusive
            pkg_refresh()   { sudo zypper refresh; }
            pkg_upgrade()   { sudo zypper dup "$@"; } # Dist-upgrade
            pkg_newrecs()   { sudo zypper install-new-recommends "$@"; }
            
            # Sudoless commands
            pkg_search()    { zypper search "$@"; }
            pkg_info()      { zypper info "$@"; }
            
            # Zypper Exclusive
            pkg_patchs()    { zypper pchk; }
            pkg_uplist()    { zypper list-updates; }
            ;;
        *)
            return 1
            ;;
    esac #

    # User convenience wrappers
    install()   { pkg_install "$@"; }
    remove()    { pkg_remove "$@"; }
    search()    { pkg_search "$@"; }
    update()    { pkg_update; }
    upgrade()   { pkg_upgrade; }
    autoremove() { pkg_autoremove; }

    # Zypper Exclusive
    newrecs()   { pkg_newrecs; } 
    refresh()   { pkg_refresh; } 
    patches()   { pkg_patchs; }
    uplist()    { pkg_uplist; }
    info()      { pkg_info "$@"; }
}
pkg_init

# Process grep with header
psg() {
    if [ -z "$1" ]; then
        echo "Usage: psg <process_name>"
        return 1
    fi
    ps aux | head -1
    ps aux | awk 'NR==1 || tolower($0) ~ tolower(ARGV[1])' "$1"

}

# System information
sysinfo() {
    echo -e "=== System Information ==="
    echo -e "Hostname: $(hostname)"
    echo -e "Kernel: $(uname -r)"
    echo -e "Uptime: $(uptime)"
    echo -e "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
}

# System Distro Logo ( requires screenfetch )
print_distro_logo() {
    [[ $- != *i* ]] && return

    # Calculate dynamic indent based on terminal width
    local cols indent
    cols=$(tput cols 2>/dev/null || echo 80)
    indent=$(( cols / 12 )) # adjust divisor: smaller = further right

    # Generate spaces
    indent=$(printf '%*s' "$indent")

    if command -v screenfetch >/dev/null 2>&1; then
        screenfetch -L 2>/dev/null | sed "s/^/${indent}/"
        return
    fi

    # Fallback if screenfetch is unavailable
    if [ -r /etc/os-release ]; then
        . /etc/os-release
        printf "%s%s%s\n" "$indent" "$GREEN" "$ID$RESET"
    fi
}

# Find GPU
get_gpu() {
    if command -v lspci >/dev/null 2>&1; then
        # Prefer NVIDIA / AMD over Intel
        lspci | grep -Ei 'vga|3d|display' | grep -Ei 'nvidia|amd' | head -1 | sed 's/.*: //'
        # Fallback to first GPU if no discrete found
        lspci | grep -Ei 'vga|3d|display' | head -1 | sed 's/.*: //'
    fi
}

# Uptime Calc
get_uptime() {
    local up
    up=$(cut -d. -f1 /proc/uptime)

    local days=$((up/86400))
    local hours=$(( (up%86400)/3600 ))
    local mins=$(( (up%3600)/60 ))

    if (( days > 0 )); then
        printf "%dd %dh %dm\n" "$days" "$hours" "$mins"
    elif (( hours > 0 )); then
        printf "%dh %dm\n" "$hours" "$mins"
    else
        printf "%dm\n" "$mins"
    fi
}

# System Overview
system_overview() {
    echo
    echo -e "${BLUE}============ System Overview =============${RESET}"

    OS="$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")"

    printf "%-12s %s\n" "User:"    "$USER@$(hostname)"
    printf "%-12s %s\n" "OS:"      "$OS"
    printf "%-12s %s\n" "Kernel:"  "$(uname -r)"
    printf "%-12s %s\n" "Uptime:" "$(get_uptime)"
    printf "%-12s %s\n" "Shell:"   "bash $BASH_VERSION"
    printf "%-12s %s\n" "CPU Load:" "$(uptime | awk -F'load average:' '{print $2}')"
    printf "%-12s %s\n" "Memory:"  "$(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    printf "%-12s %s\n" "Disk:"    "$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"

    GPU="$(get_gpu)"
    [ -n "$GPU" ] && printf "%-12s %s\n" "GPU:" "$GPU"

    echo
}
##################################
## Utility functions
##################################

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Search history
hgrep() {
    history | grep -i "$1"
}

# Get size of directory
dirsize() {
    du -sh "${1:-.}" 2>/dev/null | awk '{print $1}'
}

# Show PATH in readable format
path() {
    echo "$PATH" | tr ':' '\n' | nl
}
##########################################################################################
# Purpose:
#   Collection of interactive shell helper functions for system inspection and
#   package management convenience wrappers. Intended for interactive use
#   (sourced into a shell), not as a standalone executable script.
#
# Globals:
#   PKG_MGR  - exported string set by detect_pkg_mgr to the detected package
#              manager (e.g. apt-get, dnf, zypper, pacman, apk, xbps-install,
#              emerge, nix-env) or "unknown" if none detected.
#
# Functions:
#   command_exists <cmd>
#     - Returns 0 if <cmd> exists in PATH, else non-zero.
#
#   detect_pkg_mgr
#     - Probes common package manager commands in a preferred order and sets
#       PKG_MGR accordingly. Exports PKG_MGR. Returns 0 on success, 1 if none
#       found.
#
#   pkg_init
#     - Calls detect_pkg_mgr (silently when sourced). If a supported manager is
#       detected, it defines manager-specific internal helpers (pkg_install,
#       pkg_search, pkg_update, pkg_upgrade, pkg_remove, pkg_uplist,
#       pkg_autoremove) and user-facing wrappers:
#         install  <pkgs>  -> pkg_install
#         search   <term>  -> pkg_search
#         update            -> pkg_update
#         upgrade           -> pkg_upgrade
#         remove   <pkgs>  -> pkg_remove
#         uplist            -> pkg_uplist
#         autoremove <args> -> pkg_autoremove
#     - Many implementations invoke sudo and use the distro's recommended flags.
#     - If no supported manager is detected, PKG_MGR="unknown" and the wrappers
#       are not defined.
#
#   psg <process_name>
#     - Prints ps aux header then filters processes (case-insensitive),
#       excluding the grep process. Returns non-zero if usage error.
#
#   sysinfo
#     - Prints concise system information: hostname, kernel, uptime, memory
#       usage, load averages, and root filesystem disk usage. Uses common
#       system utilities (hostname, uname, uptime, free, df).
#
#   mkcd <dir>
#     - Creates <dir> (mkdir -p) and cds into it on success.
#
#   extract <archive>
#     - Convenience wrapper to extract many archive formats (tar.*, zip, gz,
#       bz2, 7z, rar, Z). Prints an error if the argument is missing or the
#       file type is unsupported. Requires the appropriate extraction tools
#       (tar, unzip, 7z, unrar, etc.).
#
#   hgrep <pattern>
#     - Greps the shell history for a case-insensitive match of <pattern>.
#
#   dirsize [path]
#     - Prints human-readable total size of the given directory (defaults to
#       current directory). Suppresses du errors.
#
#   path
#     - Displays $PATH each entry on its own line with line numbers.
#
# Exit codes:
#   - Most helpers return conventional exit codes: 0 on success, non-zero on
#     failure or incorrect usage. pkg_init/detect_pkg_mgr return 0 when a
#     manager is found, 1 when none is found.
#
# Notes and caveats:
#   - Functions assume an interactive environment and that external utilities
#     (sudo, tar, apt-get, dnf, pacman, etc.) are available when relevant.
#   - Wrapper semantics vary per package manager (flags, behavior). Read the
#     underlying manager docs if in doubt.
#   - The file auto-calls pkg_init when sourced to populate wrappers if a
#     package manager is detected.
#   - Designed for convenience; audit and adapt commands (especially sudo and
#     autoremove behavior) to your distribution and security policies.
#   - All lines above are comments intended to be included when placing this
#     block into a shell script or README for quick reference.
#########################################################################################
