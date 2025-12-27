#!/usr/bin/env bash
# ModularShell Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MODULARSHELL_DIR="$HOME/.config/bash"
CONFIG_BACKUP_DIR="$HOME/.config/bash.backup.$(date +%Y%m%d_%H%M%S)"
BASHRC_BACKUP="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"

# Print colored message
print_msg() {
    echo -e "${2}${1}${NC}"
}

# Print header
print_header() {
    echo
    print_msg "✨ ModularShell Installer" "$YELLOW"
    print_msg "==========================" "$YELLOW"
    echo
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup existing configuration
backup_existing() {
    if [ -d "$MODULARSHELL_DIR" ] || [ -f "$HOME/.bashrc" ]; then
        print_msg "📦 Backing up existing configuration..." "$BLUE"
        
        # Backup .bashrc if it exists
        if [ -f "$HOME/.bashrc" ]; then
            cp "$HOME/.bashrc" "$BASHRC_BACKUP"
            print_msg "   ✓ Backed up .bashrc" "$GREEN"
        fi

        # Backup existing bash config directory
        if [ -d "$MODULARSHELL_DIR" ]; then
            cp -a "$MODULARSHELL_DIR" "$CONFIG_BACKUP_DIR"
            rm -rf "$MODULARSHELL_DIR"
            print_msg "   ✓ Backed up existing config to $CONFIG_BACKUP_DIR" "$GREEN"
        fi
    fi
}

install_modularshell() {
    print_msg "🚀 Installing ModularShell..." "$BLUE"
    
    # Check if required files exist
    if [ ! -d "bash" ] || [ ! -f "bashrc.example" ]; then
        print_msg "   ❌ Error: ModularShell files not found!" "$RED"
        print_msg "   Please run the installer from the cloned modularshell directory" "$YELLOW"
        exit 1
    fi
    
    # Create config directory
    mkdir -p "$MODULARSHELL_DIR/functions"
    # Copy configuration files
    cp -r bash/* "$MODULARSHELL_DIR/"
    print_msg "   ✓ Copied configuration files" "$GREEN"

    # Install main bashrc
    cp bashrc.example "$HOME/.bashrc"
    print_msg "   ✓ Installed .bashrc" "$GREEN"
}

install_man_page() {
    local man_source="man/man7/modularshell.7"
    local man_dir="$HOME/.local/share/man/man7"

    if [ ! -f "$man_source" ]; then
        print_msg "   ! Manual page not found: $man_source" "$YELLOW"
        return
    fi

    mkdir -p "$man_dir"
    cp "$man_source" "$man_dir/"
    print_msg "   Installed manual page (man modularshell)" "$GREEN"

    if command_exists mandb; then
        mandb -q "$HOME/.local/share/man" >/dev/null 2>&1 || true
    fi
}

# Install optional dependencies
install_dependencies() {
    echo
    # Use /dev/tty to read from terminal even when piped
    if [[ -t 0 ]]; then
        # Normal interactive mode
        read -p "$(echo -e ${YELLOW}Would you like to install recommended tools? [fzf, ripgrep] \(y/N\): ${NC})" -n 1 -r
    elif [[ -e /dev/tty ]]; then
        # Piped mode but terminal available
        read -p "$(echo -e ${YELLOW}Would you like to install recommended tools? [fzf, ripgrep] \(y/N\): ${NC})" -n 1 -r </dev/tty
    else
        # No terminal available at all (like in CI/CD)
        print_msg "   ℹ Skipping optional tools (no terminal available)" "$YELLOW"
        return
    fi
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_msg "📦 Installing recommended tools..." "$BLUE"
        
        # Detect package manager
        if command_exists apt; then
            PKG_MGR="apt"
            INSTALL_CMD="sudo apt install -y"
        elif command_exists dnf; then
            PKG_MGR="dnf"
            INSTALL_CMD="sudo dnf install -y"
        elif command_exists pacman; then
            PKG_MGR="pacman"
            INSTALL_CMD="sudo pacman -S --noconfirm"
        elif command_exists brew; then
            PKG_MGR="zypper"
            INSTALL_CMD="zypper install"
        else
            print_msg "   ⚠ Could not detect package manager" "$YELLOW"
            return
        fi
        
        # Install fzf
        if ! command_exists fzf; then
            print_msg "   Installing fzf..." "$BLUE"
            $INSTALL_CMD fzf
        else
            print_msg "   ✓ fzf already installed" "$GREEN"
        fi
        
        # Install ripgrep
        if ! command_exists rg; then
            print_msg "   Installing ripgrep..." "$BLUE"
            $INSTALL_CMD ripgrep
        else
            print_msg "   ✓ ripgrep already installed" "$GREEN"
        fi
        
        # Try to install eza (might not be available in all repos)
        if ! command_exists eza && ! command_exists exa; then
            print_msg "   Installing eza/exa..." "$BLUE"
            $INSTALL_CMD eza 2>/dev/null || $INSTALL_CMD exa 2>/dev/null || print_msg "   ⚠ eza/exa not available" "$YELLOW"
        else
            print_msg "   ✓ eza/exa already installed" "$GREEN"
        fi
    fi
}

# Main installation
main() {
    print_header
    
    # Check bash version
    if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
        print_msg "⚠ Warning: Bash version 4+ recommended (you have $BASH_VERSION)" "$YELLOW"
    fi
    
    # Skip confirmation if called with --yes flag or from another installer
    if [[ "$1" != "--yes" ]] && [[ -z "$SKIP_CONFIRMATION" ]]; then
        # Confirm installation
        echo "This will install ModularShell to $MODULARSHELL_DIR"
        echo "Your existing configuration will be backed up."
        echo
        read -p "$(echo -e ${YELLOW}Continue with installation? \(y/N\): ${NC})" -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_msg "Installation cancelled" "$RED"
            exit 1
        fi
    fi
    
    # Run installation steps
    backup_existing
    install_modularshell
    install_man_page
    install_dependencies
    
    # Success message
    echo
    print_msg "✨ ModularShell installed successfully!" "$GREEN"
    echo
    print_msg "To get started:" "$BLUE"
    print_msg "  1. Reload your shell: source ~/.bashrc" "$NC"
    print_msg "  2. Check the README for full documentation" "$NC"
    echo
    print_msg "Enjoy your ModularShell experience!" "$YELLOW"
}

# Run main function
main "$@"
