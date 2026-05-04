# dotfiles
My dotfile configuration

## Setup

```bash
./install.sh
```

After running, create `~/.gitconfig.local` (not committed — keeps your identity out of the public repo):

```ini
[user]
  name = Your Name
  email = your@email.com
```

## Shell aliases

### Claude Code
| Alias | Command | Description |
|-------|---------|-------------|
| `cc` | `claude` | Start Claude Code |
| `ccc` | `claude --continue` | Continue last session |
| `ccr` | `claude --resume` | Resume a previous session |

### Git
| Alias | Command |
|-------|---------|
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
| `serve` | `python3 -m http.server 8000` |
| `brewup` | `brew update && brew upgrade && brew cleanup` |
| `dotfiles` | `cd ~/dotfiles` |
| `dev` | `cd ~/dev` |
