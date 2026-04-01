# Usage

## Quick start

```bash
# Preview what would happen (no changes)
./install.sh --dry-run

# Interactive (choose groups / per-group packages)
./install.sh

# Non-interactive: install specific groups
./install.sh --groups "Shell Tools,Development Tools" --yes
```

Notes:

- `--dry-run` automatically behaves like `--yes` to avoid blocking on prompts.
- The installer writes a log file (default: `./modularconfig-install.log`).

## Command-line options

`./install.sh --help` prints the authoritative list. Common options:

- `--dry-run` — print commands but don’t execute them.
- `--yes` / `-y` — assume yes to prompts.
- `--groups <list>` — comma-separated group names (must match headers in `packages/pkg-list.txt`).
- `--pm <name>` — override package manager detection (`apt|dnf|pacman|zypper`).
- `--log <file>` — change log path.

## What the installer does (high level)

1. Detects a package manager (or uses `--pm`).
2. Loads package groups from `packages/pkg-list.txt`.
3. Lets you:
   - select a group, then select packages within it, **or**
   - install all groups, **or**
   - install specific groups via `--groups`, **or**
   - install everything via `--yes`.
4. Optionally offers extra steps (prompted at the end):
   - npm global packages from `packages/npm.txt` (if present)
   - cargo packages from `packages/cargo.txt` (if present)
   - vim configuration installer from `vim-config/`
   - fonts + wallpapers installer from `theming/install_fonts-wallpapers.sh`
   - Flatpak setup (install + add Flathub remote)
   - VS Code repo setup + install `code` (wired for `apt`, `dnf`, `zypper`)

## Logs

Default log file is created in the repo root:

- `./modularconfig-install.log`

To change it:

```bash
./install.sh --log /tmp/csi-install.log
```

## Safety

- Many actions run via `sudo`.
- Use `--dry-run` first on a new machine.
- If package database checks are slow or problematic, you can bypass them:

```bash
IGNORE_PKG_DB=1 ./install.sh --dry-run --yes
```
