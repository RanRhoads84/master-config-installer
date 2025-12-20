# 🧈 butterscripts
![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)

A modular collection of scripts I use across my Debian setups — minimal and practical. These scripts automate installs, configure tools, apply theming, and tweak the system just how I like it.

---

## Overview

Butterscripts is a collection of utility scripts that help streamline various tasks in Linux. These scripts are organized into different directories based on their functionality and purpose, making it easy to find the script you need.

## Unified Installer

This repository includes a unified interactive installer: `install.sh`.

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
- Use `--log <file>` to change the logfile location.
- The script will attempt to skip already-installed packages and supports common package managers (`apt`, `dnf`, `pacman`, `zypper`, `apk`, `brew`).
- Package names may vary by distribution; edit `packages/<pm>.txt` to customize.

## Repository Structure

The repository is organized into the following directories:


### `/browsers`

- [Installation and Documentation](https://codeberg.org/justaguylinux/butterscripts/src/branch/main/browsers)
- **brave**: Brave browser
- **firefox**: Firefox latest
- **floorp**: Floorp
- **zen**: Zen browser
- **more**

---

### `/discord` 

- [Installation and Documentation](https://codeberg.org/justaguylinux/butterscripts/src/branch/main/discord)
- **Install**: Discord latest binary and built-in updater.

---

### `/fastfetch`

- [Installation and Documentation](https://codeberg.org/justaguylinux/butterscripts/src/branch/main/fastfetch)
- **fastfetch**: fastfetch latest
- **Auto alias**: for Bash, Zsh, and Fish
- **3 configurations**: default, minimal and server

---

### `/git`

- [Installation and Documentation](https://codeberg.org/justaguylinux/butterscripts/src/branch/main/git)
- **gitup**: Quick commit and push workflow script
- **git-notes-status.sh**: Background monitoring script for git repository status notifications
- **CODEBERG_SSH_SETUP.md**: SSH setup guide for Codeberg

---

### `/mkvmerge`

- **mergemkvs**: Script for merging MKV files

---

### `/neovim`

- [Installation and Documentation](https://codeberg.org/justaguylinux/butterscripts/src/branch/main/neovim)
- **buttervim.sh**: Installs Neovim and sets up JustAGuyLinux's configuration
- **build-neovim.sh**: Builds and installs Neovim from source code

---

### `/setup`

- **install_caligula.sh**: Installs Caligula disk imaging TUI
- **install_geany.sh**: Installs Geany text editor (APT or source build options)
- **install_picom.sh**: Installs Picom compositor
- **optional_tools.sh**: Interactive installer for development tools including [ButterBash](https://codeberg.org/justaguylinux/butterbash) ⭐

---

### `/st`

- **install_st.sh**: Installs st (simple terminal)

---

### `/system`

- **install_bluetooth.sh**: Installs and configures Bluetooth support
- **install_lightdm.sh**: Installs LightDM display manager
- **install_printer_support.sh**: Sets up printer support

---

### `/theming`

- [Installation and Documentation](https://codeberg.org/justaguylinux/butterscripts/src/branch/main/theming)
- **nerdfonts**: Installs curated list of popular Nerd Fonts.
- **install-theme**: Installs my favorite GTK theme and Dracula Dark icon theme

---

### `/wezterm`

- [Installation and Documentation](https://codeberg.org/justaguylinux/butterscripts/src/branch/main/wezterm)
- **install_wezterm.sh**: Installs WezTerm terminal emulator from official repository
- **wezterm.lua**: Curated lua configuration file for WezTerm

---

Thanks to all contributors and the open source community for inspiration and code references.
## 🧈 Built For

- **Butter Bean (butterbian) Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast

> Butterbian Linux is a joke... for now.

---

## Testing

To test the unified installer:

1. Run `./install.sh --dry-run` to preview actions without making changes.
2. Check the log file (`./butter-install.log` by default) for detailed output.
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
