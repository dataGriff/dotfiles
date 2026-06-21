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

# mise (runtime manager)
mkdir -p "$HOME/.config/mise"
ln -sf "$DOTFILES/mise/config.toml" "$HOME/.config/mise/config.toml"
if command -v mise >/dev/null 2>&1; then
  mise trust "$DOTFILES/mise/config.toml"
  mise install
fi

# Claude
mkdir -p "$HOME/.claude"
symlink "claude/CLAUDE.md" ".claude/CLAUDE.md"
symlink "claude/settings.json" ".claude/settings.json"
symlink "claude/statusline-command.sh" ".claude/statusline-command.sh"

# Claude skills
mkdir -p "$HOME/.claude/skills"
for skill in "$DOTFILES/claude/skills"/*/; do
  [ -d "$skill" ] || continue
  name=$(basename "$skill")
  # -n prevents ln from dereferencing an existing symlink-to-dir and
  # creating the new link inside it on re-runs.
  ln -snf "$skill" "$HOME/.claude/skills/$name"
done

# VS Code settings
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_SETTINGS"
ln -sf "$DOTFILES/vscode/settings.json" "$VSCODE_SETTINGS/settings.json"

# Zed
mkdir -p "$HOME/.config/zed"
ln -sf "$DOTFILES/zed/settings.json" "$HOME/.config/zed/settings.json"

# Git local config (not committed — contains email/name)
if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo ""
  echo "ACTION REQUIRED: Create ~/.gitconfig.local with your git identity:"
  echo "  [user]"
  echo "    name = Your Name"
  echo "    email = your@email.com"
fi

echo "All dotfiles linked."
