#!/usr/bin/env bash

# Simplified installer

IFS=$'\n\t'

# shellcheck source=libs/text_mods.bash
source "$(dirname "$0")/libs/text_mods.bash"

LOGFILE="./modularconfig-install.log"
DRY_RUN=0
ASSUME_YES=0
SELECT_GROUPS=""
PM_INSTALL_CMD=""
OVERRIDE_PM=""
IGNORE_PKG_DB="${IGNORE_PKG_DB:-0}"
CONSOLIDATED_FILE="packages/pkg-list.txt"
declare -a ORDERED_GROUP_INDICES=()

usage() {
  cat <<EOF
Usage: $0 [--dry-run] [--yes] [--log <file>] [--groups <list>]

Options:
  --dry-run        Print commands that would be run (no changes)
  --yes, -y        Assume yes to prompts
  --pm <name>      Override detected package manager (apt|dnf|pacman|zypper)
  --log <file>     Path to log file (default: ./modularconfig-install.log)
  --groups <list>  Comma-separated group names to select non-interactively
  -h, --help       Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --yes|-y|--assume-yes) ASSUME_YES=1; shift ;;
    --log) if [ -n "${2:-}" ]; then LOGFILE="$2"; shift 2; else shift; fi ;;
    --groups) if [ -n "${2:-}" ]; then SELECT_GROUPS="$2"; shift 2; else shift; fi ;;
    --pm) if [ -n "${2:-}" ]; then OVERRIDE_PM="$2"; shift 2; else shift; fi ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    *) break ;;
  esac
done


log() {
  local msg="$1"
  printf "%s %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$msg" | tee -a "$LOGFILE"
}

run_cmd() {
  local cmd="$*"
  log "RUN: $cmd"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY-RUN: $cmd"
    return 0
  fi
  bash -c "$cmd"
}

safe_run() {
  local cmd="$*"
  log "RUN (safe): $cmd"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY-RUN: $cmd"
    return 0
  fi
  bash -c "$cmd" >>"$LOGFILE" 2>&1 || return 1
}

install_suite_man_page() {
  local man_source="man/man7/modularconfig-suite.7"
  local man_dir="$HOME/.local/share/man/man7"

  if [ ! -f "$man_source" ]; then
    log "Suite manual page not found: $man_source"
    return
  fi

  log "Installing suite manual page"
  run_cmd "mkdir -p \"$man_dir\""
  run_cmd "cp \"$man_source\" \"$man_dir/\""
  if command -v mandb >/dev/null 2>&1; then
    run_cmd "mandb -q \"$HOME/.local/share/man\" >/dev/null 2>&1 || true"
  fi
}

detect_pm() {
  if command -v apt >/dev/null 2>&1; then echo apt; return 0; fi
  if command -v dnf >/dev/null 2>&1; then echo dnf; return 0; fi
  if command -v pacman >/dev/null 2>&1; then echo pacman; return 0; fi
  if command -v zypper >/dev/null 2>&1; then echo zypper; return 0; fi
  echo unknown
}

set_pm_install_cmd() {
  case "$1" in
    apt) PM_INSTALL_CMD="sudo apt install -y" ;;
    dnf) PM_INSTALL_CMD="sudo dnf install -y" ;;
    pacman) PM_INSTALL_CMD="sudo pacman -Syu --noconfirm" ;;
    zypper) PM_INSTALL_CMD="sudo zypper install -y" ;;
    *) PM_INSTALL_CMD="sudo apt install -y" ;;
  esac
}

# Leave this commented out for now
#describe_module_scope() {
#  local modules=(browsers git neovim setup system theming modularshell vim-config)
#  local available=()
#  for module in "${modules[@]}"; do
#    if [ -d "$module" ]; then
#      available+=("$module")
#    fi
#  done
#  if [ ${#available[@]} -eq 0 ]; then
#    available=(packages)
#  fi
#  echo "Installer modules: ${available[*]}"
#  log "Installer modules: ${available[*]}"
#}

