# macOS Developer Setup Guide

**What you will build:** A keyboard-first, Claude-augmented developer environment capable of handling full-stack development, data engineering, DevOps, and program management — with a reproducible configuration you can restore from scratch in minutes.

**Time to complete:** 3–4 hours for a clean install. Less if some things are already done.

---

## Philosophy

- **Keyboard-first**: keep the mouse for browsers. Everything else should be reachable from keys.
- **Reproducible**: one command should be able to rebuild this machine from scratch.
- **Claude-augmented**: Claude Code is not just a coding tool — it is your pair programmer, code reviewer, ticket drafter, and research assistant.
- **Minimal menu bar noise, maximum signal**: you should know CPU, time, and calendar at a glance and nothing else.

---

## Before You Start

You need:
- Your Mac, logged in with your Apple ID
- A GitHub account (free — create one at github.com if you don't have one)
- Internet connection

Open the built-in **Terminal** app for now (Spotlight → type "Terminal" → Enter). You will replace this with Ghostty later.

---

## Part 1: Foundation — Xcode Tools & Homebrew

### Step 1.1 — Install Xcode Command Line Tools

**What this is:** Apple ships developer tools (git, compilers, build utilities) separately from macOS. They are not installed by default but almost everything in this guide depends on them.

Run this in Terminal:

```bash
xcode-select --install
```

A dialog box will appear. Click **Install** and wait for it to finish — takes 5–10 minutes. When it completes, verify it worked:

```bash
git --version
```

You should see something like `git version 2.x.x`. If you do, move on.

---

### Step 1.2 — Install Homebrew

**What this is:** Homebrew is the package manager for macOS — the equivalent of `apt` on Ubuntu or `choco` on Windows. It lets you install, update, and remove developer tools and applications from the command line.

Run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This will prompt for your password (normal — it needs to create directories in `/opt/homebrew/`). Follow any instructions it prints at the end — on Apple Silicon Macs it will tell you to add Homebrew to your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Run those two lines if instructed.

Verify Homebrew works:

```bash
brew --version
```

You should see `Homebrew 4.x.x`.

---

### Step 1.3 — Create Your Dev Directory

**What this is:** A consistent home for all your code projects.

```bash
mkdir ~/dev
```

You will clone all projects here: `~/dev/my-project`, `~/dev/client-app`, etc.

---

## Part 2: Dotfiles Repo — Your Machine's Source of Truth

**What this is:** A "dotfiles" repo is a GitHub repository that stores all your configuration files — your shell settings, editor config, git settings, Claude instructions, and the complete list of everything installed on your machine.

The name comes from the fact that most config files on Unix systems start with a dot (`.zshrc`, `.gitconfig`) which makes them hidden by default.

**Why it matters:** With a dotfiles repo, you run one command and everything is back after a wipe, new machine, or upgrade. Every config change is version-controlled — you can see what you changed and when, and roll back if something breaks.

---

### Step 2.1 — Set Up SSH Authentication for GitHub

**What this is:** GitHub no longer accepts passwords for git operations. SSH keys are the standard alternative — a cryptographic key pair where your Mac holds the private key and GitHub holds the public key.

This must be done before cloning or pushing anything.

**Generate an SSH key:**

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

Press Enter three times to accept the default file location and skip the passphrase.

**Add the key to your Mac's SSH agent:**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Copy your public key to the clipboard:**

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

**Add it to GitHub:**

1. Go to **github.com** → your avatar top right → **Settings**
2. Left sidebar → **SSH and GPG keys**
3. Click **New SSH key**
4. Title: `MacBook`
5. Paste (`CMD + V`) — the key is already in your clipboard
6. Click **Add SSH key**

**Verify it works:**

```bash
ssh -T git@github.com
```

Accept the GitHub server fingerprint when prompted. You should see: `Hi YOUR_USERNAME! You've successfully authenticated...`

From now on, always use SSH URLs (`git@github.com:username/repo.git`) rather than HTTPS URLs when cloning repos.

**Troubleshooting — git push still asks for username and password:**

```bash
git remote -v
```

If it shows `https://github.com/...`, switch it to SSH:

```bash
git remote set-url origin git@github.com:YOUR_GITHUB_USERNAME/dotfiles.git
```

---

### Step 2.2 — Create the Repo on GitHub

1. Go to **github.com** and sign in
2. Click the **+** button top right → **New repository**
3. Name it `dotfiles`
4. Set it to **Public** (dotfiles repos are conventionally public; never put secrets here)
5. Tick **Add a README file**
6. Click **Create repository**

---

### Step 2.3 — Clone it to Your Mac

**Important:** Clone dotfiles directly into your home directory (`~/dotfiles`), not inside `~/dev` or any other subfolder. Every script, symlink, and tool in this guide expects it at `~/dotfiles`.

```bash
git clone git@github.com:YOUR_GITHUB_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### Step 2.4 — Create the Directory Structure

```bash
mkdir -p ~/dotfiles/zsh
mkdir -p ~/dotfiles/git
mkdir -p ~/dotfiles/ghostty
mkdir -p ~/dotfiles/vscode
mkdir -p ~/dotfiles/claude
```

The repo layout this produces:

```
dotfiles/
├── Brewfile                  # all brew/cask installs
├── install.sh                # symlinks everything into place
├── .gitignore
├── docs/                     # setup guide and reference docs
├── zsh/
│   └── .zshrc                # main shell config (no secrets)
├── git/
│   └── .gitconfig
├── ghostty/
│   └── config
├── vscode/
│   ├── settings.json
│   └── extensions.txt
└── claude/
    ├── CLAUDE.md             # global Claude Code instructions
    └── settings.json         # model, theme, hooks
```

---

### Step 2.5 — Create the Install Script

**What this is:** A shell script that creates *symlinks* from your dotfiles repo to the locations on your Mac where each tool expects to find its config.

A symlink is like a shortcut — when your shell looks for `~/.zshrc`, it finds the symlink, which points to `~/dotfiles/zsh/.zshrc`. This means you only ever edit files inside `~/dotfiles/`, and git tracks every change automatically.

```bash
nano ~/dotfiles/install.sh
```

Paste this content:

```bash
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
```

Make it executable:

```bash
chmod +x ~/dotfiles/install.sh
```

**What `set -e` does:** It makes the script stop immediately if any command fails, rather than silently continuing and leaving things in a broken half-state.

**How to verify any symlink is working:**

```bash
ls -la ~/.config/ghostty/config
```

The output should show an arrow pointing back to your dotfiles:
```
~/.config/ghostty/config -> /Users/your-username/dotfiles/ghostty/config
```

---

### Step 2.6 — Set Up the .gitignore

You will store local secrets in a file called `.zshrc.local` which must *never* be committed to GitHub. Tell git to ignore it:

```bash
cat > ~/dotfiles/.gitignore << 'EOF'
zsh/.zshrc.local
.DS_Store
EOF
```

---

### Step 2.7 — Commit the Structure

```bash
cd ~/dotfiles
git add -A
git commit -m "chore: initial dotfiles structure"
git push
```

---

## Part 3: Installing Everything with a Brewfile

**What a Brewfile is:** A text file that lists every tool and application you want installed via Homebrew. Instead of running `brew install` one thing at a time, you maintain this list and run one command to install everything. This is how you rebuild your machine in minutes.

---

### Step 3.1 — Create the Brewfile

```bash
nano ~/dotfiles/Brewfile
```

Paste this:

```ruby
# Brewfile — complete package list

# CLI essentials
brew "git"
brew "wget"
brew "tldr"
brew "jq"
brew "fzf"
brew "ripgrep"
brew "bat"
brew "eza"
brew "zoxide"
brew "gh"
brew "tree"
brew "htop"
brew "zsh"
brew "go-task"

# Dev runtimes
brew "node"
brew "python"
brew "pyenv"
brew "nvm"

# Secrets management
cask "1password-cli"

# AI / Agent
cask "claude-code"
cask "cmux"

# Mac apps
cask "ghostty"
cask "visual-studio-code"
cask "google-chrome"
cask "docker-desktop"
cask "raycast"
cask "stats"
cask "alt-tab"
cask "hiddenbar"
cask "itsycal"
cask "time-out"
cask "linear-linear"
cask "slack"
cask "discord"
cask "1password"

# Fonts
cask "font-jetbrains-mono-nerd-font"
```

**What each category does:**

- **CLI essentials:** Core command-line tools. `fzf` is a fuzzy finder, `ripgrep` is a fast search tool, `bat`/`eza` are better versions of `cat`/`ls`, `zoxide` is a smarter `cd`, `gh` is the GitHub CLI.
- **Dev runtimes:** Node.js, Python, and version managers for both (`nvm` for Node, `pyenv` for Python) so you can switch versions per project.
- **Casks:** Full Mac applications installed via Homebrew instead of manually downloading them.

---

### Step 3.2 — Install Everything

This will take 10–20 minutes depending on your internet speed.

```bash
brew bundle --file=~/dotfiles/Brewfile
```

Watch the output. If any package fails, Homebrew will tell you. The most common reason is a naming difference — check `brew search <name>` if something is not found.

When it finishes, commit the Brewfile:

```bash
cd ~/dotfiles
git add Brewfile
git commit -m "chore: add Brewfile with full package list"
git push
```

---

## Part 4: Shell Setup — Ghostty, Oh My Zsh & Your .zshrc

Your shell is the environment you live in as a developer. This section transforms it from the default macOS Terminal into a fast, informative, highly productive workspace.

---

### Step 4.1 — Open Ghostty

Ghostty is now installed. Open it from Spotlight (`CMD + Space` → "Ghostty"). From this point, do all terminal work in Ghostty instead of the built-in Terminal.

**What Ghostty is:** A GPU-accelerated terminal emulator. It renders text using your graphics card, which makes scrolling and large outputs noticeably faster. It also has first-class macOS integration — native tabs, proper font rendering, and tight system integration.

---

### Step 4.2 — Configure Ghostty

Create the config in your dotfiles repo first:

```bash
nano ~/dotfiles/ghostty/config
```

Paste:

```
font-family = JetBrainsMono Nerd Font
font-size = 14
theme = Dracula
window-decoration = false
macos-titlebar-style = tabs
shell-integration = zsh
scrollback-limit = 10000
```

Then symlink it to where Ghostty looks:

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
```

Fully quit Ghostty (`CMD + Q`) and reopen it. You should see the Dracula dark theme with the new font.

**If you get a theme not found error:** Run `ghostty +list-themes` to see all available names.

**What "Nerd Font" means:** A version of JetBrains Mono patched with thousands of extra icon glyphs. Your shell prompt and tools like `eza` use these icons — without the Nerd Font, you would see broken squares instead.

---

### Step 4.3 — Install Oh My Zsh

**What Oh My Zsh is:** A community framework that sits on top of zsh. It provides themes (which control how your prompt looks), plugins (which add shortcuts and integrations), and makes managing your shell config much easier.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

When it asks if you want to change your default shell to zsh, say yes.

---

### Step 4.4 — Install Shell Plugins

Two plugins that are not bundled with Oh My Zsh but are essential:

**Syntax highlighting** — colours commands as you type them. Valid commands are green, invalid ones are red. You catch typos before pressing Enter.

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

**Autosuggestions** — as you type, shows a grey ghost of the most likely command based on your history. Press the right arrow key to accept it.

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

---

### Step 4.5 — Write Your .zshrc

**What .zshrc is:** The main configuration file for your shell. It runs every time you open a new terminal session. This is where you set up plugins, create shortcuts (aliases), configure tools, and set environment variables.

Create the file in your dotfiles:

```bash
nano ~/dotfiles/zsh/.zshrc
```

Paste the entire config:

```zsh
# Oh My Zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
DEFAULT_USER="your_mac_username"  # hides user@hostname from prompt when on your own machine

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  docker
  node
  python
  fzf
  gh
  z
)

source $ZSH/oh-my-zsh.sh

# ── Path ─────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# ── Better command defaults ───────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias cat='bat'
alias grep='rg'
alias cd='z'

# ── Git shortcuts ─────────────────────────────────────────────────────────────
alias gs='git status'
alias ga='git add -p'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias glg='git log --oneline --graph --decorate'
alias gnb='git checkout -b'

# ── Claude shortcuts ──────────────────────────────────────────────────────────
alias cc='claude'
alias ccc='claude --continue'
alias ccr='claude --resume'

# ── Dev shortcuts ─────────────────────────────────────────────────────────────
alias py='python3'
alias serve='python3 -m http.server 8000'
alias brewup='brew update && brew upgrade && brew cleanup'
alias dotfiles='cd ~/dotfiles'
alias dev='cd ~/dev'

# ── FZF ───────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='rg --files --hidden'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ── NVM (Node version manager) ────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# ── Load local secrets (never committed to git) ───────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
```

**Note:** Replace `your_mac_username` with the output of `whoami`.

Save and exit. Now create the symlink:

```bash
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
```

Reload the shell:

```bash
source ~/.zshrc
```

**What the aliases do and why:**

| Alias | Replaces | What changes |
|---|---|---|
| `ls` → `eza` | `ls` | Adds icons, colour, git status per file |
| `ll` | `ls -la` | Full detail list with git integration |
| `cat` → `bat` | `cat` | Adds syntax highlighting, line numbers |
| `grep` → `rg` | `grep` | 10–100x faster, respects .gitignore |
| `cd` → `z` | `cd` | Learns where you go; `z proj` jumps to right folder |
| `cc` | `claude` | Faster to type |
| `brewup` | long command | Weekly update routine in one word |

**Test fzf is working:** Press `CTRL + R`. Instead of a list, you should see a fuzzy-searchable history.

**Test the Nerd Font is working:** Run `ll` — you should see file and folder icons next to each entry. If you see squares or question marks, check `cat ~/.config/ghostty/config` and verify `font-family = JetBrainsMono Nerd Font` is present, then fully quit and reopen Ghostty (`CMD + Q`).

To view all aliases:

```bash
alias
```

---

### Step 4.6 — Create Your Secrets File

This file stays on this machine and is never committed to git.

```bash
nano ~/.zshrc.local
```

Add placeholders now — you will fill in real values later:

```bash
# Local secrets — DO NOT commit this file
export ANTHROPIC_API_KEY=""
export GITHUB_TOKEN=""
export BRAVE_API_KEY=""
```

This file is loaded automatically by your `.zshrc` every time you open a terminal.

---

### Step 4.7 — Commit Your Shell Config

```bash
cd ~/dotfiles
git add zsh/.zshrc .gitignore
git commit -m "chore: add zshrc and gitignore"
git push
```

---

## Part 5: macOS System Settings

Before setting up applications, dial in the system itself. Open **System Settings** (Apple menu → System Settings or `CMD + Space` → "System Settings").

| Setting | Value | Why |
|---|---|---|
| Mouse → Natural Scrolling | Off | Windows muscle memory |
| Trackpad → Tap to click | On | Less fatiguing than pressing |
| Trackpad → Tracking speed | Fast | You will thank yourself |
| Accessibility → Pointer Control → Three-finger drag | On | Move windows without clicking |
| Keyboard → Key Repeat Rate | Fast | Essential for coding |
| Keyboard → Delay Until Repeat | Short | Essential for coding |
| Dock → Auto-hide | On | Maximise screen space |
| Dock → Show suggested apps | Off | Keeps dock clean |
| Dock → Animate opening | Off | Faster feel |
| General → Login Items | Add: Stats, Itsycal, Time Out, Raycast, Hidden Bar, Alt-Tab | Auto-start |

**Dock:** Remove everything from the Dock manually (right-click each icon → Options → Remove from Dock). Leave only Finder and Trash. You open everything else with Raycast.

**Why this matters:** Every time you reach for the Dock you are breaking focus. Raycast lets you open any app in under a second without leaving the keyboard.

**Menu bar clock:** You cannot turn off the system clock entirely — set it to **Analogue** (System Settings → Control Centre → Clock). Stats will show the time digitally; the analogue clock is small enough to ignore.

---

### Multiple Desktops

Set up three desktops deliberately:

1. Press `F3` (or `CTRL + UP`) to open Mission Control
2. Hover at the top — click `+` twice to create two additional desktops (three total)

**Assign desktop shortcut keys:**

Settings → Keyboard → Keyboard Shortcuts → Mission Control:
- Enable "Switch to Desktop 1" → `CTRL + 1`
- Enable "Switch to Desktop 2" → `CTRL + 2`
- Enable "Switch to Desktop 3" → `CTRL + 3`

**Assign apps to desktops:**

1. Open each app (use `CMD + Space` for now)
2. Press `CTRL + UP` to open Mission Control
3. Drag each window up into the desktop thumbnail you want it to live on

Suggested layout:
- **Desktop 1:** Dev (VS Code, Ghostty, browser with docs)
- **Desktop 2:** Comms (Slack, Discord)
- **Desktop 3:** PM (Linear, planning browser tabs)

---

## Part 6: Raycast & the Menu Bar

### Step 6.1 — Set Up Raycast

Raycast is now installed. Open it: `CMD + Space` → type "Raycast" → Enter.

**What Raycast is:** A replacement for Spotlight that is dramatically more powerful. It searches your apps, files, and the web — but also has clipboard history, window management, text snippets, and an extension ecosystem. It becomes the single place you go for everything you used to use the mouse for.

**Configure the hotkey:**
- Raycast Preferences (`CMD + ,`) → General → Raycast Hotkey
- Set to `Option + Space`
- This leaves `CMD + Space` as Spotlight (useful as a fallback)

**Enable Clipboard History:**
- Preferences → Extensions → Clipboard History → Enable
- Set hotkey: `CMD + SHIFT + V`

**Enable Window Management:**
- Preferences → Extensions → Window Management → Enable
- Test: press `Option + Space` → type "left half" — your current window should snap to the left half

**Install extensions:**
- Open Raycast → type "Store" → browse and install:
  - **Linear** — search and open tickets from Raycast
  - **GitHub** — search repos, PRs, issues
  - **Docker** — manage containers
  - **Color Picker** — pick and copy colours
  - **Chrome** — search bookmarks and browser history
  - **Slack** — search messages and jump to channels
  - **Kill Process** — force-quit frozen apps instantly

**Set up snippets:**

Snippets expand short trigger text into longer content. Create them for things you type constantly: email addresses, common URLs, code templates.

- Preferences → Extensions → Snippets → Create Snippet
- Example: Keyword `;email` → your email address

**Raycast Pro ($10/month):** The main reason to pay is config sync across machines. On a single Mac the free tier covers everything you need.

---

### Step 6.2 — Configure the Menu Bar

**Hidden Bar:**

Hidden Bar creates a separator in your menu bar. Icons to the right of the separator are hidden unless you click the arrow.

- Open Hidden Bar (it adds a `<` icon to your menu bar)
- Hold `CMD` and drag icons to reorder
- Drag everything you do not need to always see to the right of the separator

**Stats:**

- Right-click its icons to configure
- **CPU:** show as percentage
- **Memory:** show as percentage
- **Clock:** enable and format as `HH:mm`
- Drag the Stats clock icon to sit near the right end of your visible menu bar

**Itsycal:**

- Right-click → Preferences
- Set the date format to: `E d MMM` — shows "Sun 26 Apr"
- Tick "Show week numbers" if useful
- Drag it to sit next to the Stats clock

**Your menu bar should now show:**
```
[Hidden Bar arrow] | [Stats CPU%] [Stats MEM%] [Stats time] [Itsycal date]
```

**Alt-Tab:**

Alt-Tab replaces macOS's app switcher with a window switcher. The difference: macOS's `CMD + TAB` shows one icon per *app*, even if an app has 5 windows open. Alt-Tab shows one thumbnail per *window*.

- Open Alt-Tab preferences (`CMD + ,`)
- Set it to activate on `CMD + TAB`

---

### Step 6.3 — Time Out (Break Reminders)

Open Time Out → Preferences:
- **Micro break:** 10 seconds every 25 minutes
- **Full break:** 5 minutes every 90 minutes

---

## Part 7: VS Code Setup

### Step 7.1 — Configure Settings

VS Code stores its settings in a JSON file. You will put this in your dotfiles and symlink it.

```bash
nano ~/dotfiles/vscode/settings.json
```

Paste:

```json
{
  "editor.fontFamily": "JetBrainsMono Nerd Font",
  "editor.fontSize": 14,
  "editor.lineHeight": 1.6,
  "editor.tabSize": 2,
  "editor.formatOnSave": true,
  "editor.linkedEditing": true,
  "editor.minimap.enabled": false,
  "editor.stickyScroll.enabled": true,
  "workbench.sideBar.location": "right",
  "workbench.secondarySideBar.location": "right",
  "workbench.colorTheme": "One Dark Pro",
  "workbench.iconTheme": "material-icon-theme",
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font",
  "terminal.integrated.fontSize": 13,
  "files.autoSave": "onFocusChange",
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "git.autofetch": true,
  "editor.inlineSuggest.enabled": true,
  "workbench.panel.defaultLocation": "bottom",
  "todo-tree.general.rootFolder": "${workspaceFolder}",
  "todo-tree.filtering.excludeGlobs": ["**/node_modules/**", "**/.venv/**", "**/dist/**"],
  "gitlens.currentLine.enabled": false,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "python.analysis.typeCheckingMode": "basic",
  "errorLens.delay": 500
}
```

Save and create the symlink:

```bash
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_SETTINGS"
ln -sf ~/dotfiles/vscode/settings.json "$VSCODE_SETTINGS/settings.json"
```

Open VS Code and verify the theme changed and the sidebar is on the right.

**Why sidebar on the right:** When the file explorer sidebar is on the left (the default), opening and closing it makes your code jump left and right. On the right, your code stays anchored. Small but reduces cognitive friction significantly across a day.

**What `editor.linkedEditing` does:** When you edit an HTML opening tag, the closing tag updates simultaneously.

**What `editor.stickyScroll` does:** Keeps the class/function name you are currently inside pinned at the top of the editor as you scroll. You always know where you are in a large file.

---

### Step 7.2 — Install Extensions

```bash
nano ~/dotfiles/vscode/extensions.txt
```

Paste:

```
zhuangtongfa.material-theme
pkief.material-icon-theme
usernamehw.errorlens
eamodio.gitlens
esbenp.prettier-vscode
dbaeumer.vscode-eslint
ms-python.python
ms-python.black-formatter
ms-azuretools.vscode-docker
ms-vscode-remote.remote-ssh
redhat.vscode-yaml
gruntfuggly.todo-tree
yzhang.markdown-all-in-one
streetsidesoftware.code-spell-checker
anthropic.claude-code
42crunch.vscode-openapi
asyncapi.asyncapi-preview
```

Install them all at once:

```bash
cat ~/dotfiles/vscode/extensions.txt | xargs -L1 code --install-extension
```

**What each extension does:**

| Extension | What it does |
|---|---|
| One Dark Pro / Material Icons | Dark theme and file icons — reduces visual noise |
| Error Lens | Shows error messages inline next to the problem line — no need to hover |
| GitLens | Shows who wrote each line and when, directly in the editor |
| Prettier | Auto-formats your code on save |
| ESLint | Catches JavaScript/TypeScript errors and style issues as you type |
| Python + Black | Python language support, type checking, and auto-formatting |
| Docker | Manage containers without leaving VS Code |
| Remote SSH | Edit files on remote servers as if they were local |
| YAML | Validation and autocomplete for YAML files |
| Todo Tree | Scans for `TODO:` and `FIXME:` comments and lists them |
| OpenAPI Editor | Validates and previews OpenAPI/Swagger specs |
| AsyncAPI Preview | Live preview for AsyncAPI contracts |
| Markdown All in One | Preview, table of contents, shortcuts for Markdown |
| Code Spell Checker | Catches typos in code and comments |
| Claude Code | Claude integration directly in VS Code |

Commit the extensions list:

```bash
cd ~/dotfiles
git add vscode/
git commit -m "chore: add VS Code settings and extensions"
git push
```

---

### Step 7.3 — Key VS Code Shortcuts

| Shortcut | Action |
|---|---|
| `CMD + P` | Quick open any file |
| `CMD + SHIFT + P` | Command palette |
| `CMD + B` | Toggle sidebar |
| `CMD + J` | Toggle terminal panel |
| `CMD + D` | Select next occurrence |
| `OPT + ↑/↓` | Move line up/down |
| `CMD + SHIFT + K` | Delete line |
| `CMD + /` | Toggle comment |
| `F12` | Go to definition |
| `OPT + F12` | Peek definition |
| `CMD + K, Z` | Enter Zen mode (press and release `CMD + K`, then press `Z`) |
| `ESC, ESC` | Exit Zen mode |

---

## Part 8: Claude Code Power User Setup

This is the section that transforms Claude from a chatbot into an integrated part of your development workflow. Take your time here — this pays off every day.

---

### Step 8.1 — Verify Claude Code is Installed

Claude Code was installed in Part 3 via the Brewfile. Verify:

```bash
claude --version
```

Log in:

```bash
claude
```

Follow the authentication flow. Once complete, you are inside an interactive Claude session. Type `/exit` to leave.

---

### Step 8.2 — Create Your Global CLAUDE.md

**What CLAUDE.md is:** Every time Claude Code starts, it reads `~/.claude/CLAUDE.md` as context before doing anything. Your global one is read in *every* session, regardless of which project you are in. It is how you tell Claude who you are and how you like to work — once, permanently.

```bash
nano ~/dotfiles/claude/CLAUDE.md
```

Paste and customise:

```markdown
# About me
Describe your role and what you work on.

# How I work
- I prefer concise, direct responses. No lengthy preamble.
- When writing code: no unnecessary comments, no over-engineering, no placeholders.
- When I ask what to do, give me a recommendation and the key tradeoff — not a list of options.
- Prefer editing existing files over creating new ones.
- Flag security issues immediately.
- Do not add error handling for scenarios that cannot happen.
- Plan before acting. Think through implications before writing code or making changes.

# Project management
- When drafting tickets or tasks, use: title, problem statement, acceptance criteria, effort estimate.
- Tracking tool is defined per-project. Ask if unclear.

# Conventions
- Commit messages: conventional commits format (feat:, fix:, chore:, etc.)
- Stack, tooling, and code style are defined per-project in a local CLAUDE.md. Do not assume language or framework defaults.
```

Save and exit. Create the symlink:

```bash
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

**Per-project CLAUDE.md:** Add a `CLAUDE.md` to each project repo to define stack, tooling, and code style for that project. The global one sets your working style; the project one sets the technical context.

---

### Step 8.3 — Configure Claude Code Settings

**What this file is:** `~/.claude/settings.json` controls Claude Code's behaviour — the model, theme, and hooks (shell commands that run in response to Claude's actions).

**The configuration levels:**

| Level | File | Scope |
|---|---|---|
| **User** | `~/.claude/settings.json` | Every session on this machine |
| **Project** | `.mcp.json` (in repo root) | MCP servers for this repo — committed to git, shared with team |
| **Project settings** | `.claude/settings.json` (in repo root) | Per-project permissions, hooks |
| **Local** | `.claude/settings.local.json` (in repo root) | Personal overrides, gitignored |

**Keep your user-level settings minimal: model, theme, and hooks that apply everywhere. Do not put MCP servers here.** Each MCP server loads its full tool list into every session's context — even when those tools are irrelevant to what you are doing. Add MCPs at the project level instead, only where they are actually used.

```bash
nano ~/dotfiles/claude/settings.json
```

Paste:

```json
{
  "theme": "dark",
  "model": "claude-sonnet-4-6",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude agent finished\" with title \"Claude Code\" sound name \"Glass\"'"
          }
        ]
      }
    ]
  }
}
```

**What the hook does:** Every time a Claude agent finishes its work, macOS will show a notification and play a sound. Start a Claude task, switch to another app, and you will be notified when Claude is done — you do not have to watch it work.

Now symlink it:

```bash
ln -sf ~/dotfiles/claude/settings.json ~/.claude/settings.json
```

---

### Step 8.4 — Add MCP Servers Per Project

**What MCP servers are:** MCP stands for Model Context Protocol. It is a standard that lets Claude connect to external services and use them as tools during a session. With MCP servers, Claude can read your GitHub issues, query your Linear backlog, search the web, and more.

Add them to each project that actually needs them. Project-level MCP configuration lives in `.mcp.json` in the project root — committed to git so your team shares the same server definitions. Credentials stay out of git in environment variables.

**In a repo that needs GitHub and Linear:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    },
    "linear": {
      "type": "http",
      "url": "https://mcp.linear.app/mcp"
    }
  }
}
```

