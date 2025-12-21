# ModularConfig Suite Installer (CSI)

This repository includes the CSI (Config Suite Installer) entrypoint: `install.sh`.

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

The installer also includes an optional vim configuration setup that installs dependencies (git, vim, ripgrep, fzf, fd) and copies a custom vimrc with plugins.

## Flatpak Support

When prompted, `install.sh` can follow the official instructions from https://flatpak.org/setup/ by installing `flatpak` through the detected package manager, adding the Flathub remote within the user scope, and running `flatpak update --assumeyes` so the runtime catalog stays current.

## Package Organization

Packages are organized in a consolidated list (`packages/consolidated.txt`) by the same categories you encounter in the installer menu. Examples include:
- Browsers
- Build Dependencies
- Database
- Development Tools
- Fonts & Themes
- Network Tools
- Office & Productivity
- Security Tools
- Shell Tools
- System Monitoring
- System Services
- System Tools
- Terminal Emulators
- Text Editors
- Virtualization
- Web Servers & Tools

The installer automatically handles package name differences between distributions.

- Use `--log <file>` to change the logfile location (defaults to `./modularconfig-install.log`).
- The script will attempt to skip already-installed packages and supports common package managers (`apt`, `dnf`, `pacman`, `zypper`, `apk`, `brew`).
- Package names may vary by distribution; edit `packages/<pm>.txt` to customize.
