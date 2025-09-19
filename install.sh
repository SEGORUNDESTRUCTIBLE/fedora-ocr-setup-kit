#!/usr/bin/env bash
set -euo pipefail
sudo dnf install -y tesseract tesseract-langpack-eng ImageMagick wl-clipboard xclip spectacle gnome-screenshot grim slurp
mkdir -p "$HOME/.local/bin"
install -Dm755 ./screen-ocr "$HOME/.local/bin/screen-ocr"
chmod +x ./bind-ocr-hotkey.sh
bash ./bind-ocr-hotkey.sh
echo "✔ Installed screen-ocr and bound Super/Meta+Z"
