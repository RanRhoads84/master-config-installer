# Agents Guide

This guide is for automation agents working on ModularConfig Suite (CSI). It
focuses on safe, repeatable workflows for the installer and module scripts.

## Scope
Agents should operate from the repo root and focus on `install.sh`, module
directories (for example `modularshell/`, `modularnotes/`, `theming/`, `setup/`),
and package lists in `packages/`.

## Safe Defaults
- Use `./install.sh --dry-run` for any validation run.
- Add `--yes` for non-interactive execution.
- Use `IGNORE_PKG_DB=1` in tests to avoid reading the host package DB.
- Avoid `sudo` unless the task explicitly requires it.

## Standard Validation
- Dry-run a specific manager: `IGNORE_PKG_DB=1 ./install.sh --dry-run --yes --pm apt`.
- Run the harness: `tests/scripts/test_dry_all_pm.sh`.
- For debugging: `tests/scripts/trace_dry_all_pm.sh` (writes traces to `tests/test_dry_results/`).
- Review logs: `./modularconfig-install.log` and `tests/test_dry_results/*.log`.

## Editing Expectations
- Keep scripts Bash-first and match local formatting.
- Update module READMEs when behavior changes.
- Keep package group headers in `packages/pkg-list.txt` aligned with the menu labels.

## Coordination
- Align commits with the repo style (`docs:`, `fix(installer):`, `chore(push):`).
- Use `SKILLS.md` for skill expectations and `MCP_CAPABILITIES.md` for tool limits.
