#!usr/bin/env bash
#
# =========================================================
# text_mods.bash
# ANSI text formatting modifiers and colors
# Source this file to use formatting variables.
# Execute directly to view usage examples.
# =========================================================
#
# ---- Reset ----
RESET='\033[0m'
NC='\033[0m'

# ---- Text attributes (set) ----
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
HIDDEN='\033[8m'
STRIKETHROUGH='\033[9m'

# ---- Text attributes (unset) ----
NO_BOLD='\033[22m'
NO_DIM='\033[22m'
NO_ITALIC='\033[23m'
NO_UNDERLINE='\033[24m'
NO_BLINK='\033[25m'
NO_REVERSE='\033[27m'
NO_HIDDEN='\033[28m'
NO_STRIKETHROUGH='\033[29m'

# ---- Text colors ----
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'

BRIGHT_BLACK='\033[90m'
BRIGHT_RED='\033[91m'
BRIGHT_GREEN='\033[92m'
BRIGHT_YELLOW='\033[93m'
BRIGHT_BLUE='\033[94m'
BRIGHT_MAGENTA='\033[95m'
BRIGHT_CYAN='\033[96m'
BRIGHT_WHITE='\033[97m'

# ---- Background colors ----
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

BG_BRIGHT_BLACK='\033[100m'
BG_BRIGHT_RED='\033[101m'
BG_BRIGHT_GREEN='\033[102m'
BG_BRIGHT_YELLOW='\033[103m'
BG_BRIGHT_BLUE='\033[104m'
BG_BRIGHT_MAGENTA='\033[105m'
BG_BRIGHT_CYAN='\033[106m'
BG_BRIGHT_WHITE='\033[107m'

# ---- Extended color templates ----
FG_256='\033[38;5;%sm'
BG_256='\033[48;5;%sm'
FG_RGB='\033[38;2;%s;%s;%sm'
BG_RGB='\033[48;2;%s;%s;%sm'

# =========================================================
# Help / Usage
# =========================================================

text_mods_help() {
  cat <<'EOF'
text_mods.bash
==============

ANSI text formatting modifiers for Bash scripts.

BASIC USAGE
-----------
source text_mods.bash

echo -e "${BOLD}Bold${RESET}"
echo -e "${FG_RED}Red${RESET}"
echo -e "${UNDERLINE}Underlined${RESET}"

COMBINING MODIFIERS
-------------------
echo -e "${BOLD}${FG_GREEN}Success${RESET}"
echo -e "${ITALIC}${FG_YELLOW}Warning${RESET}"
echo -e "${UNDERLINE}${FG_RED}Error${RESET}"

BACKGROUND COLORS
-----------------
echo -e "${FG_WHITE}${BG_RED} White on red ${RESET}"

RESETTING OUTPUT
----------------
Always reset formatting:

echo -e "${BOLD}Styled${RESET}"
echo "Normal"

UNSETTING ATTRIBUTES
--------------------
echo -e "${BOLD}Bold ${NO_BOLD}Normal${RESET}"

256-COLOR
---------
printf "${FG_256}Indexed color${RESET}\n" 196

TRUECOLOR
---------
printf "${FG_RGB}RGB text${RESET}\n" 255 128 0

EXECUTION BEHAVIOR
------------------
- Sourced: defines variables only
- Executed: prints this help text

EOF
}

# Print help if executed directly or call with --help or -h
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  case "$1" in
    -h|--help|"")
      text_mods_help
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help"
      exit 1
      ;;
  esac
fi
