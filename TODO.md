# Unified Installer Plan

This repo will include a unified interactive installer `install.sh` that:

- Detects the host package manager (`apt`, `dnf`, `pacman`, `zypper`, `apk`, `brew`).
- Loads package lists from `packages/`.
- Presents an interactive menu to select groups or all packages.
- Supports flags: `--dry-run`, `--yes`, `--groups <list>`, `--log <path>`.
- Provides idempotent installs and `--dry-run` output.
- Supports `npm` and `cargo` installs and (optional) source builds for heavy components.
- Performs post-install steps (enable services, symlinks, update font cache).

Work items:

1. Create `install.sh` scaffold with argument parsing and PM detection.
2. Load `packages/*.txt` mapping to PM-specific installs.
3. Implement PM driver functions for `apt`, `pacman`, `dnf`, `zypper`, `apk`, `brew`.
4. Add `npm`/`cargo` handling and optional source-build flows.
5. Add logging, `--dry-run`, and `--yes` non-interactive mode.
6. Add README usage and test instructions.

Backups: a compressed archive of the repo was created before any changes.
