# 🎨 Butter Theming
A simple theming installer for Linux systems.
> **Note:** These scripts install GTK themes, icon packs, and Nerd Fonts on Debian-based systems.

## Features
- Installs Orchis GTK theme and Colloid icon theme with a single command
- Installs popular Nerd Fonts for enhanced terminal and editor experience
- Custom configuration automatically applied
- Clean installation process with status indicators

## Requirements
- Debian-based Linux distribution
- git for cloning repositories
- sudo privileges for installing dependencies
- wget/unzip for font installation

## Installation
To install the themes and fonts:
```bash
# Clone repository
git clone https://codeberg.org/justaguylinux/butterscripts.git
# Navigate to theming directory
cd butterscripts/theming
# Make scripts executable
chmod +x install-theme.sh nerdfonts.sh
# Run the theme installer
./install-theme.sh
# Run the font installer
./nerdfonts.sh
```

## How It Works
The scripts:

### install-theme.sh
1. Installs the Orchis Grey Dark GTK theme from https://github.com/vinceliuice/Orchis-theme
2. Installs the Colloid Grey Dracula Dark icon theme from https://github.com/vinceliuice/Colloid-icon-theme
3. Configures GTK2 and GTK3 settings to use the installed themes

### nerdfonts.sh
1. Checks for and installs necessary dependencies (unzip)
2. Downloads and installs popular Nerd Fonts from the official repository
3. Only installs fonts that aren't already on your system
4. Updates font cache to make new fonts immediately available

## Included Nerd Fonts
- JetBrainsMono
- FiraCode
- Hack
- CascadiaCode
- SourceCodePro
- RobotoMono
- Meslo
- UbuntuMono
- Inconsolata
- VictorMono
- Mononoki
- Terminus

## Project Info
Made for Linux users who want a consistent and beautiful desktop theme with minimal effort.

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
