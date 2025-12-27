#!/usr/bin/env bash
# lis/menu.bash - reusable menu helpers (caller provides menu items)

# Colors
source libs/text_mods.bash || {
  echo "ERROR: failed to source colors.bash" >&2
  exit 2
}

: "${MENU_NO_CLEAR:=0}"

_menu_clear() {
  if [ "${MENU_NO_CLEAR:-0}" -eq 0 ]; then
    clear
  fi
}

# Output:
#   MENU_SELECTED_INDICES (global array of 1-based indices)
# Return:
#   0 if selection made
#   1 if Exit chosen
menu_select_multi() {
  local title="$1"
  local prompt="$2"
  local items_ref="$3"
  local meta_ref="${4:-}"

  local -n _items="$items_ref"
  local n="${#_items[@]}"

  MENU_SELECTED_INDICES=()

  if (( n == 0 )); then
    echo "menu_select_multi: no items provided" >&2
    return 1
  fi

  local have_meta=0
  if [[ -n "$meta_ref" ]]; then
    have_meta=1
    local -n _meta="$meta_ref"
  fi

  local all_idx=$((n + 1))
  local exit_idx=$((n + 2))

  while true; do
    _menu_clear

    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}  ${title}${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${YELLOW}${prompt}${NC}"

    local i line
    for (( i=1; i<=n; i++ )); do
      line="${_items[$((i-1))]}"
      if (( have_meta == 1 )) && [[ -n "${_meta[$((i-1))]:-}" ]]; then
        line+="  ${_meta[$((i-1))]}"
      fi
      echo -e "${CYAN}${i}. ${NC}${line}"
    done

    echo -e "${CYAN}${all_idx}. ${NC}All"
    echo -e "${CYAN}${exit_idx}. ${NC}Exit"
    echo -e "${CYAN}=========================================================${NC}"

    local input tok
    read -r -p "> " input || return 1
    [[ -z "${input//[[:space:]]/}" ]] && continue

    local -a picks=()
    for tok in $input; do
      [[ "$tok" =~ ^[0-9]+$ ]] || { picks=(); break; }
      picks+=("$tok")
    done
    (( ${#picks[@]} == 0 )) && continue

    for tok in "${picks[@]}"; do
      if (( tok == exit_idx )); then
        MENU_SELECTED_INDICES=()
        return 1
      fi
    done

    for tok in "${picks[@]}"; do
      if (( tok == all_idx )); then
        MENU_SELECTED_INDICES=()
        for (( i=1; i<=n; i++ )); do
          MENU_SELECTED_INDICES+=("$i")
        done
        return 0
      fi
    done

    local -A seen=()
    MENU_SELECTED_INDICES=()
    for tok in "${picks[@]}"; do
      if (( tok < 1 || tok > n )); then
        MENU_SELECTED_INDICES=()
        break
      fi
      if [[ -z "${seen[$tok]+x}" ]]; then
        seen["$tok"]=1
        MENU_SELECTED_INDICES+=("$tok")
      fi
    done

    (( ${#MENU_SELECTED_INDICES[@]} > 0 )) && return 0
  done
}