#!/usr/bin/env bash
# DESC: Download and install popular Nerd Fonts for terminal and code editor use

set -euo pipefail

# Nerd Fonts Installer
# A script to download and install popular Nerd Fonts

# Set color variables for better readability
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../libs/text_mods.bash"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
check_dependencies() {
    local deps=("wget" "unzip")
    
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            echo -e "${YELLOW}Installing required dependency: $dep${NC}"
            sudo apt install -y "$dep" || { 
                echo -e "${RED}Failed to install $dep. Please install it manually.${NC}"
                exit 1
            }
        fi
    done
    echo -e "${GREEN}All dependencies are satisfied.${NC}"
}

# Array of font names
fonts=(
    "JetBrainsMono"
    "FiraCode"
    "Hack"
    "CascadiaCode"
    "SourceCodePro"
    "RobotoMono"
    "Meslo"
    "UbuntuMono"
    "Inconsolata"
    "VictorMono"
    "Mononoki"
    "Terminus"
    "Lilex"
)

# Font version and directories
FONT_VERSION="v3.4.0"
FONTS_DIR="$HOME/.local/share/fonts"
TEMP_DIR="$(mktemp -d)"

# Wallpapers directories
WALLPAPER_SRC_DIR="$script_dir/Wallpapers"
WALLPAPER_DST_DIR="$HOME/.local/share/wallpapers"

# Create necessary directories
mkdir -p "$FONTS_DIR"

# Install wallpapers from Wallpapers/ into ~/.local/share/wallpapers/
install_wallpapers() {
    echo -e "\n${BLUE}===== Wallpapers Installer =====${NC}"
    echo -e "${BLUE}Copying wallpapers from:${NC} $WALLPAPER_SRC_DIR"
    echo -e "${BLUE}Copying wallpapers to:${NC}   $WALLPAPER_DST_DIR"

    if [ ! -d "$WALLPAPER_SRC_DIR" ]; then
        echo -e "${YELLOW}➤ Wallpapers directory not found. Skipping.${NC}"
        echo -e "${YELLOW}  Expected: $WALLPAPER_SRC_DIR${NC}"
        return 0
    fi

    mkdir -p "$WALLPAPER_DST_DIR"

    # Copy everything under Wallpapers/ (including subfolders)
    # Using '/.' preserves contents even if the directory is empty.
    if cp -a "$WALLPAPER_SRC_DIR/." "$WALLPAPER_DST_DIR/"; then
        echo -e "${GREEN}✓ Successfully installed wallpapers into:${NC} $WALLPAPER_DST_DIR"
    else
        echo -e "${RED}✗ Failed to copy wallpapers.${NC}"
        return 1
    fi
}

# Font installation function
install_nerd_fonts() {
    local installed=0
    local skipped=0
    local failed=0
    
    echo -e "\n${BLUE}===== Nerd Fonts Installer =====${NC}"
    echo -e "${BLUE}Installing fonts to:${NC} $FONTS_DIR"
    
    # Start timer
    local start_time=$(date +%s)
    
    # First check dependencies
    check_dependencies
    
    # Process each font in the array
    for font in "${fonts[@]}"; do
        echo -e "\n${BLUE}Processing:${NC} $font"
        
        # Check if font is already installed
        if [ -d "$FONTS_DIR/$font" ] && [ "$(ls -A "$FONTS_DIR/$font" 2>/dev/null)" ]; then
            echo -e "  ${YELLOW}➤ $font is already installed. Skipping.${NC}"
            ((skipped++))
        else
            echo -e "  ${BLUE}⚙ Downloading $font...${NC}"
            
            # Download the font zip file with a timeout
            if wget --timeout=30 -q --show-progress "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${font}.zip" -P "$TEMP_DIR"; then
                echo -e "  ${BLUE}⚙ Extracting $font...${NC}"
                
                # Create font directory
                mkdir -p "$FONTS_DIR/$font"
                
                # Extract the font with error handling
                if unzip -q "$TEMP_DIR/${font}.zip" -d "$FONTS_DIR/$font/" 2>/dev/null; then
                    echo -e "  ${GREEN}✓ Successfully installed $font${NC}"
                    ((installed++))
                else
                    echo -e "  ${RED}✗ Failed to extract $font${NC}"
                    rm -rf "$FONTS_DIR/$font" # Clean up the incomplete font directory
                    ((failed++))
                fi
                
                # Clean up the zip file
                rm -f "$TEMP_DIR/${font}.zip"
            else
                echo -e "  ${RED}✗ Failed to download $font${NC}"
                ((failed++))
            fi
        fi
    done
    
    # Update font cache
    echo -e "\n${BLUE}Updating font cache...${NC}"
    fc-cache -f
    
    # End timer and calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Print summary
    echo -e "\n${BLUE}====== Installation Summary ======${NC}"
    echo -e "  ${GREEN}✓ Successfully installed:${NC} $installed fonts"
    echo -e "  ${YELLOW}➤ Already installed (skipped):${NC} $skipped fonts"
    echo -e "  ${RED}✗ Failed to install:${NC} $failed fonts"
    echo -e "  ${BLUE}⏱ Total time:${NC} $duration seconds"
    echo -e "${BLUE}==============================${NC}"
    echo -e "Fonts installed in: $FONTS_DIR"
}

# Handle script interruption
cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Run the installation
install_nerd_fonts

# Install wallpapers
install_wallpapers

echo -e "\n${GREEN}Installation process completed.${NC}"
