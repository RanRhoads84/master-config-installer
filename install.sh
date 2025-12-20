#!/usr/bin/env bash

# Simplified installer (neovim and rofi removed)
set -euo pipefail
IFS=$'\n\t'

LOGFILE="./butter-install.log"
DRY_RUN=0
ASSUME_YES=0
SELECT_GROUPS=""
PM_INSTALL_CMD=""
CONSOLIDATED_FILE="packages/consolidated.txt"
declare -a ORDERED_GROUP_INDICES=()

usage() {
  cat <<EOF
Usage: $0 [--dry-run] [--yes] [--log <file>] [--groups <list>]

Options:
  --dry-run        Print commands that would be run (no changes)
  --yes, -y        Assume yes to prompts
  --log <file>     Path to log file (default: ./butter-install.log)
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

PM=$(detect_pm)
if [ "$PM" = "unknown" ]; then
  log "Detected package manager: unknown"
  PM_INSTALL_CMD=""
else
  log "Detected package manager: $PM"
  set_pm_install_cmd "$PM"
fi

if [ ! -f "$CONSOLIDATED_FILE" ]; then
  echo "Package list file not found: $CONSOLIDATED_FILE" >&2
  exit 3
fi

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
    GROUP_VALUES[$current_group_index]="$line_trim"
  else
    GROUP_VALUES[$current_group_index]+=$'\n'$line_trim
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
  log "Installing ${#to_install[@]} packages for $PM"
  run_cmd "$PM_INSTALL_CMD ${to_install[*]}"
}

show_package_submenu() {
  local group_idx="$1"
  local group_name="${GROUP_ORDER[$group_idx]}"
  local group_data="${GROUP_VALUES[$group_idx]}"

  echo
  echo "=== $group_name ==="
  echo "Select individual packages to install:"
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

  pkg_options+=("Install ALL packages in this group")
  pkg_options+=("Back to main menu")
  local all_index=$(( ${#pkg_options[@]} - 2 ))
  local back_index=$(( ${#pkg_options[@]} - 1 ))

  for i in "${!pkg_options[@]}"; do
    echo "$((i+1))) ${pkg_options[$i]}"
  done
  echo

  local selected_packages=()
  local choice
  local invalid=0
  while true; do
    echo -n "Enter choice(s) (1-${#pkg_options[@]}), separated by commas, or press Enter to install all pending packages: "
    if ! read -r choice; then
      echo
      echo "Input stream ended while selecting packages. Returning to main menu..."
      return 0
    fi
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
    for pick in "${picks[@]}"; do
      pick=$(echo "$pick" | sed -E 's/^\s+|\s+$//g')
      if [[ ! "$pick" =~ ^[0-9]+$ ]]; then
        invalid=1
        break
      fi
      idx=$((pick - 1))
      if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#pkg_options[@]}" ]; then
        invalid=1
        break
      fi
      if [ "$idx" -eq "$all_index" ]; then
        selected_packages=()
        for pending in "${!pkg_status[@]}"; do
          if [ "${pkg_status[$pending]}" = "to_install" ]; then
            selected_packages+=("${pkg_names[$pending]}")
          fi
        done
        echo "Selected all packages that need installation (${#selected_packages[@]} packages)"
        break 2
      elif [ "$idx" -eq "$back_index" ]; then
        echo "Returning to main menu..."
        return 0
      else
        if [ "${pkg_status[$idx]}" = "installed" ]; then
          echo "Package '${pkg_names[$idx]}' is already installed. Skipping."
        else
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

process_group_selection() {
  local group_idx="$1"
  show_package_submenu "$group_idx"
  if [ ${#SUBMENU_SELECTIONS[@]} -eq 0 ]; then
    return 0
  fi
  install_package_batch "${SUBMENU_SELECTIONS[@]}"
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
  while true; do
    echo
    echo "+-------------------------------------------------------------+"
    echo "|                   Package group overview                    |"
    echo "+----+-------------------------------+-----------+------------+"
    printf "| %2s | %-29s | %9s | %10s |\n" "ID" "Group" "Installed" "Installed"
    echo "+----+-------------------------------+-----------+------------+"

    actions=()
    for idx in "${ORDERED_GROUP_INDICES[@]}"; do
      g="${GROUP_ORDER[$idx]}"
      total_count=0
      installed_count=0
      if [ -n "${GROUP_VALUES[$idx]}" ]; then
        while IFS= read -r pkg; do
          pkg=$(echo "$pkg" | sed -E 's/^\s+|\s+$//g')
          [ -z "$pkg" ] && continue
          total_count=$((total_count + 1))
          mapped_pkg=$(map_name "$pkg")
          if is_installed "$mapped_pkg"; then
            installed_count=$((installed_count + 1))
          fi
        done <<< "${GROUP_VALUES[$idx]}"
      fi
      to_install=$((total_count - installed_count))
      actions+=("group:$idx")
      printf "| %2d | %-29s | %9d | %10d |\n" "$(( ${#actions[@]} ))" "$g" "$installed_count" "$to_install"
    done
    echo "+----+-------------------------------+-----------+------------+"

    all_idx=$(( ${#actions[@]} + 1 ))
    done_idx=$(( all_idx + 1 ))
    actions+=("all")
    actions+=("done")

    printf " %2d) %-56s\n" "$all_idx" "Install every group sequentially"
    printf " %2d) %-56s\n" "$done_idx" "Done (exit installer)"
    echo
    echo "Select a number to open that group's submenu; runs install immediately and returns here."
    echo -n "Enter your choice (1-${#actions[@]}): "
    if ! read -r main_choice; then
      echo
      log "Input stream ended; exiting menu."
      break
    fi
    if [[ -z "$main_choice" ]]; then
      echo "Please select an option."
      continue
    fi
    if [[ ! "$main_choice" =~ ^[0-9]+$ ]]; then
      echo "Invalid input: $main_choice"
      continue
    fi
    sel_index=$((main_choice - 1))
    if [ "$sel_index" -lt 0 ] || [ "$sel_index" -ge "${#actions[@]}" ]; then
      echo "Choice out of range: $main_choice"
      continue
    fi
    action="${actions[$sel_index]}"
    case "$action" in
      group:*)
        process_group_selection "${action#group:}"
        ;;
      all)
        for j in "${!GROUP_ORDER[@]}"; do
          process_group_selection "$j"
        done
        ;;
      done)
        break
        ;;
    esac
  done
fi

do_npm() {
  npm_file="packages/npm.txt"
  [ -f "$npm_file" ] || return
  mapfile -t npm_pkgs < <(grep -E -v '^\s*#' "$npm_file" | sed '/^$/d')
  [ ${#npm_pkgs[@]} -eq 0 ] && return
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

do_cargo() {
  cargo_file="packages/cargo.txt"
  [ -f "$cargo_file" ] || return
  mapfile -t cargo_pkgs < <(grep -E -v '^\s*#' "$cargo_file" | sed '/^$/d')
  [ ${#cargo_pkgs[@]} -eq 0 ] && return
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

do_npm

do_cargo

do_vim_config() {
  vim_config_dir="vim-config"
  [ -d "$vim_config_dir" ] || return
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
  fi
}

do_vim_config

log "Install step completed (dry-run=$DRY_RUN)"

echo "Done. Review $LOGFILE for details."
