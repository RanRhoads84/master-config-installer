#!/usr/bin/env bash

# ---------------------------------------------------------
# log.bash
# Simple debug logging helper for Bash scripts
#
# Usage:
#   source log.bash
#   init_log
#   log "message"
#
# Execute directly or call log_help for usage info.
# ---------------------------------------------------------

init_log() {
  local caller script_name script_dir repo_root log_dir

  # Script that called init_log (not this file)
  caller="${BASH_SOURCE[1]}"
  script_name="$(basename "$caller" .sh)"

  script_dir="$(cd "$(dirname "$caller")" && pwd)"
  repo_root="$(cd "$script_dir/.." && pwd)"

  log_dir="$repo_root/logs"
  mkdir -p "$log_dir" || {
    echo "Failed to create log directory: $log_dir" >&2
    return 1
  }

  LOGFILE="$log_dir/${script_name}.log"
  touch "$LOGFILE" || {
    echo "Failed to create log file: $LOGFILE" >&2
    return 1
  }
}

log() {
  local msg="$1"

  [[ -z "${LOGFILE:-}" ]] && {
    echo "LOGFILE not initialized. Call init_log first." >&2
    return 1
  }

  printf "%s %s\n" \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "$msg" >> "$LOGFILE"
}

log_help() {
  cat <<'EOF'
log.bash
========

Simple debug logging helper for Bash scripts.

WHAT IT DOES
------------
- Creates a repo-level logs/ directory
- Creates a log file named after the calling script
- Appends timestamped messages to that file

BASIC USAGE
-----------
source /path/to/log.bash

init_log
log "Starting script"
log "Doing work"
log "Finished"

RESULT
------
If your script is named:
  install.sh

Log file will be:
  logs/install.log

TIMESTAMP FORMAT
----------------
UTC ISO-8601:
  YYYY-MM-DDTHH:MM:SSZ

IMPORTANT NOTES
---------------
- init_log must be called once before log
- log writes only to the log file (no stdout)
- LOGFILE is set globally after initialization
- Designed for debug / install / automation logs

CALLING HELP
------------
After sourcing:
  log_help

Execute directly:
  ./log.bash
  bash log.bash

EOF
}

# Print help if executed directly or call with --help or -h
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  case "$1" in
    -h|--help|"")
      log_help
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help"
      exit 1
      ;;
  esac
fi