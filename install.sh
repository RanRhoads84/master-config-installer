#!/usr/bin/env bash

# Simplified installer (neovim and rofi removed)
set -euo pipefail
IFS=$'\n\t'

LOGFILE="./butter-install.log"
DRY_RUN=0
ASSUME_YES=0
SELECT_GROUPS=""

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

# Parse command-line flags
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
  msg="$1"
  printf "%s %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$msg" | tee -a "$LOGFILE"
}

run_cmd() {
  cmd="$*"
  log "RUN: $cmd"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "DRY-RUN: $cmd"
    return 0
  fi
  bash -c "$cmd"
}

safe_run() {
  cmd="$*"
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

# Detect package manager
PM=$(detect_pm)
if [ "$PM" = "unknown" ]; then
  log "Detected package manager: unknown"
  PM_INSTALL_CMD=""
else
  log "Detected package manager: $PM"
  set_pm_install_cmd "$PM"
fi

# Load package groups from packages/<pm>.txt
PKG_FILE="packages/${PM}.txt"
if [ ! -f "$PKG_FILE" ]; then
  echo "Package list file not found: $PKG_FILE" >&2
  exit 3
fi

declare -a GROUP_ORDER
declare -a GROUP_VALUES
current_group_index=0
GROUP_ORDER+=("default")
GROUP_VALUES+=("")
while IFS= read -r line || [ -n "$line" ]; do
  line_trim=$(echo "$line" | sed -E 's/^\s+//;s/\s+$//')
  if [[ "$line_trim" =~ ^# ]]; then
    header=$(echo "$line_trim" | sed -E 's/^#\s*//')
    if [ -n "$header" ]; then
      current_group_index=${#GROUP_ORDER[@]}
      GROUP_ORDER+=("$header")
      GROUP_VALUES+=("")
    fi
  else
    if [ -z "$line_trim" ]; then
      continue
    fi
    if [[ "$line_trim" =~ ^# ]]; then
      continue
    fi
    if [ -z "${GROUP_VALUES[$current_group_index]}" ]; then
      GROUP_VALUES[$current_group_index]="$line_trim"
    else
      GROUP_VALUES[$current_group_index]+=$'\n'$line_trim
    fi
  fi
done < "$PKG_FILE"

# Present groups and let user choose
echo "Package manager: $PM"
echo "Found groups:"
idx=1
declare -A IDX_TO_GROUP
for i in "${!GROUP_ORDER[@]}"; do
  g=${GROUP_ORDER[$i]}
  count=0
  if [ -n "${GROUP_VALUES[$i]}" ]; then
    count=$(echo -n "${GROUP_VALUES[$i]}" | grep -c '^' || true)
  fi
  printf "%3d) %s (%d packages)\n" "$idx" "$g" "$count"
  IDX_TO_GROUP[$idx]="$i"
  idx=$((idx+1))
done

echo
if [ -n "$SELECT_GROUPS" ]; then
  IFS=',' read -r -a parts <<< "$SELECT_GROUPS"
  selected_idxs=()
  for name in "${parts[@]}"; do
    name_trim=$(echo "$name" | sed -E 's/^\s+|\s+$//g')
    for i in "${!GROUP_ORDER[@]}"; do
      if [ "${GROUP_ORDER[$i]}" = "$name_trim" ]; then
        selected_idxs+=("$((i+1))")
      fi
    done
  done
else
  if [ "$ASSUME_YES" -eq 1 ]; then
    selection=all
  else
    read -r -p "Enter group numbers to install (comma-separated), or 'all' to select all: " selection || true
    selection=${selection:-all}
  fi
  if [ "$selection" = "all" ]; then
    selected_idxs=($(seq 1 $((idx-1))))
  else
    IFS=',' read -r -a parts <<< "$selection"
    selected_idxs=()
    for p in "${parts[@]}"; do
      p_trim=$(echo "$p" | sed -E 's/^\s+|\s+$//g')
      if [[ "$p_trim" =~ ^[0-9]+$ ]]; then
        selected_idxs+=("$p_trim")
      fi
    done
  fi
fi

PACKAGES_SELECTED=()
for si in "${selected_idxs[@]}"; do
  gi=${IDX_TO_GROUP[$si]}
  if [ -n "$gi" ]; then
    while IFS= read -r pkg; do
      pkg=$(echo "$pkg" | sed -E 's/^\s+|\s+$//g')
      [ -z "$pkg" ] && continue
      PACKAGES_SELECTED+=("$pkg")
    done <<< "${GROUP_VALUES[$gi]}"
  fi
done

if [ ${#PACKAGES_SELECTED[@]} -eq 0 ]; then
  echo "No packages selected. Exiting."; exit 0
fi

map_name() {
  local name="$1"
  case "$PM" in
    apt)
      if [ "$name" = "fd" ]; then echo "fd-find"; return; fi
      ;;
    pacman|dnf|zypper)
      if [ "$name" = "fd-find" ]; then echo "fd"; return; fi
      ;;
  esac
  echo "$name"
}

PACKAGES_MAPPED=()
for p in "${PACKAGES_SELECTED[@]}"; do
  PACKAGES_MAPPED+=("$(map_name "$p")")
done

to_install=()

is_installed() {
  local pkg="$1"
  case "$PM" in
    apt) dpkg -s "$pkg" >/dev/null 2>&1 && return 0 || true ;; 
    pacman) pacman -Qi "$pkg" >/dev/null 2>&1 && return 0 || true ;; 
    dnf|zypper) rpm -q "$pkg" >/dev/null 2>&1 && return 0 || true ;; 
  esac
  if command -v "$pkg" >/dev/null 2>&1; then return 0; fi
  return 1
}

for p in "${PACKAGES_MAPPED[@]}"; do
  if is_installed "$p"; then
    log "Skipping installed package: $p"
  else
    to_install+=("$p")
  fi
done

TOTAL=${#to_install[@]}
log "Will install $TOTAL packages for $PM"
if [ "$TOTAL" -eq 0 ]; then
  echo "All selected packages appear to be installed. Nothing to do."; exit 0
fi

if [ "$ASSUME_YES" -eq 0 ]; then
  read -r -p "Proceed to install selected packages? [Y/n]: " resp || true
  resp=${resp:-y}
  if [[ ! "$resp" =~ ^[Yy] ]]; then
    echo "Aborting."; exit 0
  fi
fi

do_apt() {
  run_cmd "sudo apt update"
  run_cmd "sudo apt install -y ${to_install[*]}"
}

do_dnf() { run_cmd "sudo dnf install -y ${to_install[*]}"; }

do_pacman() { run_cmd "sudo pacman -Syu --noconfirm ${to_install[*]}"; }

do_zypper() { run_cmd "sudo zypper install -y ${to_install[*]}"; }

case "$PM" in
  apt) do_apt ;; dnf) do_dnf ;; pacman) do_pacman ;; zypper) do_zypper ;; *) echo "No driver for $PM"; exit 4 ;;
