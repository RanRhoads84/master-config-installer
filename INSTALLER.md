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

Notes:
- Use `--log <file>` to change the logfile location.
- The script will attempt to skip already-installed packages and supports common package managers (`apt`, `dnf`, `pacman`, `zypper`, `apk`, `brew`).
- Package names may vary by distribution; edit `packages/<pm>.txt` to customize.
