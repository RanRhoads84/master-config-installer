#!/usr/bin/env bash
# Provides: als — alias picker/search; shelp — full shell help browser

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

# _help_colors: set color vars in the caller's scope (empty when NO_COLOR set)
_help_colors() {
    if [[ -n "${NO_COLOR:-}" ]]; then
        BOLD=''; CYAN=''; GREEN=''; DIM=''; RESET=''
    else
        BOLD='\033[1m'; CYAN='\033[1;36m'; GREEN='\033[0;32m'; DIM='\033[2m'; RESET='\033[0m'
    fi
}

# _help_strip_quotes: strip one layer of matching outer ' or " from a string
_help_strip_quotes() {
    local val="$1"
    case "$val" in
        \'*\') val="${val#\'}"; val="${val%\'}" ;;
        \"*\") val="${val#\"}"; val="${val%\"}" ;;
    esac
    printf '%s' "$val"
}

# _help_parse_aliases_file: parse aliases.bash, printing each alias entry.
# Args: $1 = config dir, $2 = filter term (empty = print all with section headers)
# When term is empty:  prints section headers (cyan) + indented alias lines
# When term is given:  prints only matching lines prefixed with dim [SECTION]
_help_parse_aliases_file() {
    local config_dir="$1"
    local term="$2"
    local aliases_file="${config_dir}/aliases.bash"
    local BOLD CYAN GREEN DIM RESET
    _help_colors

    [[ -f "$aliases_file" ]] || return 0

    local current_section='' line name raw_val val

    while IFS= read -r line; do
        # Skip separator lines (====…)
        if [[ "$line" =~ ^#[[:space:]]+={10,}[[:space:]]*$ ]]; then
            continue
        fi

        # Section header
        if [[ "$line" =~ ^#[[:space:]]+([A-Z][A-Z\ ]+)[[:space:]]*$ ]]; then
            current_section="${BASH_REMATCH[1]}"
            current_section="${current_section%"${current_section##*[! ]}"}"  # rtrim
            if [[ -z "$term" ]]; then
                printf "${CYAN}── %s ──${RESET}\n" "$current_section"
            fi
            continue
        fi

        # Alias line
        if [[ "$line" =~ ^[[:space:]]*alias[[:space:]]+([^=]+)=(.+)$ ]]; then
            name="${BASH_REMATCH[1]}"
            raw_val="${BASH_REMATCH[2]}"
            val="$(_help_strip_quotes "$raw_val")"

            if [[ -z "$term" ]]; then
                printf "  ${GREEN}%-20s${RESET} %s\n" "$name" "$val"
            else
                if printf '%s %s' "$name" "$val" | grep -qi -- "$term" 2>/dev/null; then
                    printf "${DIM}[%s]${RESET} ${GREEN}%-20s${RESET} %s\n" \
                        "${current_section:-unknown}" "$name" "$val"
                fi
            fi
            continue
        fi

        # Skip blank lines and other comment lines
    done < "$aliases_file"
}

# _help_scan_functions: scan functions/*.bash, printing function names.
# Args: $1 = config dir, $2 = filter term (empty = print all with file subheaders)
# When term is empty:  prints per-file subheader (cyan) + function names (green)
# When term is given:  prints only matching names prefixed with dim [filename]
_help_scan_functions() {
    local config_dir="$1"
    local term="$2"
    local func_dir="${config_dir}/functions"
    local BOLD CYAN GREEN DIM RESET
    _help_colors

    local f basename fname

    for f in "${func_dir}"/*.bash; do
        [[ -f "$f" ]] || continue
        basename="${f##*/}"
        basename="${basename%.bash}"

        if [[ -z "$term" ]]; then
            printf "${CYAN}  [%s]${RESET}\n" "$basename"
            while IFS= read -r line; do
                if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*)\(\) ]]; then
                    fname="${BASH_REMATCH[1]}"
                    printf "    ${GREEN}%s${RESET}\n" "$fname"
                fi
            done < "$f"
        else
            while IFS= read -r line; do
                if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_-]*)\(\) ]]; then
                    fname="${BASH_REMATCH[1]}"
                    if printf '%s' "$fname" | grep -qi -- "$term" 2>/dev/null; then
                        printf "${DIM}[%s]${RESET} ${GREEN}%s${RESET}\n" "$basename" "$fname"
                    fi
                fi
            done < "$f"
        fi
    done
}

# ---------------------------------------------------------------------------
# als — alias picker / search
# ---------------------------------------------------------------------------

