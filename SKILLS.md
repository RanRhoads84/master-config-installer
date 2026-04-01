# Agent Skills

This repository is a Bash-first installer suite. Agents should be comfortable
with safe shell automation, Linux package managers, and dry-run workflows.

## Core Technical Skills
- Bash scripting with safe quoting, and arrays.
- Package manager fluency: `apt`, `dnf`, `pacman`, `zypper` (repo setup and non-interactive flags).
- Installer hygiene: `--dry-run`, `--yes`, `--pm`, `--log`, and `IGNORE_PKG_DB`.
- Structured file edits in `packages/`, module directories, and `install.sh`.

## Testing & Debugging
- Run dry-run harnesses in `tests/scripts/` and interpret logs in `tests/test_dry_results/`.
- Use `bash -x` traces to diagnose installer behavior and errors.
- Validate outcomes by checking `./modularconfig-install.log`.

## Safety & Collaboration
- Prefer idempotent changes; avoid destructive commands unless explicitly asked.
- Minimize `sudo` usage, and surface when it is required.
- Keep docs in sync when installer behavior or module setup changes.