# shellcheck source=functions/summary.sh
source "$(dirname "$0")/functions/summary.sh"
# shellcheck source=functions/npm.sh
source "$(dirname "$0")/functions/npm.sh"
# shellcheck source=functions/cargo.sh
source "$(dirname "$0")/functions/cargo.sh"
# shellcheck source=functions/vim-config.sh
source "$(dirname "$0")/functions/vim-config.sh"
# shellcheck source=functions/theming.sh
source "$(dirname "$0")/functions/theming.sh"
# shellcheck source=functions/flatpak.sh
source "$(dirname "$0")/functions/flatpak.sh"
# shellcheck source=functions/vscode.sh
source "$(dirname "$0")/functions/vscode.sh"
# shellcheck source=functions/modularshell.sh
source "$(dirname "$0")/functions/modularshell.sh"
# shellcheck source=functions/git-config.sh
source "$(dirname "$0")/functions/git-config.sh"

declare -a MODULE_NAMES=("npm" "Cargo" "Vim Config" "Theming Assets" "Flatpak" "VS Code" "ModularShell" "Git Config")
declare -a MODULE_FUNCS=("do_npm" "do_cargo" "do_vim_config" "do_theming_assets" "do_flatpak_setup" "do_vscode_setup" "do_modularshell" "do_git_config")

if [ -n "$OVERRIDE_PM" ]; then
  PM="$OVERRIDE_PM"
  log "Overriding package manager: $PM"
else
  PM=$(detect_pm)
  if [ "$PM" = "unknown" ]; then
    log "Detected package manager: unknown"
    PM_INSTALL_CMD=""
  else
    log "Detected package manager: $PM"
  fi
fi

if [ -n "$PM" ]; then
  set_pm_install_cmd "$PM"
fi

if [ ! -f "$CONSOLIDATED_FILE" ]; then
  echo "Package list file not found: $CONSOLIDATED_FILE" >&2
  exit 3
fi

install_suite_man_page

declare -a GROUP_ORDER
declare -a GROUP_VALUES
GROUP_ORDER=()
GROUP_VALUES=()
current_group_index=-1
while IFS= read -r line || [ -n "$line" ]; do
  line_trim=$(echo "$line" | sed -E 's/^\s+|\s+$//g')
  if [ -z "$line_trim" ]; then
    continue
  fi
  if [[ "$line_trim" =~ ^# ]]; then
    header=$(echo "$line_trim" | sed -E 's/^#\s*//')
    if [ -n "$header" ]; then
      current_group_index=${#GROUP_ORDER[@]}
      GROUP_ORDER+=("$header")
      GROUP_VALUES+=("")
    fi
    continue
  fi
  if [ "$current_group_index" -lt 0 ]; then
    continue
  fi
  if [ -z "${GROUP_VALUES[$current_group_index]}" ]; then
    GROUP_VALUES[current_group_index]="$line_trim"
  else
    GROUP_VALUES[current_group_index]+=$'\n'$line_trim
  fi
done < "$CONSOLIDATED_FILE"

map_name() {
  local name="$1"
  case "$PM" in
    apt)
      if [ "$name" = "fd" ]; then
        echo "fd-find"
        return
      fi
      if [ "$name" = "bat" ]; then
        echo "batcat"
        return
      fi
      ;;
    pacman|dnf|zypper)
      if [ "$name" = "fd-find" ]; then
        echo "fd"
        return
      fi
      ;;
  esac
  echo "$name"
}

is_installed() {
  local pkg="$1"
  if [ "${IGNORE_PKG_DB:-0}" -eq 1 ]; then
    return 1
  fi
  case "$PM" in
    apt) dpkg -s "$pkg" >/dev/null 2>&1 && return 0 || true ;;
    pacman) pacman -Qi "$pkg" >/dev/null 2>&1 && return 0 || true ;;
    dnf|zypper) rpm -q "$pkg" >/dev/null 2>&1 && return 0 || true ;;
  esac
  if command -v "$pkg" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

declare -a SUBMENU_SELECTIONS=()
declare -a GROUP_INSTALLED=()
declare -a GROUP_TOTAL=()
ORDERED_GROUP_INDICES=()
for i in "${!GROUP_ORDER[@]}"; do
  ORDERED_GROUP_INDICES+=("$i")
done


