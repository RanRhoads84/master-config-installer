# 🧈 Discord Updater

Skip Discord's annoying update prompts. Just run `discord` from your terminal.

## Why Use This?

**The Problem:** Discord on Linux doesn't auto-update like Windows. Their .deb package is broken and outdated. When Discord says "update available", your options are:
1. **Manual way:** Download tarball, extract, move to /opt/, create symlinks (10 minutes of frustration)
2. **This script:** Type `discord` in terminal (10 seconds)

**Primary use case:** When Discord prompts you to update:
1. Close Discord
2. Run `discord` in your terminal
3. Done - latest version installed

Also useful for:
- Initial Discord installation
- Clean reinstalls when something breaks
- Uninstalling Discord completely

## Features
- One command does everything: `discord`
- Automatic first-time setup (no manual configuration needed)
- Works with Bash, Zsh, Fish, and other shells
- Self-installs to `~/.local/bin` for global access
- Automatic shell environment configuration
- Clean uninstallation option
- Uses wget or curl (automatically detects which you have)

## Requirements
- Linux-based operating system
- wget or curl for downloading files
- sudo privileges for Discord installation

## Installation

**Quick setup (copy and paste this):**
```bash
git clone https://codeberg.org/justaguylinux/butterscripts.git
cd butterscripts/discord
chmod +x discord
./discord install
```

That's it! The first run automatically:
- Installs the updater script to `~/.local/bin`
- Adds `~/.local/bin` to your PATH (if needed)
- Downloads and installs Discord

**From then on:** Whenever Discord prompts you to update, just type `discord` in your terminal and it's done.

## Usage

```bash
# Install or update Discord (first time does automatic setup)
discord

# Uninstall Discord completely
discord uninstall

# Show help
discord help
```

## How It Works
The script:
1. Downloads the latest Discord Linux package
2. Extracts it to /opt/Discord
3. Creates necessary symbolic links and desktop entries
4. Handles cleanup during updates/uninstallation

## Project Info
Made for Linux Discord users who want simple installation and updates.

---

## 🧈 Built For

- **Butter Bean (butterbian) Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast

> Butterbian Linux is a joke... for now.

---

## 📫 Author

**JustAGuy Linux**  
🎥 [YouTube](https://youtube.com/@JustAGuyLinux)  

---

More scripts coming soon. Use what you need, fork what you like, tweak everything.