**In a repo that needs web search:**

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"]
    }
  }
}
```

**Credentials** — add to `.zshrc.local`:

**GitHub** — requires a personal access token. Go to github.com → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token. Give it `repo` and `read:org` scopes:

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

**Linear** — uses OAuth, no token needed. Claude will walk you through a one-time authentication flow the first time you use it.

**Brave Search** — requires a free API key. Get one at brave.com/search/api:

```bash
export BRAVE_API_KEY="your_key_here"
```

Verify MCP servers are registered in a project that has them configured:

```bash
claude mcp list
```

---

### Step 8.5 — Claude Code Usage Patterns

These are the daily patterns that make Claude Code genuinely useful.

**Starting a task:**

```bash
cc "review the auth module in src/auth.py for security issues. Explain each issue and suggest a fix."
```

**Continuing the last session:**

```bash
ccc
```

**Resuming a specific past session:**

```bash
ccr
```

**Piping files into Claude:**

```bash
# Explain a file
claude "explain what this does and identify any bugs" < src/payment.py

# Generate tests for a file
claude "write pytest unit tests for all public functions" < src/utils.py > tests/test_utils.py
```

**Using Claude as a commit message writer:**

```bash
git add -p
git diff --staged | claude "write a conventional commit message for these changes. Format: type(scope): description"
```

**Drafting a ticket:**

```bash
claude "draft a ticket for this bug: users cannot log in with Google OAuth after the token refresh flow. Include: title, problem statement, steps to reproduce, acceptance criteria, effort estimate (S/M/L/XL)."
```

---

## Part 9: cmux Setup

**What cmux is:** A terminal environment designed specifically for running Claude Code agents. Where Ghostty is your general dev terminal, cmux is optimised for agentic workflows — multi-pane layouts, Claude output rendering, and markdown display.

cmux was installed in Part 3. Run the initial setup:

```bash
cmux welcome
cmux themes set --dark "Dracula"
```

Open cmux by running it from Ghostty:

```bash
cmux
```

**When to use cmux vs Ghostty:**

| Task | Use |
|---|---|
| Running a Claude agent on a long task | cmux |
| Monitoring multiple Claude sessions | cmux |
| Reading Claude's markdown output | cmux |
| Running tests, git commands, editing files | Ghostty |
| Quick one-off Claude question | Either |

**Key cmux shortcuts:**
- `CMD + ,` — settings
- `CMD + ←/→` — jump to start/end of line
- `OPT + ←/→` — skip words

**Notifications:** Combined with the hook you set up in Step 8.3, you get notified when agents complete regardless of which terminal you are looking at.

**Workspace naming:** Name each cmux workspace to match the task: `api`, `frontend`, `auth-refactor`. cmux ties every notification to the workspace it came from, giving you free context.

---

## Part 10: Chrome Setup

### Step 10.1 — Set as Default Browser

**System Settings → Desktop & Dock → Default web browser → Google Chrome**

### Step 10.2 — Sign In and Configure

- Sign into Chrome with your Google account to sync bookmarks and settings
- **Settings → Autofill and passwords → Google Password Manager → Offer to save passwords: Off** — 1Password handles this
- **Settings → Privacy and security → Send "Do Not Track" requests: On**

### Step 10.3 — Install Extensions

| Extension | Why |
|---|---|
| **uBlock Origin** | Blocks ads and trackers. Faster page loads, fewer distractions |
| **Dark Reader** | Applies dark mode to any website |
| **OneTab** | Collapses all open tabs into a saved list |
| **Tabliss** | Replaces new tab page with a clean, minimal design |
| **Privacy Badger** | Blocks invisible trackers |
| **Vimium** | Keyboard navigation for the browser — most impactful extension here |
| **1Password** | Password manager integration |

### Step 10.4 — Learn Vimium

**What Vimium is:** A Chrome extension that adds keyboard shortcuts inspired by Vim. It lets you navigate the web entirely without touching the mouse.

| Key | Action |
|---|---|
| `F` | Show letter labels on all clickable elements — press the letters to click |
| `H` / `L` | Go back / go forward in history |
| `J` / `K` | Scroll down / up |
| `G G` | Jump to top of page |
| `SHIFT + G` | Jump to bottom |
| `/` | Search on the page |
| `T` | Open new tab |
| `X` | Close current tab |
| `SHIFT + J` / `SHIFT + K` | Switch between tabs |

The `F` command is transformative. On any page, press `F` and every link and button gets a two-letter label. Type the letters to activate it — no mouse needed.

---

## Part 11: Password Manager — 1Password

**Why 1Password:** For a developer handling production credentials, API keys, and client data, the password manager is critical infrastructure. 1Password has a strong security track record and supports CLI access for scripts.

### Step 11.1 — Set Up 1Password

1Password is installed. Open it and create an account at 1password.com.

Install the Chrome extension from the 1Password website.

### Step 11.2 — Sign In to the CLI

The 1Password CLI (`op`) was installed via the Brewfile. Sign in:

```bash
op signin
```

**How to use it:** Instead of putting a secret in a script:

```bash
# Instead of this (secret in plaintext):
export DB_PASSWORD="my_actual_password"

