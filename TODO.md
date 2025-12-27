# TODO (from DEVELOPMENT_LOG.md → Next Steps)

## Immediate (High Priority)
1. Run dry-run matrix: Execute `tests/scripts/test_dry_all_pm.sh` and review logs in `tests/test_dry_results/`.
2. Validate man page installs: Confirm `man modularconfig-suite` and `man modularshell` resolve after running installers.
3. Wire theming assets install: Decide on `theming/Wallpapers/` destination (for example `~/.local/share/wallpapers`) and wire `theming/install_fonts-wallpapers.sh` into the installer or optional tools.
4. Test full installation flow: Ensure end-to-end functionality works after any installer wiring changes.

## Medium Priority
1. Input validation: Harden error handling for invalid comma-separated input.
2. Menu navigation: Improve flow between main menu and submenus.
3. Library consolidation: Ensure scripts source helpers from `libs/` via `script_dir` and remove lingering `lib/` references.
4. Package list maintenance: Keep `packages/pkg-list.txt` sorted and aligned with menu labels.
5. Optional package lists: Decide whether to add `packages/npm.txt` and `packages/cargo.txt` templates or document their optional use.

## Future Enhancements
1. Dependency resolution: Handle package dependencies automatically.
2. Rollback functionality: Ability to undo installations.
3. Configuration profiles: Save/load different package selection profiles.
4. Progress reporting: Summarize per-group install results and timing.
