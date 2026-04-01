# Modules

CSI is a single installer (`install.sh`) plus several module directories.

## Core entrypoint

- `install.sh` — the unified installer.

## Notable modules

These are standalone directories with their own installers and/or docs:

- `modularshell/` — Bash configuration framework
  - Installer: `modularshell/install.sh`
  - Docs: `modularshell/README.md`, `modularshell/DOCUMENTATION.md`
  - Man page: `modularshell/man/man7/modularshell.7`

- `modularnotes/` — note-taking tooling
  - Installer: `modularnotes/install.sh`
  - Docs: `modularnotes/README.md`, `modularnotes/HOW-TO.md`

- `vim-config/` — vim setup used by the optional installer step
  - Dependencies: `vim-config/depends.sh`
  - Installer: `vim-config/install.sh`

- `theming/` — fonts + wallpapers
  - Installer: `theming/install_fonts-wallpapers.sh`
  - Assets: `theming/Wallpapers/`

- `system/` — service support helpers
  - Examples: Bluetooth, LightDM, printer support

- `setup/` — optional tooling helpers
  - Example: `setup/optional_tools.sh`

## Manual pages

The suite ships a man page:

- Source: `man/man7/modularconfig-suite.7`
- Install target: `~/.local/share/man/man7/modularconfig-suite.7`

After running `./install.sh`, you can open it with:

```bash
man modularconfig-suite
```
