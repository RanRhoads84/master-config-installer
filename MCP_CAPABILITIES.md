# MCP Capabilities

This file describes the minimum MCP capabilities expected when working on this
repository. Keep usage safe, local-first, and consistent with dry-run workflows.

## Required Capabilities
- Filesystem read/write within the repo to update scripts, package lists, and docs.
- Shell execution to run `./install.sh --dry-run` and test harnesses in `tests/scripts/`.
- Fast text search (ripgrep) to locate module references and package entries.
- Git read operations (`status`, `log`, `diff`) to align with commit conventions.

## Preferred Optional Capabilities
- Network access (restricted by default) for verifying remote installer URLs in `setup/`.
- Ability to capture command output to logs for traceability.

## Safety Notes
- Avoid destructive commands unless explicitly requested.
- Use dry-run mode and `--yes` for non-interactive checks.
