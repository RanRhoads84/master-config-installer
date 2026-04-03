#!/usr/bin/env bash
# functions/summary.sh — install summary tracker and renderer
# Source this early in install.sh; call _summary_record from each function,
# then call print_install_summary at the end.

declare -a _SUMMARY_ITEMS=()

# Package install counters — incremented directly by install_package_batch
declare -i _PKG_INSTALLED=0
declare -i _PKG_ALREADY_INSTALLED=0
declare -i _PKG_UNAVAILABLE=0
declare -i _PKG_FAILED=0
declare -a _PKG_UNAVAILABLE_NAMES=()

# _summary_record <label> <status> [detail]
#   status: installed | skipped | already_installed | failed
_summary_record() {
    local label="$1"
    local status="$2"
    local detail="${3:-}"
    _SUMMARY_ITEMS+=("${label}|${status}|${detail}")
}

print_install_summary() {
    # Load colors if not already sourced
    if [[ -z "${BOLD:-}" ]]; then
        local _script_dir
        _script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        # shellcheck source=../libs/text_mods.bash
        source "$_script_dir/../libs/text_mods.bash"
    fi

    local WIDTH=62
    local INNER=$((WIDTH - 2))

    local C_BORDER="${BRIGHT_CYAN}"
    local C_TITLE="${BOLD}${BRIGHT_WHITE}"
    local C_OK="${BRIGHT_GREEN}"
    local C_SKIP="${DIM}${WHITE}"
    local C_ALREADY="${CYAN}"
    local C_FAIL="${BRIGHT_RED}"
    local C_LABEL="${WHITE}"
    local C_DETAIL="${DIM}${BRIGHT_WHITE}"
    local C_LOG="${DIM}${CYAN}"
    local R="${NC}"

    _box_top()    { printf "${C_BORDER}╔%s╗${R}\n" "$(printf '═%.0s' $(seq 1 $INNER))"; }
    _box_mid()    { printf "${C_BORDER}╠%s╣${R}\n" "$(printf '═%.0s' $(seq 1 $INNER))"; }
    _box_bot()    { printf "${C_BORDER}╚%s╝${R}\n" "$(printf '═%.0s' $(seq 1 $INNER))"; }
    _box_row() {
        local content="$1"
        # Strip ANSI for length calculation
        local plain
        plain=$(printf '%b' "$content" | sed 's/\x1b\[[0-9;]*m//g')
        local pad=$(( INNER - ${#plain} - 2 ))
        [[ $pad -lt 0 ]] && pad=0
        printf "${C_BORDER}║${R} %b%*s ${C_BORDER}║${R}\n" "$content" "$pad" ""
    }
    _box_blank()  { _box_row ""; }

    local total=0 installed=0 skipped=0 failed=0

    echo
    _box_top
    _box_row "$(printf "${C_TITLE}%-${INNER}s" "  ModularConfig Suite — Install Summary")"
    _box_mid
    _box_blank

    for item in "${_SUMMARY_ITEMS[@]}"; do
        IFS='|' read -r label status detail <<< "$item"
        total=$(( total + 1 ))

        local icon color
        case "$status" in
            installed)
                icon="✔"; color="$C_OK"; installed=$(( installed + 1 )) ;;
            already_installed)
                icon="✔"; color="$C_ALREADY"; installed=$(( installed + 1 )) ;;
            skipped)
                icon="—"; color="$C_SKIP"; skipped=$(( skipped + 1 )) ;;
            failed)
                icon="✘"; color="$C_FAIL"; failed=$(( failed + 1 )) ;;
            *)
                icon="?"; color="$C_SKIP" ;;
        esac

        local status_word
        case "$status" in
            installed)         status_word="Installed" ;;
            already_installed) status_word="Already installed" ;;
            skipped)           status_word="Skipped" ;;
            failed)            status_word="Failed" ;;
            *)                 status_word="$status" ;;
        esac

        local right_col="${color}${icon}  ${status_word}${R}"
        [[ -n "$detail" ]] && right_col+="${C_DETAIL} (${detail})${R}"

        local left="${C_LABEL}${label}${R}"
        local left_plain="$label"
        local right_plain
        right_plain=$(printf '%b' "$right_col" | sed 's/\x1b\[[0-9;]*m//g')

        local gap=$(( INNER - ${#left_plain} - ${#right_plain} - 2 ))
        [[ $gap -lt 1 ]] && gap=1
        local spacer
        spacer=$(printf '%*s' "$gap" "")

        _box_row "${left}${spacer}${right_col}"
    done

    # Packages aggregate row
    if (( _PKG_INSTALLED + _PKG_ALREADY_INSTALLED + _PKG_FAILED > 0 )); then
        local pkg_right="${C_OK}✔  ${_PKG_INSTALLED} installed${R}"
        (( _PKG_ALREADY_INSTALLED > 0 )) && pkg_right+="${C_ALREADY}  (${_PKG_ALREADY_INSTALLED} already installed)${R}"
        (( _PKG_FAILED > 0 )) && pkg_right+="  ${C_FAIL}${_PKG_FAILED} failed${R}"
        local pkg_right_plain
        pkg_right_plain=$(printf '%b' "$pkg_right" | sed 's/\x1b\[[0-9;]*m//g')
        local pkg_label="Packages"
        local pkg_gap=$(( INNER - ${#pkg_label} - ${#pkg_right_plain} - 2 ))
        [[ $pkg_gap -lt 1 ]] && pkg_gap=1
        _box_row "${C_LABEL}${pkg_label}${R}$(printf '%*s' "$pkg_gap" "")${pkg_right}"
    fi

    _box_blank
    _box_mid

    # Totals line
    local grand_installed=$(( installed + _PKG_INSTALLED + _PKG_ALREADY_INSTALLED ))
    local grand_failed=$(( failed + _PKG_FAILED ))
    local totals_str
    totals_str=$(printf "${C_OK}%d installed${R}  ${C_SKIP}%d skipped${R}" "$grand_installed" "$skipped")
    [[ $grand_failed -gt 0 ]] && totals_str+="  $(printf "${C_FAIL}%d failed${R}" "$grand_failed")"
    [[ $_PKG_UNAVAILABLE -gt 0 ]] && totals_str+="  $(printf "${C_SKIP}%d unavailable${R}" "$_PKG_UNAVAILABLE")"
    _box_row "  $totals_str"

    _box_blank

    # Log file line
    local logfile="${LOGFILE:-./modularconfig-install.log}"
    _box_row "  ${C_LOG}Log: ${logfile}${R}"

    _box_bot
    echo

    if (( _PKG_UNAVAILABLE > 0 )); then
        printf "  ${C_SKIP}%d packages were not available in repos. Show list? [y/N]:${R} " "$_PKG_UNAVAILABLE"
        local ans
        read -r ans
        if [[ "${ans,,}" == "y" ]]; then
            echo
            for pkg in "${_PKG_UNAVAILABLE_NAMES[@]}"; do
                printf "  ${C_FAIL}✘${R}  %s\n" "$pkg"
            done
            echo
        fi
    fi
}
