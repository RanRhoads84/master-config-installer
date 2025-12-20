# 🧈 Butter WezTerm

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![Debian](https://img.shields.io/badge/debian-based-red.svg)](https://www.debian.org/)
[![WezTerm](https://img.shields.io/badge/WezTerm-nightly-orange.svg)](https://wezfurlong.org/wezterm/)
[![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)

A simple WezTerm terminal emulator installer for Linux systems.

> **Note:** This script installs WezTerm terminal emulator on Debian-based systems.

## Features
- Installs WezTerm nightly build with a single command
- Custom configuration automatically applied
- Clean installation process

## 📋 Requirements

- **OS:** Debian-based Linux distribution
- **Tools:** `wget` for downloading files
- **Permissions:** `sudo` privileges for installation

## 🚀 Quick Start
To install WezTerm:
```bash
# Clone repository
git clone https://codeberg.org/justaguylinux/butterscripts.git
# Navigate to wezterm directory
cd butterscripts/wezterm
# Make executable
chmod +x install_wezterm.sh
# Run the installer
./install_wezterm.sh
```

## ⚙️ How It Works

The installation script performs the following steps:

1. **Repository Setup** - Adds the WezTerm repository and GPG key
2. **Installation** - Installs the latest WezTerm nightly build
3. **Configuration** - Sets up configuration in `~/.config/wezterm`
4. **Custom Config** - Applies the optimized configuration from this repository
5. **Default Terminal** - Sets WezTerm as the default terminal emulator (Debian 13+)
   - Configures the system to use WezTerm when file managers like Thunar launch a terminal
   - Replaces the default lxterminal

## ✨ Configuration Features

The included configuration provides a powerful, customizable terminal experience:

### 🎨 Color Scheme
- GitHub Dark theme with carefully selected colors
- 98% background opacity for subtle transparency
- Custom tab bar styling with blue active tabs

### ⌨️ Keybindings (ALT + key)

**Pane Management:**
- `ALT + Enter` - Split pane horizontally (50/50)
- `ALT + SHIFT + Enter` - Split pane vertically (50/50)
- `ALT + w` - Close current pane (with confirmation)
- `ALT + Arrow Keys` - Navigate between panes

**Tab Management:**
- `ALT + t` - New tab
- `ALT + q` - Close tab (with confirmation)
- `ALT + 1-8` - Switch to tab 1-8
- `CTRL+ALT + 1-8` - Move tab to position 1-8
- `CTRL+ALT + Left/Right` - Move tab left/right relative
- `CTRL+ALT + Up/Down` - Switch to last active tab

**Other:**
- `ALT + c` - Copy selection
- `ALT + v` - Paste from clipboard
- `ALT + =` - Increase font size
- `ALT + -` - Decrease font size
- `ALT + 0` - Reset font size

### 🔤 Font Settings
- Primary: Lilex Nerd Font Mono Regular (size 16)
- Fallbacks: SauceCodePro, FiraCode, Symbols Nerd Fonts
- Window frame: Lilex Nerd Font Mono Italic (size 12)
- Line height: 1.1
- Optimized rendering with FreeType (Light/HorizontalLcd)

### ⚡ Performance
- 120 FPS max refresh rate
- OpenGL frontend with EGL preference
- Hardware acceleration enabled
- Optimized for responsiveness

### 🖱️ Mouse Bindings
- Right-click to copy selection
- Middle-click to split pane horizontally
- Shift + Middle-click to close pane

## Project Info
Made for Linux users who want a powerful terminal emulator with simple installation.

---
## 🧈 Built For
- **Butter Bean (butterbian) Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast
> Butterbian Linux is a joke... for now.

---

## ☕ Support

If this setup has been helpful, consider buying me a coffee:

<a href="https://www.buymeacoffee.com/justaguylinux" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy me a coffee" /></a>

## 📺 Watch on YouTube

Want to see how it looks and works?
🎥 Check out [JustAGuy Linux on YouTube](https://www.youtube.com/@JustAGuyLinux)

---
More scripts coming soon. Use what you need, fork what you like, tweak everything.
