# ModularConfig Suite (CSI)

ModularConfig Suite powers the CSI (Config Suite Installer) experience, a curated collection of installer helpers for Linux. The repository groups scripts by feature so you can immediately spot which module covers shell configuration, notes, theming, system services, and tooling.

---

## Overview

CSI is built around a single interactive installer (`install.sh`) plus a handful of trusted utility directories. Modules that include README files document their standalone behavior outside the core installer.

## Documentation

Focused docs live in `docs/`:

- [docs/README.md](docs/README.md)

## Unified Installer

This repository includes the CSI entry point: `install.sh`.

Quick examples:

```bash
# dry-run to preview actions
./install.sh --dry-run

# interactive install (choose groups)
./install.sh

# non-interactive: pick groups by name and assume yes
./install.sh --groups "Shell Tools" --yes
```

After package installs, the script can optionally run module installers (such as `vim-config` and theming assets) and setup steps for Flatpak and VS Code. If `packages/npm.txt` or `packages/cargo.txt` exist, it will also offer to install those package lists. Use `--dry-run` first to preview commands.

The installer includes an optional vim configuration setup that installs dependencies and applies the curated vimrc from `vim-config/`.

## Manual Pages

A normal `./install.sh` run installs the suite manual page to `~/.local/share/man/man7`. Use:

```bash
man modularconfig-suite
```

Running `./modularshell/install.sh` installs the ModularShell manual page:

```bash
man modularshell
```

## Flatpak Setup

CSI can optionally walk through the official Flatpak setup steps from https://flatpak.org/setup/. When you agree, `install.sh` installs the `flatpak` package via the detected package manager (if it is not already available), adds the Flathub remote in the user scope, and runs `flatpak update --assumeyes` so the runtime catalog is up to date.

## VS Code Repository Setup

When you agree, `install.sh` follows the official guidance at https://code.visualstudio.com/docs/setup/linux to import the Microsoft signing key, add the VS Code repository, and install the `code` package for `apt`, `dnf`, or `zypper`-based systems. That means Windows-style releases are served through the native package manager and stay up to date automatically.

## Package Management

The installer uses a consolidated package list (`packages/pkg-list.txt`) organized into the same categories you see in the menu. Each header in the file (and the corresponding menu entry) covers a group such as:
- Build Dependencies
- Database
- Development Tools
- Network Tools
- Office & Productivity
- Security Tools
- Shell Tools
- System Monitoring
- System Tools
- Virtualization

Package names are automatically mapped for different distributions (e.g., `fd-find` and `batcat` on Debian/Ubuntu).

Notes:
- Use `--log <file>` to change the logfile location (defaults to `./modularconfig-install.log`).
- The script will attempt to skip already-installed packages and supports `apt`, `dnf`, `pacman`, and `zypper` (use `--pm` to override detection).
- Set `IGNORE_PKG_DB=1` to skip package database checks.
- Package names may vary by distribution; edit `packages/pkg-list.txt` to customize.

## Repository Structure

CSI focuses on the directories you see in this repository. Only actively maintained modules appear in the installer menu.

Modules with README files include usage notes, dependencies, and configuration tips.

### `/libs`

- Shared Bash helpers for logging, menus, and text formatting.

### `/modularnotes`

- Modular note-taking tooling (notes/todos, backups, templates, and shell helpers). See [modularnotes/README.md](modularnotes/README.md).

### `/modularshell`

- Modular Bash configuration framework plus helper functions. See [modularshell/README.md](modularshell/README.md).

### `/man`

- Manual pages for CSI and modules.

### `/packages`

- Unified package group list consumed by the installer.

### `/setup`

- Utility installers and the `optional_tools.sh` menu. The optional tools menu can fetch and run external helper installers when requested.

### `/system`

- Scripts for service support: Bluetooth, LightDM, and printer drivers.

### `/theming`

- Fonts + wallpaper setup plus the `Wallpapers/` asset library.

### `/tests`

- Dry-run harnesses and stored results (see `tests/scripts/` and `tests/test_dry_results/`).

### `/vim-config`

- Vim configuration installer used by the optional installer step.

Thanks to everyone who has contributed—ModularConfig Suite (CSI) stands on top of your scripts, configurations, and feedback.

## 🛠️ Built For

- Debian-based distros (and the broader Linux ecosystem)
- tiled/window manager users (BSPWM, Openbox, Sway, etc.)
- people who prefer modular, fast tooling that can be riffed on

---

## Testing

To test the unified installer:

1. Run `./install.sh --dry-run` to preview actions without making changes.
2. Check the log file (`./modularconfig-install.log` by default) for detailed output.
3. For non-interactive testing, use `--groups <list> --yes`.
4. To dry-run against all supported package managers, use `tests/scripts/test_dry_all_pm.sh`.
5. For verbose traces, use `tests/scripts/trace_dry_all_pm.sh` (logs land in `tests/test_dry_results/`).
6. Verify package installations and any npm/cargo installs in a safe environment.

---

## ☕ Support

If these scripts have been helpful, consider buying me a coffee:

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## 📫 Author

**JustAGuy Linux**  
🎥 [YouTube](https://youtube.com/@JustAGuyLinux)  

---

More scripts coming soon. Use what you need, fork what you like, tweak everything.
