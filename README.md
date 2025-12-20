![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)

# ModularConfig Suite (CSI)

ModularConfig Suite powers the CSI (Config Suite Installer) experience, a curated collection of installer helpers for Linux. The repository groups scripts by feature so you can immediately spot which module covers browsers, fastfetch, theming, system services, and tooling.

---

## Overview

CSI is built around a single interactive installer (`install.sh`) plus a handful of trusted utility directories. Each module ships with its own README so you can explore how it behaves outside the core installer.

## Unified Installer

This repository includes the CSI entry point: `install.sh`.

Quick examples:

```bash
# dry-run to preview actions
./install.sh --dry-run

# interactive install (choose groups)
./install.sh

# non-interactive: pick groups by name and assume yes
./install.sh --groups "Zypper / openSUSE packages (approximate names)" --yes
```

Optional build-from-source flows are available at the end of the install run (Neovim, Picom, Rofi, st). Use `--dry-run` first to preview commands.

The installer also includes an optional vim configuration setup that installs dependencies and copies a custom vimrc with plugins.

## Package Management

The installer uses a consolidated package list (`packages/consolidated.txt`) organized by functionality:
- System Tools (git, curl, wget, vim, etc.)
- Development Tools (gcc, cmake, python, nodejs, etc.)
- Desktop Applications (browsers, editors, multimedia, etc.)
- System Services (cups, bluetooth, networking, etc.)

Package names are automatically mapped for different distributions (e.g., `fd-find` on Debian vs `fd` on others).

Notes:
- Use `--log <file>` to change the logfile location (defaults to `./modularconfig-install.log`).
- The script will attempt to skip already-installed packages and supports common package managers (`apt`, `dnf`, `pacman`, `zypper`, `apk`, `brew`).
- Package names may vary by distribution; edit `packages/<pm>.txt` to customize.

## Repository Structure

CSI focuses on the directories you see in this repository. The legacy Discord, MKVMerge, st, and WezTerm installers were removed so only actively maintained modules appear in the installer menu.

Each directory below ships with its own README; hover on the links or open the file to see usage notes, dependencies, and configuration tips.

### `/browsers`

- Hosts helpers for Brave, Firefox, Floorp, Zen, and related browser tooling. See [browsers/README.md](browsers/README.md) for install steps.

### `/fastfetch`

- Contains the OS-aware fastfetch installer plus alias helpers (Bash/Zsh/Fish) and three sample configs. See [fastfetch/README.md](fastfetch/README.md).

### `/git`

- Git automation scripts (`gitup`, `git-notes-status.sh`) and the SSH setup guide (`CODEBERG_SSH_SETUP.md`) that help manage repositories from the CLI.

### `/neovim`

- `buttervim.sh` and `build-neovim.sh` install Neovim and the ModularConfig vim stack. Details live in [neovim/README.md](neovim/README.md).

### `/modularnotes`

- Modular note-taking tooling (notes/todos, backups, templates, and shell helpers). See [modularnotes/README.md](modularnotes/README.md).

### `/setup`

- Utility installers such as `install_caligula.sh`, `install_geany.sh`, `install_picom.sh`, and `optional_tools.sh`. The optional tools menu now surfaces CSI-friendly bundles including `ModularShell` and the fastfetch installer.

### `/system`

- Scripts for service support: Bluetooth, LightDM, and printer drivers.

### `/theming`

- Nerd font installs plus GTK theme setup. Documentation is available in [theming/README.md](theming/README.md).

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
4. Verify package installations and npm/cargo installs in a safe environment.

---

## ☕ Support

If these scripts have been helpful, consider buying me a coffee:

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## 📫 Author

**JustAGuy Linux**  
🎥 [YouTube](https://youtube.com/@JustAGuyLinux)  

---

More scripts coming soon. Use what you need, fork what you like, tweak everything.
