#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

PMS=(apt dnf pacman zypper)
OUTDIR="test_dry_results"
mkdir -p "$OUTDIR"

echo "Starting dry-run tests for package managers: ${PMS[*]}"

for pm in "${PMS[@]}"; do
  echo
  echo "=== Testing PM: $pm ==="
  logfile="$OUTDIR/$pm.log"
  echo "PM: $pm" > "$logfile"
  echo "Command: ./install.sh --dry-run --yes --pm $pm" >> "$logfile"

  # Run install.sh with dry-run and assume-yes using the --pm override,
  # and ignore the system package DB so tests are hermetic.
  IGNORE_PKG_DB=1 ./install.sh --dry-run --yes --pm "$pm" >> "$logfile" 2>&1 || echo "install.sh exited with code $?" >> "$logfile"

  echo "Completed PM: $pm (log: $logfile)"
  echo "Saved log to $logfile"
done

echo
echo "All tests complete. Logs in: $OUTDIR"
