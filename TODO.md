# Unified Installer Plan

This repo will include a unified interactive installer `install.sh` that:

- Detects the host package manager (`apt`, `dnf`, `pacman`, `zypper`, `apk`, `brew`).
- Loads package lists from `packages/consolidated.txt` (organized by functionality).
- Presents an interactive menu to select groups or all packages.
- Supports flags: `--dry-run`, `--yes`, `--groups <list>`, `--log <path>`.
- Provides idempotent installs and `--dry-run` output.
- Supports `npm` and `cargo` installs and (optional) source builds for heavy components.
- Performs post-install steps (enable services, symlinks, update font cache).

Work items:

1. Create `install.sh` scaffold with argument parsing and PM detection. ✅
2. Load `packages/*.txt` mapping to PM-specific installs. ✅
3. Implement PM driver functions for `apt`, `pacman`, `dnf`, `zypper`. ✅
4. Add `npm`/`cargo` handling and optional source-build flows. ✅
5. Add logging, `--dry-run`, and `--yes` non-interactive mode. ✅
6. Add README usage and test instructions. ✅
7. Consolidate the main menu layout so it mirrors `packages/consolidated.txt` and avoids duplicate entries.
8. Trim the main menu as needed so it focuses on the modules we plan to ship.
9. Remove the unused folders (`discord`, `mkvmerge`, `st`, `wezterm`) from the repo since those packages are no longer install options.
10. Flesh out `fastfetch/install_fastfetch.sh` and the accompanying configs so they detect OS/architecture, then fetch and configure fastfetch from this repo.
11. Document and/or simplify the usage of the scripts inside `browsers/`, `git/`, `theming/`, `system/`, and `setup/` to understand how (or if) they should appear in the installer.
12. Incorporate the contents of `butterbash/` and `vim-config/` into the main installer options (e.g., new menu entries or post-install steps).
13. Refactor the main install script to streamline operations and improve execution speed across supported package managers.

Backups: a compressed archive of the repo was created before any changes.
