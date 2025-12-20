# Unified Installer

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

The installer also includes an optional vim configuration setup that installs dependencies (git, vim, ripgrep, fzf, fd) and copies a custom vimrc with plugins.

## Package Organization

Packages are organized in a consolidated list (`packages/consolidated.txt`) by category:
- System Tools (git, curl, wget, vim, etc.)
- Development Tools (gcc, cmake, python, nodejs, etc.)
- Desktop Applications (browsers, editors, multimedia, etc.)
- System Services (cups, bluetooth, networking, etc.)

The installer automatically handles package name differences between distributions.

Notes:
- Use `--log <file>` to change the logfile location.
- The script will attempt to skip already-installed packages and supports common package managers (`apt`, `dnf`, `pacman`, `zypper`, `apk`, `brew`).
- Package names may vary by distribution; edit `packages/<pm>.txt` to customize.
