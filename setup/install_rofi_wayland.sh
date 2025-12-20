#!/bin/bash
# DESC: Build and install rofi-wayland with dependencies
set -e
# install-rofi-wayland.sh: Build and install rofi-wayland

# Print current directory for debugging
echo "Current directory: $(pwd)"

# Check if rofi is already installed
if command -v rofi &>/dev/null; then
    echo "Rofi is already installed. Skipping installation."
    exit 0
fi

echo "Installing dependencies for rofi-wayland..."
sudo apt-get install -y \
    libpango1.0-dev libpangocairo-1.0-0 libcairo2-dev \
    libglib2.0-dev libgdk-pixbuf-2.0-dev libstartup-notification0-dev \
    libxkbcommon-dev libxkbcommon-x11-dev libxcb-xkb-dev \
    libxcb-randr0-dev libxcb-xinerama0-dev libxcb-ewmh-dev \
    libxcb-icccm4-dev libxcb-cursor-dev libxcb-util-dev \
    libxcb-keysyms1-dev \
    libwayland-dev wayland-protocols meson ninja-build \
    bison flex check

# Use the temp directory provided by the main script, or create a unique one if run standalone
ROFI_BUILD_DIR="${SCRIPT_TEMP_DIR:-/tmp/rofi-build-$(date +%s)-$$}"
echo "Using build directory: $ROFI_BUILD_DIR"

# Create directory (main script should have created it already if called from there)
mkdir -p "$ROFI_BUILD_DIR"

echo "Cloning rofi-wayland repository..."
git clone https://github.com/lbonn/rofi "$ROFI_BUILD_DIR/source" || {
    echo "Failed to clone rofi-wayland."
    exit 1
}

echo "Building rofi-wayland..."
cd "$ROFI_BUILD_DIR/source"
meson setup --buildtype=release build
ninja -C build

echo "Installing rofi-wayland..."
sudo ninja -C build install

# Only clean up if run standalone (the main script handles cleanup otherwise)
if [ -z "$SCRIPT_TEMP_DIR" ]; then
    echo "Cleaning up build directory..."
    rm -rf "$ROFI_BUILD_DIR"
fi

echo "Rofi-wayland installation completed successfully."