# Do this (retrieved securely at runtime):
export DB_PASSWORD=$(op read "op://Private/Database/password")
```

The secret never touches a file. It is retrieved from 1Password's encrypted vault at the moment it is needed.

---

## Part 12: Git Configuration

Git reads a global config file for settings that apply to all repos on this machine.

```bash
nano ~/dotfiles/git/.gitconfig
```

Paste:

```ini
[include]
  path = ~/.gitconfig.local

[core]
  editor = code --wait
  autocrlf = input

[init]
  defaultBranch = main

[pull]
  rebase = true

[push]
  autoSetupRemote = true

[alias]
  st = status
  co = checkout
  br = branch
  ci = commit
  lg = log --oneline --graph --decorate --all
  undo = reset HEAD~1 --mixed
  amend = commit --amend --no-edit
  aliases = config --get-regexp alias

[diff]
  tool = vscode

[difftool "vscode"]
  cmd = code --wait --diff $LOCAL $REMOTE
```

Then create `~/.gitconfig.local` (never committed — keeps your identity out of the public repo):

```bash
nano ~/.gitconfig.local
```

```ini
[user]
  name = Your Name
  email = your@email.com
```

Create the symlink for the main config:

```bash
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
```

**Key settings explained:**

- **`[include]`:** Loads your name and email from a local file that is never committed to git
- **`editor = code --wait`:** When git needs you to write something (merge commit message, interactive rebase), it opens VS Code and waits
- **`autocrlf = input`:** Handles the Windows/Mac line ending difference
- **`pull.rebase = true`:** Rebases your local commits on top instead of creating a merge commit — keeps history cleaner
- **`push.autoSetupRemote = true`:** When you push a new branch for the first time, git automatically sets up tracking without requiring `--set-upstream`
- **`undo`:** `git undo` rolls back the last commit but keeps your changes staged — safer than other undo approaches

Commit:

```bash
cd ~/dotfiles
git add git/.gitconfig
git commit -m "chore: add git config"
git push
```

---

## Part 13: Program Management

Install your project management tool of choice — Linear is included in the Brewfile. Sign in with your work or personal account.

If using Linear, the MCP integration from Part 8.4 lets Claude interact with your backlog directly:

```bash
cc "what are my open issues in Linear assigned to me?"
cc "create a Linear ticket: title 'Fix OAuth refresh flow', problem: users cannot re-authenticate after token expiry"
```

**Key Linear keyboard shortcuts:**

| Shortcut | Action |
|---|---|
| `C` | Create new issue from anywhere |
| `CMD + K` | Command palette |
| `1` / `2` / `3` | Change issue priority |
| `A` | Assign issue |
| `S` | Change status |
| `F` | Filter issues |

---

## Part 14: Final Commit & Verification

### Step 14.1 — Run the Install Script

```bash
cd ~/dotfiles
./install.sh
```

You should see "All dotfiles linked." without errors.

### Step 14.2 — Final Commit

```bash
cd ~/dotfiles
git add -A
git commit -m "chore: complete initial setup"
git push
```

### Step 14.3 — Verification Checklist

**Shell:**
- [ ] Open Ghostty — prompt should show with icons and colour (Oh My Zsh agnoster theme)
- [ ] Type `ll` — should show directory listing with icons and git column
- [ ] Type `cat ~/.zshrc` — should show syntax-highlighted output via bat
- [ ] Press `CTRL + R` — should open fzf fuzzy history search

**Dotfiles:**
- [ ] `ls -la ~/ | grep zshrc` — should show `.zshrc -> /Users/your-username/dotfiles/zsh/.zshrc`
- [ ] `ls ~/dotfiles/` — should show Brewfile, install.sh, zsh/, git/, ghostty/, vscode/, claude/

**Claude Code:**
- [ ] `cc` — should open Claude and show it read your CLAUDE.md context
- [ ] `claude mcp list` — run from a project with `.mcp.json` configured; should show the servers defined there

**VS Code:**
- [ ] Open VS Code — theme should be One Dark Pro, sidebar on right
- [ ] Open any Python or JS file — should format on save

**Raycast:**
- [ ] `OPT + Space` — Raycast opens
- [ ] `CMD + SHIFT + V` — clipboard history opens
- [ ] Type "left half" in Raycast — window snaps to left half of screen

**Menu bar:**
- [ ] CPU% and memory% visible from Stats
- [ ] Time visible from Stats
- [ ] Date visible from Itsycal, click it for calendar pop-up

---

## Part 15: Maintenance

### Weekly routine

```bash
brewup          # updates all Homebrew packages and cleans up old versions