# als [term]: browse or search shell aliases; uses fzf when available
als() {
    local BOLD CYAN GREEN DIM RESET
    _help_colors

    local term="${1:-}"
    local raw_aliases
    raw_aliases="$(alias | sed 's/^alias //')"

    if [[ -z "$term" ]]; then
        if command -v fzf >/dev/null 2>&1; then
            printf '%s\n' "$raw_aliases" | fzf \
                --prompt='alias> ' \
                --height=40% \
                --layout=reverse \
                --border \
                --header='Type to filter • Ctrl-C to cancel' \
                --preview='echo {}' \
                --preview-window=down:3:wrap
        else
            if [[ -n "${NO_COLOR:-}" ]]; then
                printf '%s\n' "$raw_aliases"
            else
                while IFS= read -r line; do
                    if [[ "$line" =~ ^([^=]+)=(.+)$ ]]; then
                        printf "${GREEN}%s${RESET}=%s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
                    else
                        printf '%s\n' "$line"
                    fi
                done <<< "$raw_aliases"
            fi
        fi
    else
        local results
        results="$(printf '%s\n' "$raw_aliases" | grep -i -- "$term" || true)"
        if [[ -z "$results" ]]; then
            printf "No aliases matching '%s'\n" "$term" >&2
            return 1
        fi
        if [[ -n "${NO_COLOR:-}" ]]; then
            printf '%s\n' "$results"
        else
            while IFS= read -r line; do
                if [[ "$line" =~ ^([^=]+)=(.+)$ ]]; then
                    printf "${GREEN}%s${RESET}=%s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
                else
                    printf '%s\n' "$line"
                fi
            done <<< "$results"
        fi
    fi
}

# ---------------------------------------------------------------------------
# shelp — shell help browser (aliases + functions)
# ---------------------------------------------------------------------------

# shelp [--aliases|--functions] [-h|--help] [term]: display or search shell help
shelp() {
    local BOLD CYAN GREEN DIM RESET
    _help_colors

    local config_dir="${BASH_CONFIG_DIR:-$HOME/.config/bash}"
    local show_aliases=1 show_functions=1 term='' opt

    # Parse options
    while [[ $# -gt 0 ]]; do
        opt="$1"
        case "$opt" in
            --aliases)
                show_aliases=1; show_functions=0; shift ;;
            --functions)
                show_aliases=0; show_functions=1; shift ;;
            -h|--help)
                printf 'Usage: shelp [--aliases|--functions] [-h|--help] [term]\n'
                printf '\n'
                printf '  --aliases    show aliases only\n'
                printf '  --functions  show functions only\n'
                printf '  -h, --help   show this help and exit\n'
                printf '  term         filter aliases and/or functions by name/value\n'
                return 0
                ;;
            --)
                shift; term="${1:-}"; [[ $# -gt 0 ]] && shift; break ;;
            -*)
                printf 'shelp: unknown option: %s\n' "$opt" >&2
                printf "Run 'shelp --help' for usage.\n" >&2
                return 2
                ;;
            *)
                term="$opt"; shift; break ;;
        esac
    done

    # ------ search mode -------------------------------------------------------
    if [[ -n "$term" ]]; then
        local alias_hits='' func_hits=''

        if (( show_aliases )); then
            alias_hits="$(_help_parse_aliases_file "$config_dir" "$term")"
        fi
        if (( show_functions )); then
            func_hits="$(_help_scan_functions "$config_dir" "$term")"
        fi

        if [[ -z "$alias_hits" && -z "$func_hits" ]]; then
            printf "No matches for '%s'\n" "$term" >&2
            return 1
        fi

        if [[ -n "$alias_hits" ]]; then
            printf "${BOLD}Aliases matching '%s':${RESET}\n" "$term"
            printf '%s\n' "$alias_hits"
        fi
        if [[ -n "$func_hits" ]]; then
            printf "${BOLD}Functions matching '%s':${RESET}\n" "$term"
            printf '%s\n' "$func_hits"
        fi
        return 0
    fi

    # ------ full display mode -------------------------------------------------
    if (( show_aliases )); then
        printf '%bAliases%b\n' "$BOLD" "$RESET"
        _help_parse_aliases_file "$config_dir" ''
    fi

    if (( show_functions )); then
        printf '%bFunctions%b\n' "$BOLD" "$RESET"
        _help_scan_functions "$config_dir" ''
    fi
}