get_group_packages() {
  local group_idx="$1"
  local pkg
  local packages=()
  while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | sed -E 's/^\s+|\s+$//g')
    [ -z "$pkg" ] && continue
    packages+=("$pkg")
  done <<< "${GROUP_VALUES[$group_idx]}"
  printf '%s\n' "${packages[@]}"
}

APT_UPDATED=0
install_package_batch() {
  local packages=("$@")
  local mapped=()
  local pkg
  for pkg in "${packages[@]}"; do
    [ -z "$pkg" ] && continue
    mapped+=("$(map_name "$pkg")")
  done
  local to_install=()
  for pkg in "${mapped[@]}"; do
    if is_installed "$pkg"; then
      log "Skipping installed package: $pkg"
      (( _PKG_ALREADY_INSTALLED++ )) || true
    else
      to_install+=("$pkg")
    fi
  done
  if [ ${#to_install[@]} -eq 0 ]; then
    log "All selected packages appear to be installed. Nothing to do."
    return 0
  fi
  if [ "$PM" = "apt" ] && [ "$APT_UPDATED" -eq 0 ]; then
    run_cmd "sudo apt update"
    APT_UPDATED=1
  fi
  if [ -z "$PM_INSTALL_CMD" ]; then
    echo "No installation command configured for $PM" >&2
    exit 4
  fi
  # Check repository availability per-package, install what's available and
  # report packages that are not found in the configured repositories.
  pkg_available() {
    local p="$1"
    if [ "${IGNORE_PKG_DB:-0}" -eq 1 ]; then
      return 0
    fi
    case "$PM" in
      apt)
        if apt-cache policy "$p" >/dev/null 2>&1; then
          apt-cache policy "$p" 2>/dev/null | grep -q "Candidate: (none)" && return 1 || return 0
        fi
        return 1
        ;;
      dnf)
        dnf --quiet list available "$p" >/dev/null 2>&1 && return 0 || return 1
        ;;
      pacman)
        pacman -Si "$p" >/dev/null 2>&1 && return 0 || return 1
        ;;
      zypper)
        zypper se -s "$p" >/dev/null 2>&1 && return 0 || return 1
        ;;
      *)
        return 1
        ;;
    esac
  }

  local avail=()
  local missing=()
  for pkg in "${to_install[@]}"; do
    if pkg_available "$pkg"; then
      avail+=("$pkg")
    else
      missing+=("$pkg")
      (( _PKG_UNAVAILABLE++ )) || true
      _PKG_UNAVAILABLE_NAMES+=("$pkg")
    fi
  done

  if [ ${#avail[@]} -eq 0 ]; then
    log "No available packages found in repositories for: ${missing[*]}"
    if [ ${#missing[@]} -gt 0 ]; then
      log "Skipping ${#missing[@]} missing packages"
    fi
    return 0
  fi

  log "Installing ${#avail[@]} packages for $PM"
  local pkg_list
  pkg_list=$(printf '%s ' "${avail[@]}")
  if ! run_cmd "$PM_INSTALL_CMD $pkg_list"; then
    log "Install command failed for some packages; continuing"
    (( _PKG_FAILED += ${#avail[@]} )) || true
  else
    (( _PKG_INSTALLED += ${#avail[@]} )) || true
  fi
  if [ ${#missing[@]} -gt 0 ]; then
    log "Packages not found in repos and skipped: ${missing[*]}"
  fi
}

show_package_submenu() {
  local group_idx="$1"
  local group_name="${GROUP_ORDER[$group_idx]}"
  local group_data="${GROUP_VALUES[$group_idx]}"

  clear
  echo -e "  ${BOLD}${BRIGHT_CYAN}=== ${group_name} ===${NC}"
  echo -e "  ${DIM}Select packages to install (numbers, ranges, or 'all'):${NC}"
  echo

  local pkg_options=()
  local pkg_status=()
  local pkg_names=()
  local pkg
  while IFS= read -r pkg; do
    pkg=$(echo "$pkg" | sed -E 's/^\s+|\s+$//g')
    [ -z "$pkg" ] && continue
    pkg_names+=("$pkg")
    local mapped
    mapped=$(map_name "$pkg")
    if is_installed "$mapped"; then
      pkg_options+=("$pkg [INSTALLED]")
      pkg_status+=("installed")
    else
      pkg_options+=("$pkg [TO INSTALL]")
      pkg_status+=("to_install")
    fi
  done <<< "$group_data"

  if [ "${#pkg_names[@]}" -eq 0 ]; then
    echo "No packages defined for this group."
    return 0
  fi

  local install_all_choice=$(( ${#pkg_options[@]} + 1 ))

  for i in "${!pkg_options[@]}"; do
    if [ "${pkg_status[$i]}" = "installed" ]; then
      printf "  ${GREEN}%3d)${NC} %s\n" "$((i+1))" "${pkg_options[$i]}"
    else
      printf "  ${YELLOW}%3d)${NC} %s\n" "$((i+1))" "${pkg_options[$i]}"
    fi
  done
  printf "  ${CYAN}%3d)${NC} Install ALL packages in this group\n" "$install_all_choice"
  echo -e "  ${DIM}    0) Back${NC}"
  echo

  local selected_packages=()
  local choice
  local invalid=0
  while true; do
    selected_packages=()
    printf "  ${BOLD}Choice (0-%d, 'all', 'back'):${NC} " "$install_all_choice"
    if ! read -r choice; then
      echo
      echo "Input stream ended while selecting packages. Returning to main menu..."
      return 0
    fi
    local choice_trim
    choice_trim="$(echo "$choice" | tr -d '[:space:]')"
    case "${choice_trim,,}" in
      b|back)
        echo "Returning to main menu..."
        return 0
        ;;
      a|all)
        for pending in "${!pkg_status[@]}"; do
          if [ "${pkg_status[$pending]}" = "to_install" ]; then
            selected_packages+=("${pkg_names[$pending]}")
          fi
        done
        if [ ${#selected_packages[@]} -gt 0 ]; then
          echo "Selected all packages that need installation (${#selected_packages[@]} packages)"
        else
          echo "No pending packages in this group."
        fi
        break
        ;;
    esac
    if [[ -z "$choice" ]]; then
      for idx in "${!pkg_status[@]}"; do
        if [ "${pkg_status[$idx]}" = "to_install" ]; then
          selected_packages+=("${pkg_names[$idx]}")
        fi
      done
      if [ ${#selected_packages[@]} -gt 0 ]; then
        echo "Selected all packages that need installation (${#selected_packages[@]} packages)"
      else
        echo "No pending packages in this group."
      fi
      break
    fi

    IFS=',' read -r -a picks <<< "$choice"
    invalid=0
    local -A seen=()
    for pick in "${picks[@]}"; do
      pick=$(echo "$pick" | sed -E 's/^\s+|\s+$//g')
      [ -z "$pick" ] && continue
      if [[ ! "$pick" =~ ^[0-9]+$ ]]; then
        invalid=1
        break
      fi
      if [ "$pick" -eq 0 ]; then
        echo "Returning to main menu..."
        return 0
      fi
      if [ "$pick" -gt "$install_all_choice" ]; then
        invalid=1
        break
      fi
      if [ "$pick" -eq "$install_all_choice" ]; then
        selected_packages=()
        for pending in "${!pkg_status[@]}"; do
          if [ "${pkg_status[$pending]}" = "to_install" ]; then
            selected_packages+=("${pkg_names[$pending]}")
          fi
        done
        echo "Selected all packages that need installation (${#selected_packages[@]} packages)"
        break 2
      fi
      idx=$((pick - 1))
      if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#pkg_options[@]}" ]; then
        invalid=1
        break
      fi
      if [ "${pkg_status[$idx]}" = "installed" ]; then
        echo "Package '${pkg_names[$idx]}' is already installed. Skipping."
      else
        if [[ -z "${seen[$idx]+x}" ]]; then
          seen["$idx"]=1
          selected_packages+=("${pkg_names[$idx]}")
          echo "Selected: ${pkg_names[$idx]}"
        fi
      fi
    done
    if [ "$invalid" -eq 1 ]; then
      echo "Invalid choice: $choice"
      continue
    fi
    if [ "${#selected_packages[@]}" -gt 0 ]; then
      echo "Selected ${#selected_packages[@]} package(s) from ${group_name}"
    fi
    break
  done

  SUBMENU_SELECTIONS=("${selected_packages[@]}")
}

_build_group_counts() {
  local i pkg mapped total installed
  for i in "${!GROUP_ORDER[@]}"; do
    total=0; installed=0
    if [ -n "${GROUP_VALUES[$i]}" ]; then
      while IFS= read -r pkg; do
        pkg=$(echo "$pkg" | sed -E 's/^\s+|\s+$//g')
        [ -z "$pkg" ] && continue
        (( total++ ))
        mapped=$(map_name "$pkg")
        is_installed "$mapped" && (( installed++ )) || true
      done <<< "${GROUP_VALUES[$i]}"
    fi
    GROUP_INSTALLED[i]=$installed
    GROUP_TOTAL[i]=$total
  done
}

_refresh_group_count() {
  local i="$1" pkg mapped total=0 installed=0
  if [ -n "${GROUP_VALUES[$i]}" ]; then
    while IFS= read -r pkg; do
      pkg=$(echo "$pkg" | sed -E 's/^\s+|\s+$//g')
      [ -z "$pkg" ] && continue
      (( total++ ))
      mapped=$(map_name "$pkg")
      is_installed "$mapped" && (( installed++ )) || true
    done <<< "${GROUP_VALUES[$i]}"
  fi
  GROUP_INSTALLED[i]=$installed
  GROUP_TOTAL[i]=$total
}

process_group_selection() {
  local group_idx="$1"
  show_package_submenu "$group_idx"
  if [ ${#SUBMENU_SELECTIONS[@]} -eq 0 ]; then
    return 0
  fi
  install_package_batch "${SUBMENU_SELECTIONS[@]}"
  _refresh_group_count "$group_idx"
  SUBMENU_SELECTIONS=()
}

echo "Package manager: $PM"

if [ "$ASSUME_YES" -eq 1 ]; then
  for i in "${!GROUP_ORDER[@]}"; do
    mapfile -t group_pkgs < <(get_group_packages "$i")
    install_package_batch "${group_pkgs[@]}"
  done
elif [ -n "$SELECT_GROUPS" ]; then
  declare -a SELECTED_GROUP_INDICES=()
  IFS=',' read -r -a requested <<< "$SELECT_GROUPS"
  for requested_name in "${requested[@]}"; do
    name_trim=$(echo "$requested_name" | sed -E 's/^\s+|\s+$//g')
    for i in "${!GROUP_ORDER[@]}"; do
      if [ "${GROUP_ORDER[$i]}" = "$name_trim" ]; then
        SELECTED_GROUP_INDICES+=("$i")
        break
      fi
    done
  done
  if [ ${#SELECTED_GROUP_INDICES[@]} -eq 0 ]; then
    echo "No matching groups for --groups: $SELECT_GROUPS" >&2
    exit 1
  fi
  for idx in "${SELECTED_GROUP_INDICES[@]}"; do
    mapfile -t group_pkgs < <(get_group_packages "$idx")
    install_package_batch "${group_pkgs[@]}"
  done
else
  _build_group_counts
  while true; do
    clear
    echo -e "${BOLD}${BRIGHT_CYAN}  ModularConfig Suite Installer${NC}  ${DIM}[${PM}]${NC}"
    echo
    echo -e "  ${DIM}${CYAN}┌────┬──────────────────────────────┬───────────┬───────────────┐${NC}"
    printf "  ${DIM}${CYAN}│${NC} ${BOLD}%-2s${NC} ${DIM}${CYAN}│${NC} ${BOLD}%-28s${NC} ${DIM}${CYAN}│${NC} ${BOLD}%-9s${NC} ${DIM}${CYAN}│${NC} ${BOLD}%-13s${NC} ${DIM}${CYAN}│${NC}\n" \
      "ID" "Group" "Installed" "Not Installed"
    echo -e "  ${DIM}${CYAN}├────┼──────────────────────────────┼───────────┼───────────────┤${NC}"

    actions=()
    for idx in "${ORDERED_GROUP_INDICES[@]}"; do
      g="${GROUP_ORDER[$idx]}"
      installed=${GROUP_INSTALLED[$idx]:-0}
      total=${GROUP_TOTAL[$idx]:-0}
      pending=$(( total - installed ))

      if (( total == 0 )); then
        pending_str="  -"
        pending_color="${DIM}"
      elif (( pending == 0 )); then
        pending_str="  done"
        pending_color="${GREEN}"
      else
        pending_str="$pending"
        pending_color="${YELLOW}"
      fi

      actions+=("group:$idx")
      num=${#actions[@]}
      printf "  ${DIM}${CYAN}│${NC} %2d ${DIM}${CYAN}│${NC} %-28s ${DIM}${CYAN}│${NC} ${GREEN}%9d${NC} ${DIM}${CYAN}│${NC} ${pending_color}%13s${NC} ${DIM}${CYAN}│${NC}\n" \
        "$num" "$g" "$installed" "$pending_str"
    done

    echo -e "  ${DIM}${CYAN}├────┴──────────────────────────────┴───────────┴───────────────┤${NC}"
    printf "  ${DIM}${CYAN}│${NC} ${DIM}%-62s${NC}${DIM}${CYAN}│${NC}\n" "  Setup & Configuration"
    echo -e "  ${DIM}${CYAN}├────┬──────────────────────────────┬───────────┬───────────────┤${NC}"

    for mi in "${!MODULE_NAMES[@]}"; do
      actions+=("module:$mi")
      num=${#actions[@]}
      printf "  ${DIM}${CYAN}│${NC} %2d ${DIM}${CYAN}│${NC} %-28s ${DIM}${CYAN}│${NC} ${DIM}%9s${NC} ${DIM}${CYAN}│${NC} ${DIM}%13s${NC} ${DIM}${CYAN}│${NC}\n" \
        "$num" "${MODULE_NAMES[$mi]}" "─" "─"
    done

    all_idx=$(( ${#actions[@]} + 1 ))
    actions+=("all")

    echo -e "  ${DIM}${CYAN}├────┴──────────────────────────────┴───────────┴───────────────┤${NC}"
    printf "  ${DIM}${CYAN}│${NC}  %-2s  %-57s${DIM}${CYAN}│${NC}\n" "0" "Exit installer"
    printf "  ${DIM}${CYAN}│${NC} %-3s  %-57s${DIM}${CYAN}│${NC}\n" "$all_idx" "Install all groups and run setup"
    echo -e "  ${DIM}${CYAN}└───────────────────────────────────────────────────────────────┘${NC}"
    echo
    printf "  ${BOLD}Choice [0-%-s]:${NC} " "$all_idx"

    if ! read -r main_choice; then
      echo
      log "Input stream ended; exiting menu."
      break
    fi
    main_choice_trim="$(echo "$main_choice" | tr -d '[:space:]')"
    if [[ -z "$main_choice_trim" ]]; then
      continue
    fi
    case "${main_choice_trim,,}" in
      q|quit|exit)
        echo "Exiting installer..."
        break
        ;;
    esac
    if [[ ! "$main_choice_trim" =~ ^[0-9]+$ ]]; then
      echo -e "  ${RED}Invalid input: $main_choice${NC}"
      sleep 1
      continue
    fi
    if [ "$main_choice_trim" -eq 0 ]; then
      echo "Exiting installer..."
      break
    fi
    sel_index=$((main_choice_trim - 1))
    if [ "$sel_index" -lt 0 ] || [ "$sel_index" -ge "${#actions[@]}" ]; then
      echo -e "  ${RED}Choice out of range: $main_choice${NC}"
      sleep 1
      continue
    fi
    action="${actions[$sel_index]}"
    case "$action" in
      group:*)
        process_group_selection "${action#group:}"
        ;;
      module:*)
        mi="${action#module:}"
        "${MODULE_FUNCS[$mi]}"
        ;;
      all)
        for j in "${!GROUP_ORDER[@]}"; do
          mapfile -t _all_pkgs < <(get_group_packages "$j")
          install_package_batch "${_all_pkgs[@]}"
          _refresh_group_count "$j"
        done
        for mi in "${!MODULE_FUNCS[@]}"; do
          "${MODULE_FUNCS[$mi]}"
        done
        break
        ;;
    esac
  done
fi

log "Install step completed (dry-run=$DRY_RUN)"

print_install_summary
