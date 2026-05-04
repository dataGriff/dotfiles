#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"

symlink() {
  ln -sf "$DOTFILES/$1" "$HOME/$2"
}

# Shell
symlink "zsh/.zshrc" ".zshrc"

# Git
symlink "git/.gitconfig" ".gitconfig"

# Ghostty
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

# Claude
mkdir -p "$HOME/.claude"
symlink "claude/CLAUDE.md" ".claude/CLAUDE.md"
symlink "claude/settings.json" ".claude/settings.json"

# VS Code settings
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_SETTINGS"
ln -sf "$DOTFILES/vscode/settings.json" "$VSCODE_SETTINGS/settings.json"

# Git local config (not committed — contains email/name)
if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo ""
  echo "ACTION REQUIRED: Create ~/.gitconfig.local with your git identity:"
  echo "  [user]"
  echo "    name = Your Name"
  echo "    email = your@email.com"
fi

echo "All dotfiles linked."
