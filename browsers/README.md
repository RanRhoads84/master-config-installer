# 🌐 Browser Installation Script

Automated installer for popular web browsers on Debian-based systems.

> **Note:** This script installs browsers from their official sources rather than potentially outdated Debian repositories.

## 🔧 Features

- **Smart Detection** - Checks if browsers are already installed
- **Repository Management** - Properly configures APT repositories and GPG keys
- **Conflict Resolution** - Handles Firefox/Firefox ESR conflicts intelligently
- **Clean Installation** - Removes old repository files before installing
- **AppImage Support** - Zen Browser via AppImage (no root required)
- **Error Handling** - Graceful failure handling with informative messages

## ⚙️ Requirements

- Debian-based operating system
- sudo privileges
- Internet connection
- Basic dependencies: `wget`, `curl`, `apt-transport-https`, `gnupg`

## 🚀 Usage

### Interactive Installation

```bash
cd butterscripts/browsers
./install_browsers.sh
```

### From ButterScripts

```bash
cd butterscripts/setup
./optional_tools.sh
# Select option 4: Browsers
```

The script will present a menu where you can:
- Select individual browsers by number
- Install multiple browsers (e.g., "1 3 5")
- Install all browsers with option 8
- Exit with option 9

## 📋 Supported Browsers

- **Helium Browser** - Excellent modern browser focused on speed and simplicity (AppImage) - [helium.computer](https://helium.computer)
- **Firefox Latest** - Latest Firefox from Mozilla repository
- **Firefox ESR** - Extended Support Release from Debian repositories
- **LibreWolf** - Privacy-focused Firefox fork
- **Brave** - Privacy-focused browser with built-in ad blocking
- **Floorp** - Customizable Firefox-based browser
- **Zen Browser** - Minimalist browser (AppImage)
- **Chromium** - Open-source Chrome alternative

## 📦 Installation Details

### Helium Browser
- Downloads AppImage from [helium.computer](https://helium.computer) to `~/Applications/HeliumBrowser.AppImage`
- Creates desktop entry for menu integration
- No system package installation required

### Firefox Latest
- Adds Mozilla APT repository
- Configures package priorities
- Handles coexistence with Firefox ESR

### LibreWolf
- Uses extrepo for repository management
- Automatically enables official LibreWolf repository

### Brave
- Downloads official GPG key
- Adds Brave browser APT repository

### Floorp
- Adds Ablaze repository
- Installs latest Floorp release

### Zen Browser
- Downloads AppImage to `~/Applications/`
- Creates desktop entry for menu integration
- No system package installation required

### Chromium
- Installs from Debian repositories
- No additional repositories needed

## 🛡️ Security

- All GPG keys are verified before repository addition
- Uses signed repositories where available
- Follows best practices for APT repository management

## 🔍 Troubleshooting

If installation fails:
1. Check internet connection
2. Verify sudo privileges
3. Update system: `sudo apt update && sudo apt upgrade`
4. Check available disk space

For browser-specific issues, the script provides detailed error messages and suggests manual installation steps.

---

## 📄 License

Part of the [ButterScripts](https://codeberg.org/justaguylinux/butterscripts) collection by [JustAGuy Linux](https://www.youtube.com/@justaguylinux).
