#!/usr/bin/env bash
# demo_menu.sh - demo script for menu.bash
set -euo pipefail
IFS=$'\n\t'

# Colors (optional)
source lib/text_mods.bash || {
  echo "ERROR: failed to source colors.bash" >&2
  exit 2
}

# Don’t clear screen in demo runs
MENU_NO_CLEAR=1

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
menu_lib="$script_dir/lib/menu.bash"

# Load menu.bash library from script-location/lib/, exit if not found with error.
if [[ ! -f "$menu_lib" ]]; then
  echo "ERROR: required library not found: $menu_lib" >&2
  echo "Expected layout (packaged together):" >&2
  echo "  $script_dir/demo_menu.sh" >&2
  echo "  $script_dir/lib/menu.bash" >&2
  exit 2
fi

# shellcheck source=/dev/null
source "$menu_lib" || {
  echo "ERROR: failed to source: $menu_lib" >&2
  exit 2
}

menu_items=()
menu_meta=()
installer_paths=()

browsers_dir="$script_dir/browsers"

# Example: “whatever the calling script is doing” == discovering installers
while IFS= read -r -d '' f; do
  installer_paths+=("$f")
  menu_items+=("$(basename "$f")")
  menu_meta+=("[path: ${f#"$script_dir"/}]")
done < <(find "$browsers_dir" -maxdepth 1 -type f -name '*.sh' -print0 2>/dev/null || true)

if ((${#menu_items[@]} == 0)); then
  echo "No installers found under $browsers_dir"
  exit 0
fi

title="Discovered installers for $(basename "$0")"
prompt="Select installers to run (space-separated): "

if menu_select_multi "$title" "$prompt" menu_items menu_meta; then
  echo "Selected indices: ${MENU_SELECTED_INDICES[*]}"
  for sel in "${MENU_SELECTED_INDICES[@]}"; do
    idx=$((sel - 1))
    echo "Would run: ${installer_paths[$idx]}"
    # Example dispatch:
    # bash "${installer_paths[$idx]}"
  done
else
  echo "Exit selected"
fi