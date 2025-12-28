# Development & testing

## Recommended workflow

1. Run the installer in dry-run mode first.
2. Use the test harness scripts under `tests/scripts/`.
3. Inspect logs in `tests/test_dry_results/` and `./modularconfig-install.log`.

## Dry-run

```bash
./install.sh --dry-run
```

Dry-run mode prints commands and avoids interactive prompts by implicitly assuming yes.

## Non-interactive test runs

Install selected groups without prompts:

```bash
./install.sh --groups "Shell Tools" --yes --dry-run
```

## Package manager matrix tests

These scripts exercise dry-run behavior across supported PMs:

```bash
tests/scripts/test_dry_all_pm.sh
tests/scripts/trace_dry_all_pm.sh
```

- `test_dry_all_pm.sh` runs standard dry-runs.
- `trace_dry_all_pm.sh` runs with `bash -x` for deeper troubleshooting.

## Log locations

- Default installer log: `./modularconfig-install.log`
- Test artifacts: `tests/test_dry_results/`

## Editing package groups

- Keep group headers in `packages/pkg-list.txt` aligned with the installer menu labels.
- When adding distro-specific package name variants, consider updating the mapping logic in `install.sh`.

## Style

This repo is Bash-first.

- Prefer `#!/usr/bin/env bash`.
- Favor strict mode (`set -euo pipefail` + safe `IFS`) for new scripts.
- Use `lower_snake_case` for functions; uppercase for constants.
