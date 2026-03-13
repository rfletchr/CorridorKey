#!/usr/bin/env bash
set -e

print_error() {
    echo -e "\e[1;31mERROR:\e[0;31m $*\e[0m" >&2
}

print_info() {
    echo -e "\e[90mINFO: $*\e[0m"
}


print_step() {
    echo -e "\e[1;36m$*\e[0m"
}

print_banner() {
    echo -e "\e[1;36m$*\e[0m"
}

trap 'print_error "Installation failed. See above for details."' ERR

# Usage: download <url> <output_path>
download() {
    local url="$1"
    local output="$2"
    if command -v curl &> /dev/null; then
        curl -L -o "$output" "$url"
    elif command -v wget &> /dev/null; then
        wget -O "$output" "$url"
    else
        print_error "Neither curl nor wget is installed. Please install one and try again."
        exit 1
    fi
}

# Always run from the directory the script lives in
cd "$(dirname "${BASH_SOURCE[0]}")"

print_banner "==================================================="
print_banner "    CorridorKey - Linux Auto-Installer"
print_banner "==================================================="
echo ""

# Sanity check — make sure we're in the right place
if [ ! -f "pyproject.toml" ]; then
    print_error "pyproject.toml not found. Please run this script from the CorridorKey directory."
    exit 1
fi

# 1. Check for uv — install it automatically if missing
if ! command -v uv &> /dev/null; then
    print_info "uv is not installed. Installing now..."
    download https://astral.sh/uv/install.sh /tmp/uv-install.sh && sh /tmp/uv-install.sh
    # uv installs to ~/.local/bin; add it to PATH for the rest of this session
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v uv &> /dev/null; then
        print_error "uv was installed but cannot be found on PATH."
        print_error "Please open a new terminal and run this script again."
        exit 1
    fi
    print_info "uv installed successfully."
    echo ""
fi

# 2. Install all dependencies
print_step "[1/2] Installing Dependencies (this may take a while on first run)..."
print_info "uv will automatically download Python if needed."
uv sync

# 4. Download model weights
echo ""
print_step "[2/2] Downloading CorridorKey Model Weights..."
mkdir -p "CorridorKeyModule/checkpoints"

if [ ! -f "CorridorKeyModule/checkpoints/CorridorKey.pth" ]; then
    print_info "Downloading CorridorKey.pth..."
    download "https://huggingface.co/nikopueringer/CorridorKey_v1.0/resolve/main/CorridorKey_v1.0.pth" \
        "CorridorKeyModule/checkpoints/CorridorKey.pth"
else
    print_info "CorridorKey.pth already exists, skipping download."
fi

echo ""
print_banner "==================================================="
print_banner "  Setup Complete! You are ready to key!"
print_banner "  Run: ./CorridorKey_DRAG_CLIPS_HERE_local.sh /path/to/your/clips"
print_banner "==================================================="
