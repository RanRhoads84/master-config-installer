# Repository Guidelines

**Canonical agent doc:** see `AGENTS_CONSOLIDATED.md` for the single consolidated playbook.

## Project Structure & Module Organization
This repository is a Bash-first installer suite. Key locations:
- `install.sh` is the unified interactive installer and main entry point.
- `packages/` holds the unified group list in `packages/pkg-list.txt` (optional `packages/npm.txt` and `packages/cargo.txt` are honored if present).
- Shared Bash helpers live in `libs/`; suite and module man pages live in `man/` and module `man/` folders.
- Module directories like `modularshell/`, `setup/`, `system/`, `theming/`, and `vim-config/` each include their own README (when available).
- `tests/scripts/` contains dry-run harnesses; `tests/test_dry_results/` stores logs.
- `theming/Wallpapers/` is a large asset library.

## Build, Test, and Development Commands
- `./install.sh --dry-run` preview actions without changes.
- `./install.sh` run the interactive menu.
- `./install.sh --groups "Shell Tools" --yes` run non-interactively by group name.
- `./install.sh --pm apt --log ./modularconfig-install.log` override PM and log location.
- `tests/scripts/test_dry_all_pm.sh` run dry-runs for apt, dnf, pacman, zypper.
- `tests/scripts/trace_dry_all_pm.sh` run `bash -x` traces for troubleshooting.
- `IGNORE_PKG_DB=1 ./install.sh --dry-run --yes --pm dnf` avoids consulting the host package DB.

## Coding Style & Naming Conventions
- Use Bash (`#!/usr/bin/env bash`) and favor strict mode: `set -euo pipefail` and `IFS=$'\n\t'`.
- Match the indentation style of the file you are editing (2 or 4 spaces are common).
- Use lower_snake_case for function names; uppercase for constants and flag-like variables.
- Installer helpers follow `install_*.sh` naming in `setup/` and `system/`.

## Testing Guidelines
Dry-run testing is the norm. Use `--dry-run` with `--yes` for non-interactive runs, and store artifacts in `tests/test_dry_results/`. Review `./modularconfig-install.log` for installer details.

## Commit & Pull Request Guidelines
Recent history favors short, imperative subjects with prefixes such as `docs:`, `fix(installer):`, and `chore(push):`, plus the occasional plain sentence. Prefer `type(scope): summary` when possible. PRs should describe the target distro or package manager, include relevant command output or log snippets for installer changes, and update module READMEs when behavior changes.

## Safety & Configuration Tips
Most scripts invoke `sudo`. Recommend `--dry-run` first, and keep package group headers in `packages/pkg-list.txt` aligned with the installer menu labels.
