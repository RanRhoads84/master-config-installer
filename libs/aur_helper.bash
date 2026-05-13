#!/usr/bin/env bash
# libs/aur_helper.bash — shared AUR helper detection for pacman-based systems.
#
# Sourceable by any installer script. Exports:
#   detect_aur_helper       — echoes helper name (yay/paru/$AUR_HELPER) or returns 1
#   apply_aur_helper <pm>   — if pm=pacman and USE_AUR=1, populates AUR_HELPER and
#                             rewrites PM_INSTALL_CMD to use the helper.
#
# Inputs (env):
#   AUR_HELPER  — force a specific helper binary (e.g., paru). Empty = auto.
#   USE_AUR     — set to 0 to disable AUR integration entirely (default 1).
#
# Outputs (env, after apply_aur_helper):
#   AUR_HELPER       — resolved helper name, or empty if none/disabled.
#   PM_INSTALL_CMD   — rewritten when a helper is active.

# Snapshot any caller-provided override before we clobber AUR_HELPER below.
: "${AUR_HELPER_OVERRIDE:=${AUR_HELPER:-}}"
: "${USE_AUR:=1}"

detect_aur_helper() {
  if [ -n "${AUR_HELPER_OVERRIDE:-}" ]; then
    if command -v "$AUR_HELPER_OVERRIDE" >/dev/null 2>&1; then
      echo "$AUR_HELPER_OVERRIDE"
      return 0
    fi
    return 1
  fi
  if command -v yay  >/dev/null 2>&1; then echo yay;  return 0; fi
  if command -v paru >/dev/null 2>&1; then echo paru; return 0; fi
  return 1
}

apply_aur_helper() {
  local pm="$1"
  AUR_HELPER=""
  if [ "$pm" != "pacman" ] || [ "${USE_AUR:-1}" -ne 1 ]; then
    return 0
  fi
  if AUR_HELPER=$(detect_aur_helper); then
    # AUR helpers wrap pacman and pull from official repos + AUR. They manage
    # privilege escalation internally and refuse to run as root, so omit sudo.
    # shellcheck disable=SC2034  # PM_INSTALL_CMD is consumed by callers.
    PM_INSTALL_CMD="$AUR_HELPER -S --needed --noconfirm"
    return 0
  fi
  AUR_HELPER=""
  return 1
}
