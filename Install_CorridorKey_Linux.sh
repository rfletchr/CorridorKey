#!/usr/bin/env bash
set -e

# Usage: download <url> <output_path>
download() {
    local url="$1"
    local output="$2"
    if command -v curl &> /dev/null; then
        curl -L -o "$output" "$url"
    elif command -v wget &> /dev/null; then
        wget -O "$output" "$url"
    else
        echo "[ERROR] Neither curl nor wget is installed. Please install one and try again."
        exit 1
    fi
}

echo "==================================================="
echo "    CorridorKey - Linux Auto-Installer"
echo "==================================================="
echo ""

# 1. Check for uv — install it automatically if missing
if ! command -v uv &> /dev/null; then
    echo "[INFO] uv is not installed. Installing now..."
    download https://astral.sh/uv/install.sh /tmp/uv-install.sh && sh /tmp/uv-install.sh
    # uv installs to ~/.local/bin; add it to PATH for the rest of this session
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v uv &> /dev/null; then
        echo "[ERROR] uv was installed but cannot be found on PATH."
        echo "Please open a new terminal and run this script again."
        exit 1
    fi
    echo "[INFO] uv installed successfully."
    echo ""
fi

# 2. Warn if ffmpeg is missing
if ! command -v ffmpeg &> /dev/null; then
    echo "[WARN] ffmpeg is not installed. Some features may not work correctly."
    echo "       Please install ffmpeg using your system package manager."
    echo ""
fi

# 3. Install all dependencies
echo "[1/2] Installing Dependencies (this may take a while on first run)..."
echo "      uv will automatically download Python if needed."
uv sync

# 4. Download model weights
echo ""
echo "[2/2] Downloading CorridorKey Model Weights..."
mkdir -p "CorridorKeyModule/checkpoints"

if [ ! -f "CorridorKeyModule/checkpoints/CorridorKey.pth" ]; then
    echo "Downloading CorridorKey.pth..."
    download "https://huggingface.co/nikopueringer/CorridorKey_v1.0/resolve/main/CorridorKey_v1.0.pth" \
        "CorridorKeyModule/checkpoints/CorridorKey.pth"
else
    echo "CorridorKey.pth already exists, skipping download."
fi

echo ""
echo "==================================================="
echo "  Setup Complete! You are ready to key!"
echo "  Run: ./CorridorKey_DRAG_CLIPS_HERE_local.sh /path/to/your/clips"
echo "==================================================="
