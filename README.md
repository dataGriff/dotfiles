# dotfiles

A keyboard-first, Claude-augmented macOS developer environment. Reproducible from scratch.

**Full setup guide:** [docs/setup.md](docs/setup.md)  
**Keyboard shortcuts:** [docs/shortcuts.md](docs/shortcuts.md)

---

## Philosophy

- **Keyboard-first**: keep the mouse for browsers. Everything else should be reachable from keys.
- **Reproducible**: one command should be able to rebuild this machine from scratch.
- **Claude-augmented**: Claude Code is your pair programmer, code reviewer, ticket drafter, and research assistant.
- **Minimal menu bar noise, maximum signal**: CPU, time, and calendar at a glance.

---

## Quick Bootstrap

For a full rebuild, run these commands in order:

```bash
# 1. Install Xcode command line tools
xcode-select --install

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Clone your dotfiles repo
git clone git@github.com:YOUR_GITHUB_USERNAME/dotfiles ~/dotfiles

# 4. Run the install script
cd ~/dotfiles && ./install.sh

# 5. Install everything from Brewfile
brew bundle --file=~/dotfiles/Brewfile
```

For a first-time setup, work through [docs/setup.md](docs/setup.md) in order.

---

## Manual Steps

These files are machine-local and must never be committed:

**`~/.gitconfig.local`** — your git identity:
```ini
[user]
  name = Your Name
  email = your@email.com
```

**`~/.zshrc.local`** — API keys and secrets:
```bash
export ANTHROPIC_API_KEY=""
export GITHUB_TOKEN=""
export BRAVE_API_KEY=""
```

---

## Shell Aliases

### Claude Code

| Alias | Command | Description |
|-------|---------|-------------|
| `cc` | `claude` | Start Claude Code |
| `ccc` | `claude --continue` | Continue last session |
| `ccr` | `claude --resume` | Resume a previous session |

### Git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add -p` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `gpl` | `git pull` |
| `gco` | `git checkout` |
| `gnb` | `git checkout -b` |
| `glg` | `git log --oneline --graph --decorate` |

### Dev

| Alias | Command |
|-------|---------|
| `py` | `python3` |
| `ll` | `eza -la --icons --git` |
| `serve` | `python3 -m http.server 8000` |
| `brewup` | `brew update && brew upgrade && brew cleanup` |
| `dotfiles` | `cd ~/dotfiles` |
| `dev` | `cd ~/dev` |
