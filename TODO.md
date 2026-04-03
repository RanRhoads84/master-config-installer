# TODO (from DEVELOPMENT_LOG.md → Next Steps)

## Immediate (High Priority)
1. Validate man page installs: Confirm `man modularconfig-suite` and `man modularshell` resolve after running installers.
2. Test full installation flow: Re-run `./install.sh --yes` on a real host (sandbox blocked sudo/network/home writes).
3. Triage temp/: Determine if `temp/git-setup.sh` duplicates `functions/git-config.sh` and integrate or delete; promote `temp/test-vscode-setup.sh` to `tests/` or drop it.

## Medium Priority
None currently.

## Future Enhancements
1. Dependency resolution: Handle package dependencies automatically.
2. Rollback functionality: Ability to undo installations.
3. Configuration profiles: Save/load different package selection profiles.
4. Progress reporting: Summarize per-group install results and timing.

## Completed
- Post-menu integration: npm, cargo, vim-config, theming, flatpak, vscode, modularshell, git-config are now selectable menu items under "Setup & Configuration" instead of running unconditionally.
- Menu performance overhaul: cached group counts eliminate per-render subprocess forks; render cost is now zero.
- Menu visuals: ANSI colors, clear on render, unicode box-drawing table, color-coded columns.
- --dry-run fix: no longer forces --yes; flags are independent.
- Install summary: aggregate "Packages" row with totals; unavailable packages shown on request.
- shellcheck -x clean: fixed SC2004 warnings and stale shellcheck source= paths.
- Dry-run matrix: `tests/scripts/test_dry_all_pm.sh` ran clean with logs in `tests/test_dry_results/`.
- Theming assets install: Wired `theming/install_fonts-wallpapers.sh` into `install.sh`.
- Input validation: Hardened submenu parsing (whitespace, duplicates, and aliases).
- Library consolidation: Standardized helper sourcing via `script_dir` and `libs/`.
- Optional package lists: Added `packages/npm.txt` and `packages/cargo.txt` templates.
- Menu navigation: Added explicit `back/all` hints and `q/quit/exit` main-menu alias.
- Package list maintenance: Sorted `packages/pkg-list.txt` within groups.
- Optional package list docs: Updated installer docs to mention npm/cargo lists.
- Full install attempt: Ran `./install.sh --yes` in sandbox; blocked by sudo/no-new-privileges, home write permissions, and network restrictions.
- Documentation refresh: Updated README, INSTALLER, AGENTS_GUIDE, and module docs to reflect current CSI layout.
