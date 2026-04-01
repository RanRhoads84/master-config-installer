# ModularConfig Suite Installer (CSI)

This repository includes the CSI (Config Suite Installer) entrypoint: `install.sh`.

Quick examples:

```bash
# dry-run to preview actions
./install.sh --dry-run

# interactive install (choose groups)
./install.sh

# non-interactive: pick groups by name and assume yes
./install.sh --groups "Shell Tools" --yes
```

After package installs, the script can optionally run module installers (such as `vim-config` and the theming assets installer). If `packages/npm.txt` or `packages/cargo.txt` exist, it will also offer to install those package lists.

The installer also includes an optional vim configuration setup that installs dependencies (git, vim, ripgrep, fzf, fd) and copies a custom vimrc with plugins.

## Flatpak Support

When prompted, `install.sh` can follow the official instructions from https://flatpak.org/setup/ by installing `flatpak` through the detected package manager, adding the Flathub remote within the user scope, and running `flatpak update --assumeyes` so the runtime catalog stays current.

## Visual Studio Code

The installer can also configure the Microsoft VS Code repository and install `code` on `apt`, `dnf`, or `zypper` systems. It follows the steps described at https://code.visualstudio.com/docs/setup/linux by importing the signing key, creating the appropriate repo definition, and installing `code` so the application receives automatic updates through the standard package manager.

## Package Organization

Packages are organized in a consolidated list (`packages/pkg-list.txt`) by the same categories you encounter in the installer menu. Examples include:
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

The installer automatically handles package name differences between distributions.

- Use `--log <file>` to change the logfile location (defaults to `./modularconfig-install.log`).
- The script will attempt to skip already-installed packages and supports `apt`, `dnf`, `pacman`, and `zypper` (use `--pm` to override detection).
- Package names may vary by distribution; edit `packages/pkg-list.txt` to customize.
- Optional npm/cargo lists can be defined in `packages/npm.txt` and `packages/cargo.txt`.