esac

# NPM and Cargo optional installs

do_npm() {
  npm_file="packages/npm.txt"
  [ -f "$npm_file" ] || return
  mapfile -t npm_pkgs < <(grep -E -v '^\s*#' "$npm_file" | sed '/^$/d')
  [ ${#npm_pkgs[@]} -eq 0 ] && return
  if [ "$ASSUME_YES" -eq 1 ]; then ans=y; else read -r -p "Install npm global packages? (${#npm_pkgs[@]}) [Y/n] " ans || true; ans=${ans:-y}; fi
  if [[ "$ans" =~ ^[Yy] ]]; then for p in "${npm_pkgs[@]}"; do run_cmd "npm install -g $p"; done; fi
}


do_cargo() {
  cargo_file="packages/cargo.txt"
  [ -f "$cargo_file" ] || return
  mapfile -t cargo_pkgs < <(grep -E -v '^\s*#' "$cargo_file" | sed '/^$/d')
  [ ${#cargo_pkgs[@]} -eq 0 ] && return
  if [ "$ASSUME_YES" -eq 1 ]; then ans=y; else read -r -p "Install cargo packages? (${#cargo_pkgs[@]}) [Y/n] " ans || true; ans=${ans:-y}; fi
  if [[ "$ans" =~ ^[Yy] ]]; then for p in "${cargo_pkgs[@]}"; do run_cmd "cargo install $p || true"; done; fi
}


do_npm

do_cargo

log "Install step completed (dry-run=$DRY_RUN)"

echo "Done. Review $LOGFILE for details."