cd ~/dotfiles
git add -A
git commit -m "chore: weekly dotfiles update"
git push
```

### When you install something new

```bash
brew install <tool-name>
brew bundle dump --force --file=~/dotfiles/Brewfile   # update the list
cd ~/dotfiles && git add Brewfile && git commit -m "chore: add <tool-name>" && git push
```

### When you change a config

Since all configs are symlinked to `~/dotfiles/`, just edit the file there:

```bash
nano ~/dotfiles/zsh/.zshrc    # edit
source ~/.zshrc                # apply immediately

cd ~/dotfiles && git add zsh/.zshrc && git commit -m "chore: update zshrc" && git push
```

---

## What You Have Built

| Layer | What | Why it matters |
|---|---|---|
| **Foundation** | Xcode tools + Homebrew + Brewfile | Reproducible — one command reinstalls everything |
| **Dotfiles repo** | GitHub-backed config store | Version-controlled config, portable to any Mac |
| **Shell** | Ghostty + Oh My Zsh + fzf + zoxide | Faster navigation, better history, richer output |
| **Secrets** | `.zshrc.local` + 1Password CLI | API keys never in plaintext files or git |
| **Launcher** | Raycast | App switching, clipboard, snippets, extensions without touching the mouse |
| **Menu bar** | Stats + Itsycal + HiddenBar | System info at a glance, no clutter |
| **Editor** | VS Code with extensions | Formatting, linting, git insight, error visibility, AI integration |
| **AI pair** | Claude Code + CLAUDE.md + MCP | Claude knows your context; MCP servers added per-project to avoid bloating every session |
| **Agent terminal** | cmux | Multi-pane Claude sessions with notifications |
| **Desktops** | 3 separate workspaces | Focus by context — code, comms, planning |
| **Browser** | Chrome + Vimium + uBlock | Keyboard-navigable, tracker-free |
| **PM** | Project tracker + MCP | Fast ticket management with Claude integration |
| **Passwords** | 1Password | Secure credential management across browser and CLI |
| **Git** | Global .gitconfig with aliases | Consistent git behaviour, VS Code as diff tool |

---

## Things to Explore Next

- [ ] **Stage Manager** — try it for a week; works well if you have many overlapping app windows
- [ ] **Raycast Pro** — revisit if you get a second Mac; the main benefit is config sync
- [ ] **pyenv** — set up Python version management per project
- [ ] **GitHub Actions** — automate testing and deployments; Claude can help write workflows
- [ ] **Claude Code hooks** — explore other hook types (PreToolUse, PostToolUse) to customise Claude's behaviour further
- [ ] **tmux** — a more general-purpose terminal multiplexer if you find cmux limiting

---

## Reference Links

- [Oh My Zsh](https://ohmyz.sh)
- [Ghostty docs](https://ghostty.org)
- [cmux quickstart](https://manaflow-ai-cmux.mintlify.app/quickstart)
- [Claude Code docs](https://docs.anthropic.com/en/docs/claude-code)
- [Raycast extensions](https://www.raycast.com/store)
- [Linear MCP](https://github.com/linear/linear-mcp)
