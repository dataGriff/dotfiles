#!/usr/bin/env bash
# Read-only dotfiles health audit. Never mutates anything.
# Reports: repo state, symlink integrity, brew drift, outdated packages, mise.
# Run via `task doctor`, the `dotfiles-doctor` alias, or the /dotfiles skill.

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
BREWFILE="$DOTFILES/Brewfile"

ok="✓"; warn="⚠"; bad="✗"
issues=0
note() { printf '  %s %s\n' "$1" "$2"; }
flag() { issues=$((issues + 1)); note "$@"; }
hr() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# ── 1. Repo state ─────────────────────────────────────────────────────────────
hr "1. Repo state"
cd "$DOTFILES" || { echo "$bad dotfiles repo not found at $DOTFILES"; exit 1; }
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
note "$ok" "branch: $branch"
dirty=$(git status --porcelain 2>/dev/null)
if [ -n "$dirty" ]; then
  flag "$warn" "uncommitted changes:"
  git status --short | sed 's/^/      /'
else
  note "$ok" "working tree clean"
fi
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
if [ -n "$upstream" ]; then
  ahead=$(git rev-list --count "@{u}..HEAD" 2>/dev/null)
  [ "$ahead" -gt 0 ] 2>/dev/null && flag "$warn" "$ahead local commit(s) not pushed" || note "$ok" "in sync with $upstream"
else
  flag "$warn" "no upstream tracking branch"
fi

# ── 2. Symlink integrity ──────────────────────────────────────────────────────
# Keep this list in step with install.sh.
hr "2. Symlink integrity"
check_link() {
  local target="$1" src="$2" dest="$HOME/$1"
  [ "${1:0:1}" = "/" ] && dest="$1"
  if [ ! -L "$dest" ]; then
    if [ -e "$dest" ]; then flag "$bad" "$dest exists but is NOT a symlink (edit the repo copy, not this)"
    else flag "$bad" "$dest missing (run ./install.sh)"; fi
  elif [ ! -e "$dest" ]; then
    flag "$bad" "$dest is a broken symlink"
  elif [[ "$(readlink "$dest")" != "$DOTFILES"/* ]]; then
    flag "$warn" "$dest does not point into the dotfiles repo"
  else
    note "$ok" "$dest"
  fi
}
check_link ".zshrc"
check_link ".gitconfig"
check_link ".config/ghostty/config"
check_link ".config/mise/config.toml"
check_link ".claude/CLAUDE.md"
check_link ".claude/settings.json"
check_link ".claude/statusline-command.sh"
check_link ".config/zed/settings.json"
check_link "$HOME/Library/Application Support/Code/User/settings.json"
for skill in "$DOTFILES"/claude/skills/*/; do
  [ -d "$skill" ] || continue
  name=$(basename "$skill")
  check_link ".claude/skills/$name"
done

# ── 3. Brew drift (installed vs Brewfile) ─────────────────────────────────────
hr "3. Brew drift"
if ! command -v brew >/dev/null 2>&1; then
  flag "$warn" "brew not found; skipping brew checks"
else
  bf_formulae=$(grep -E '^brew "' "$BREWFILE" | sed -E 's/brew "([^"]+)".*/\1/' | sort -u)
  bf_casks=$(grep -E '^cask "' "$BREWFILE" | sed -E 's/cask "([^"]+)".*/\1/' | sort -u)
  inst_leaves=$(brew leaves --installed-on-request 2>/dev/null | sort -u)
  inst_all=$(brew list --formula 2>/dev/null | sort -u)
  inst_casks=$(brew list --cask 2>/dev/null | sort -u)

  untracked_f=$(comm -23 <(echo "$inst_leaves") <(echo "$bf_formulae"))
  missing_f=$(comm -23 <(echo "$bf_formulae") <(echo "$inst_all"))
  untracked_c=$(comm -23 <(echo "$inst_casks") <(echo "$bf_casks"))
  missing_c=$(comm -23 <(echo "$bf_casks") <(echo "$inst_casks"))

  if [ -n "$untracked_f$untracked_c" ]; then
    flag "$warn" "installed but NOT in Brewfile (add to repo, or uninstall):"
    [ -n "$untracked_f" ] && echo "$untracked_f" | sed 's/^/      brew  /'
    [ -n "$untracked_c" ] && echo "$untracked_c" | sed 's/^/      cask  /'
  else
    note "$ok" "no untracked installs"
  fi
  if [ -n "$missing_f$missing_c" ]; then
    flag "$warn" "in Brewfile but NOT installed (run: brew bundle install):"
    [ -n "$missing_f" ] && echo "$missing_f" | sed 's/^/      brew  /'
    [ -n "$missing_c" ] && echo "$missing_c" | sed 's/^/      cask  /'
  else
    note "$ok" "everything in Brewfile is installed"
  fi
fi

# ── 4. Outdated packages ──────────────────────────────────────────────────────
hr "4. Outdated packages"
if command -v brew >/dev/null 2>&1; then
  outdated=$(brew outdated --greedy 2>/dev/null)
  if [ -n "$outdated" ]; then
    flag "$warn" "outdated (run: brewup):"
    echo "$outdated" | sed 's/^/      /'
  else
    note "$ok" "all brew packages current"
  fi
fi

# ── 5. mise runtimes ──────────────────────────────────────────────────────────
hr "5. mise runtimes"
if command -v mise >/dev/null 2>&1; then
  mise current 2>/dev/null | sed 's/^/      /'
  mout=$(mise outdated 2>/dev/null | tail -n +2)
  if [ -n "$mout" ]; then
    flag "$warn" "outdated runtimes (run: mise upgrade):"
    echo "$mout" | sed 's/^/      /'
  else
    note "$ok" "runtimes current"
  fi
else
  flag "$warn" "mise not found"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
hr "Summary"
if [ "$issues" -eq 0 ]; then
  echo "  $ok dotfiles healthy — no drift, no action needed."
else
  echo "  $warn $issues item(s) need attention. Run /dotfiles to resolve, or task sync / brewup."
fi
exit 0
