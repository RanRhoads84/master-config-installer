# Agents and Test Scripts

This repository includes a small set of helper "agents" (scripts and test harnesses)
used to run dry-runs, traced runs, and other automation steps for the installer.

Overview
- `install.sh` - main installer. Supports `--dry-run`, `--yes`/`-y`, `--pm <name>` and reads `IGNORE_PKG_DB`.
- `tests/scripts/test_dry_all_pm.sh` - runs a dry-run across supported package managers and writes logs to `tests/test_dry_results/`.
- `tests/scripts/trace_dry_all_pm.sh` - runs `bash -x` traced dry-runs and stores traces in `tests/test_dry_results/`.
- `push-git.sh` - repository push helper (used by maintainers).

Key env vars / flags
- `DRY_RUN=1` or `--dry-run` : run in dry-run mode (no package manager commands executed).
- `ASSUME_YES=1` or `--yes`/`-y` : assume yes to all interactive prompts.
- `IGNORE_PKG_DB=1` : testing mode that ignores the system package DB when checking installed/available packages.
- `--pm <apt|dnf|pacman|zypper>` : force a specific package manager.

Common commands

Run a simple dry-run (auto assumes yes in dry-run):
```bash
./install.sh --dry-run --pm zypper
```

Run a traced dry-run and save output:
```bash
bash -x ./install.sh --dry-run --pm apt 2>&1 | tee tests/test_dry_results/trace-apt.log
```

Run the test harness (all package managers):
```bash
tests/scripts/test_dry_all_pm.sh
```

Where logs go
- Per-run logs and traces: `tests/test_dry_results/` (this directory is gitignored for large artifacts).
- Installer log: `./modularconfig-install.log`.

Notes for maintainers
- Dry-run mode is non-interactive (it sets `ASSUME_YES=1`) so it can be used in CI.
- The installer now skips packages not found in configured repositories and logs them as skipped.
- If you need deterministic tests that don't consult the host system, use `IGNORE_PKG_DB=1`.

If you want any additional agent scripts or CI snippets added, open an issue or send a PR.

-- Maintainers
