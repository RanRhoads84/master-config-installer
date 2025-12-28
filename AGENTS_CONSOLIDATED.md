# Agent Playbook (Consolidated)

This is the **single, canonical** reference for automation / coding agents working on **ModularConfig Suite (CSI)**.

If you’re new, start with:

- [Quick start](#quick-start)
- [Safe defaults](#safe-defaults)
- [Validation checklist](#validation-checklist)

---

## Scope

Work from the repo root. The primary touchpoints are:

- `install.sh` — unified installer and main entry point.
- `packages/` — package lists (especially `packages/pkg-list.txt`).
- `libs/` — shared Bash helpers.
- Module directories (examples): `modularshell/`, `modularnotes/`, `theming/`, `setup/`, `system/`, `vim-config/`.
- `tests/scripts/` — dry-run harnesses; `tests/test_dry_results/` stores logs.

---

## Quick start

Run a safe preview first:

```bash
./install.sh --dry-run
```

Non-interactive validation examples:

```bash
# Force a specific PM and avoid reading the host package DB
IGNORE_PKG_DB=1 ./install.sh --dry-run --yes --pm apt

# Validate a specific group non-interactively
./install.sh --dry-run --yes --groups "Shell Tools"
```

---

## Safe defaults

Use these defaults unless the task explicitly requires otherwise:

- Prefer `--dry-run` for any validation run.
- Use `--yes` for non-interactive runs.
- Use `IGNORE_PKG_DB=1` in automated tests / containers.
- Avoid `sudo` unless the task explicitly requires it.
- Keep changes idempotent and minimize destructive actions.

Notes:

- In CSI, `--dry-run` implicitly behaves like `--yes` to avoid blocking on prompts.

---

## Validation checklist

Use the smallest validation that fits the change, then expand if needed.

1. **Targeted dry-run**

```bash
IGNORE_PKG_DB=1 ./install.sh --dry-run --yes
```

2. **Package-manager matrix harness**

```bash
tests/scripts/test_dry_all_pm.sh
```

3. **Trace harness (when debugging behavior)**

```bash
tests/scripts/trace_dry_all_pm.sh
```

4. **Review logs**

- Default installer log: `./modularconfig-install.log`
- Harness logs: `tests/test_dry_results/`

---

## Package list rules

### Group list format

`packages/pkg-list.txt` is parsed like this:

- Lines starting with `#` define a **group header**.
- Non-empty, non-header lines are package names belonging to the current group.

These group header strings are the names used in the menu and must match `--groups` values.

### Optional lists

If present, these files are offered after package installs:

- `packages/npm.txt` → `npm install -g <pkg>`
- `packages/cargo.txt` → `cargo install <pkg>`

Both ignore blank lines and `#` comments.

### Distro mapping

CSI includes lightweight name mapping for common mismatches (e.g. `fd` vs `fd-find`).

If you add packages with known cross-distro name differences, be prepared to update mapping logic in `install.sh`.

---

## Coding & repo conventions

### Bash style

- Prefer Bash-first scripts (`#!/usr/bin/env bash`).
- When adding new scripts, prefer strict mode (`set -euo pipefail`) and safe `IFS`.
- Match the indentation style of the file you’re editing.
- Use `lower_snake_case` for function names; uppercase for constants.

### Documentation expectations

When behavior changes:

- Update the closest README for the module you touched.
- If installer behavior changes, update top-level docs (README / INSTALLER / docs pages).

### Commit / PR conventions

Follow the repo’s commit subject style:

- `docs:` / `fix(installer):` / `chore(push):` (or similar)

PRs should mention:

- Target distro / package manager
- The exact command(s) run (prefer `--dry-run`)
- Relevant log snippets when debugging is involved

---

## Operational constraints & pitfalls

- Many actions can require `sudo`; in CI or sandboxes this may be blocked. Prefer dry-run validation.
- End-to-end installs may fail in constrained environments due to:
  - `sudo` restrictions
  - `$HOME` write restrictions (man pages, vim config, wallpapers)
  - network restrictions (fonts, Flatpak remote setup)

If you need to validate those flows, do it on a real host or a properly-permissioned VM.

---

## Capabilities expected

Minimum capabilities expected for an agent working on this repo:

- Filesystem read/write within the repo
- Shell execution to run `./install.sh --dry-run` and `tests/scripts/*`
- Fast search (e.g., ripgrep) for locating references
- Git read operations (`status`, `diff`, `log`) for context
