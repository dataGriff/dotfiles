#!/bin/bash
set -e

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
source "$DOTFILES/macos/settings.sh"

for entry in "${MACOS_SETTINGS[@]}"; do
  IFS='|' read -r domain key type value <<< "$entry"
  defaults write "$domain" "$key" "-$type" "$value"
  echo "  set $domain $key = $value"
done

for app in "${MACOS_RESTART[@]}"; do
  killall "$app" 2>/dev/null || true
done

echo "macOS settings applied."
echo "Note: KeyRepeat/InitialKeyRepeat fully take effect after log-out/in."
echo "Note: digital menu-bar time comes from the Stats app (see /macos-setup)."
