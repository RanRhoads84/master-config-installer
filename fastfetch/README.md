# 🧈 Butter Fastfetch

A simple Fastfetch installer and configurator for Linux systems.

> **Note:** The setup process will ask for confirmation before installation and will automatically configure shell aliases for bash, zsh, and fish.

## Features
- Installs and configures Fastfetch with a single command
- Works with Bash, Zsh, Fish, and other shells
- Multiple configuration options with pre-configured themes
- Automatic shell alias configuration
- Installs from official prebuilt packages (no compilation needed)

## Requirements
- Debian-based Linux operating system
- wget for downloading packages
- sudo privileges for installation

## Installation
To set up Butter Fastfetch:
```bash
# Clone repository
git clone https://codeberg.org/justaguylinux/butterscripts.git

# Navigate to fastfetch directory
cd butterscripts/fastfetch

# Make executable
chmod +x install_fastfetch.sh

# Run the installer
./install_fastfetch.sh
```

## Usage
```bash
# Run fastfetch with default configuration
ff

# Run fastfetch with minimal configuration
fastfetch -c ~/.config/fastfetch/minimal.jsonc

# Run fastfetch with server configuration
fastfetch -c ~/.config/fastfetch/server.jsonc
```

## How It Works
The script:
1. Checks if Fastfetch is already installed
2. Downloads and installs the latest Fastfetch `.deb` package if needed
3. Downloads configuration files from Codeberg to ~/.config/fastfetch/
4. Creates shell aliases for convenient usage (bash, zsh, fish)
5. Provides multiple configuration presets for different use cases

## Project Info
Made for Linux users who want a simple, elegant system information display tool.

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
