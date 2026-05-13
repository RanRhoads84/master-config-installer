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

- `--dry-run` and `--yes` are independent flags. Dry-run prints commands without executing them but does not skip prompts on its own.
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
3. Presents a colored, unicode table menu with two sections:

   **Package groups** (10 groups: Build Dependencies, Database, Development Tools,
   Network Tools, Office & Productivity, Security Tools, Shell Tools, System Monitoring,
   System Tools, Virtualization) — each row shows how many packages in the group are
   already installed vs. not yet installed.

   **Setup & Configuration** (8 modules: npm, Cargo, Vim Config, Theming Assets,
   Flatpak, VS Code, ModularShell, Git Config) — selecting a module runs its
   handler from `functions/` immediately and returns to the menu.

4. Selecting a package group opens a submenu: install all packages in the group, or
   pick individual packages.
5. "Install all groups and run setup" installs every package group and all setup
   modules, then exits.
6. After the menu, prints a colored install summary: per-module status rows, an
   aggregate Packages row (N installed, N already installed), a totals line, and an
   opt-in prompt to list unavailable packages.

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
