#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

PMS=(apt dnf pacman zypper)
OUTDIR="tests/test_dry_results"
mkdir -p "$OUTDIR"

echo "Starting traced dry-run tests for: ${PMS[*]}"

for pm in "${PMS[@]}"; do
  echo
  echo "=== Trace PM: $pm ==="
  logfile="$OUTDIR/trace-$pm.log"
  echo "PM: $pm" > "$logfile"
  echo "Command: bash -x ./install.sh --dry-run --yes --pm $pm" >> "$logfile"

  set +e
  IGNORE_PKG_DB=1 bash -x ./install.sh --dry-run --yes --pm "$pm" >> "$logfile" 2>&1
  rc=$?
  set -e

  echo "EXIT_CODE: $rc" >> "$logfile"
  echo "Saved trace log: $logfile (exit $rc)"
done

echo
echo "Traced tests complete. Logs: $OUTDIR"
