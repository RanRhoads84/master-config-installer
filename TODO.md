# TODO (from DEVELOPMENT_LOG.md → Next Steps)

## Immediate (High Priority)
1. Validate man page installs: Confirm `man modularconfig-suite` and `man modularshell` resolve after running installers.
2. Test full installation flow: Ensure end-to-end functionality works after any installer wiring changes.

## Medium Priority
1. Menu navigation: Improve flow between main menu and submenus as needed.
2. Package list maintenance: Keep `packages/pkg-list.txt` sorted and aligned with menu labels.
3. Optional package lists: Decide if additional examples or docs are needed for npm/cargo lists.

## Future Enhancements
1. Dependency resolution: Handle package dependencies automatically.
2. Rollback functionality: Ability to undo installations.
3. Configuration profiles: Save/load different package selection profiles.
4. Progress reporting: Summarize per-group install results and timing.

## Completed
- Dry-run matrix: `tests/scripts/test_dry_all_pm.sh` ran clean with logs in `tests/test_dry_results/`.
- Theming assets install: Wired `theming/install_fonts-wallpapers.sh` into `install.sh`.
- Input validation: Hardened submenu parsing (whitespace, duplicates, and aliases).
- Library consolidation: Standardized helper sourcing via `script_dir` and `libs/`.
- Optional package lists: Added `packages/npm.txt` and `packages/cargo.txt` templates.
