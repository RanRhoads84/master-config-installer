#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-/tmp/install-fastfetch}"
RELEASE_API="https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest"

fetch_release_json() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RELEASE_API"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$RELEASE_API"
  else
    echo "curl or wget is required to query fastfetch releases." >&2
    exit 1
  fi
}

download_file() {
  local url="$1"
  local destination="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$url" -o "$destination"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$destination" "$url"
  else
    echo "curl or wget is required to download fastfetch." >&2
    exit 1
  fi
}

find_asset_url() {
  local asset_name="$1"
  local url
  if url=$(printf '%s' "$RELEASE_JSON" | python3 - "$asset_name" <<'PY'
import json
import sys

data = json.load(sys.stdin)
name = sys.argv[1]
for asset in data.get('assets', []):
    if asset.get('name') == name:
        print(asset.get('browser_download_url'))
        sys.exit(0)
sys.exit(1)
PY
  ); then
    printf '%s' "$url"
    return 0
  fi
  return 1
}

append_alias() {
  local rc_file="$1"
  local alias_line="alias ff='fastfetch'"
  if [ ! -f "$rc_file" ]; then
    return
  fi
  if ! grep -Fxq "$alias_line" "$rc_file" >/dev/null 2>&1; then
    {
      printf '\n# Fastfetch shortcut\n%s\n' "$alias_line"
    } >> "$rc_file"
    echo "Added fastfetch alias to $rc_file"
  fi
}

add_fish_function() {
  local function_dir="$HOME/.config/fish/functions"
  local function_file="$function_dir/ff.fish"
  if ! command -v fish >/dev/null 2>&1; then
    return
  fi
  mkdir -p "$function_dir"
  if [ -f "$function_file" ]; then
    return
  fi
  cat <<'EOF' > "$function_file"
function ff
    fastfetch $argv
end
EOF
  echo "Created fish helper function at $function_file"
}

if [ "$(uname -s)" != "Linux" ]; then
  echo "This installer currently supports Linux hosts only." >&2
  exit 1
fi

raw_arch="$(uname -m)"
case "$raw_arch" in
  x86_64|amd64)
    target_arch="amd64"
    ;;
  aarch64|arm64)
    target_arch="aarch64"
    ;;
  armv7l)
    target_arch="armv7l"
    ;;
  armv6l)
    target_arch="armv6l"
    ;;
  i686)
    target_arch="i686"
    ;;
  ppc64le)
    target_arch="ppc64le"
    ;;
  riscv64)
    target_arch="riscv64"
    ;;
  s390x)
    target_arch="s390x"
    ;;
  *)
    echo "Unsupported architecture: $raw_arch" >&2
    exit 1
    ;;
esac

echo "Detected host: Linux/$raw_arch (using fastfetch release for $target_arch)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to inspect fastfetch releases." >&2
  exit 1
fi

RELEASE_JSON=""
if ! command -v fastfetch >/dev/null 2>&1; then
  echo "Fastfetch is not installed; downloading the latest release."
  RELEASE_JSON="$(fetch_release_json)"
  artifact_candidates=("fastfetch-linux-${target_arch}.tar.gz" "fastfetch-linux-${target_arch}-polyfilled.tar.gz")
  asset_url=""
  selected_asset=""
  for artifact in "${artifact_candidates[@]}"; do
    if asset_url=$(find_asset_url "$artifact"); then
      selected_asset="$artifact"
      break
    fi
  done
  if [ -z "$asset_url" ]; then
    echo "No fastfetch release artifact found for architecture: $target_arch" >&2
    exit 1
  fi
  echo "Downloading $selected_asset..."
  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  archive_path="$INSTALL_DIR/$selected_asset"
  download_file "$asset_url" "$archive_path"
  echo "Extracting fastfetch archive..."
  tar -xzf "$archive_path" -C "$INSTALL_DIR"
  fastfetch_binary="$(find "$INSTALL_DIR" -type f -name fastfetch -print -quit)"
  if [ -z "$fastfetch_binary" ]; then
    fastfetch_binary="$(find "$INSTALL_DIR" -type f -name '*fastfetch*' -print -quit)"
  fi
  if [ -z "$fastfetch_binary" ]; then
    echo "Unable to locate the fastfetch binary inside the archive." >&2
    exit 1
  fi
  echo "Installing fastfetch binary to /usr/local/bin"
  sudo install -m755 "$fastfetch_binary" /usr/local/bin/fastfetch
else
  echo "Fastfetch is already installed; skipping the binary download."
fi

config_destination="$HOME/.config/fastfetch"
mkdir -p "$config_destination"
for config_file in "$SCRIPT_DIR"/*.jsonc; do
  if [ ! -f "$config_file" ]; then
    continue
  fi
  install -m644 "$config_file" "$config_destination/$(basename "$config_file")"
done

echo "Configuration files placed in $config_destination"

append_alias "$HOME/.bashrc"
append_alias "$HOME/.zshrc"
add_fish_function

echo "Fastfetch setup complete. Use 'ff' for the default configuration or pass '-c <preset>' to select another profile."

