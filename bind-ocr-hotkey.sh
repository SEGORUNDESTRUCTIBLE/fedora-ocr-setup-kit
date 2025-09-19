#!/usr/bin/env bash
set -euo pipefail
APP="$HOME/.local/bin/screen-ocr"
[ -x "$APP" ] || { echo "ERROR: $APP not found"; exit 1; }
if command -v gsettings >/dev/null 2>&1 && gsettings list-schemas | grep -q org.gnome.settings-daemon.plugins.media-keys; then
  BASE=org.gnome.settings-daemon.plugins.media-keys
  PATHSTR="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/screen-ocr/"
  CURR=$(gsettings get $BASE custom-keybindings | sed 's/^@as //')
  if ! printf '%s' "$CURR" | grep -q "screen-ocr"; then
    if [ "$CURR" = "[]" ] || [ "$CURR" = "@as []" ]; then NEW="['$PATHSTR']"; else NEW="$(printf '%s' "$CURR" | sed "s/]$/, '$PATHSTR']/")"; fi
    gsettings set $BASE custom-keybindings "$NEW"
  fi
  SCHEMA="$BASE.custom-keybinding:$PATHSTR"
  gsettings set "$SCHEMA" name 'Screen OCR'
  gsettings set "$SCHEMA" command "$APP"
  gsettings set "$SCHEMA" binding '<Super>z'
  echo "✔ GNOME: bound Super+Z"
  exit 0
fi
KWRC=$(command -v kwriteconfig6 || command -v kwriteconfig5 || true)
KQUIT=$(command -v kquitapp6 || command -v kquitapp5 || true)
KACCEL=$(command -v kglobalaccel6 || command -v kglobalaccel5 || true)
if [ -n "${KWRC:-}" ]; then
  mkdir -p "$HOME/.local/share/applications"
  DESK="$HOME/.local/share/applications/screen-ocr.desktop"
  cat > "$DESK" <<EOD
[Desktop Entry]
Name=Screen OCR
Exec=$APP
Icon=accessories-screenshot
Type=Application
Categories=Utility;
EOD
  CFG="$HOME/.config/kglobalshortcutsrc"
  "$KWRC" --file "$CFG" --group "screen-ocr.desktop" --key "_launch" "Meta+Z,Meta+Z,Screen OCR"
  [ -n "${KQUIT:-}" ] && "$KQUIT" kglobalaccel >/dev/null 2>&1 || true
  [ -n "${KACCEL:-}" ] && "$KACCEL" >/dev/null 2>&1 || true
  echo "✔ KDE: bound Meta+Z"
  exit 0
fi
echo "Could not detect GNOME/KDE. Bind manually."
