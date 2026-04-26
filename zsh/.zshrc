# Oh My  Zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
DEFAULT_USER="richardgriffiths"  # hides user@hostname from prompt when on your own machine

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

