---
name: dotfiles
description: Manage the ~/dotfiles repo — audit drift between installed packages and the Brewfile, keep every install tracked in the repo, verify symlinks, surface outdated/replaceable packages, and resolve discrepancies. Use whenever installing/removing tools, or for a periodic dotfiles health check.
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
---

Keep the `~/dotfiles` repo the single source of truth for this machine. Everything installed is tracked here; everything tracked is installed; nothing is configured by editing files in place.

The audit logic lives in one script — `bin/dotfiles-doctor.sh` (also `task doctor`). Always run that for the report rather than re-implementing checks, then act on what it finds.

# Non-negotiable rules

- **Never install directly.** No `brew install X` / `brew install --cask X`. Add the entry to `~/dotfiles/Brewfile` (correct category), then `brew bundle install --file ~/dotfiles/Brewfile`.
- **Never edit installed config in place.** Edit the repo copy under `~/dotfiles/…` and re-link with `./install.sh`. If the doctor reports a path that "exists but is NOT a symlink", that file was edited directly — reconcile it into the repo, don't keep editing it.
- **Never `brew bundle cleanup --force` without showing the dry run first and getting explicit confirmation.** Cleanup removes everything not in the Brewfile — including tools that are simply untracked. Reconcile the Brewfile *before* forcing.
- **No secrets in the repo.** Env vars go in `~/.zshrc.local`, credentials in 1Password CLI. If a secret is about to land in a tracked file, stop and flag it.
- **All changes follow the working-code workflow:** branch, commit (conventional commits), push, open a draft PR. Don't mark ready or merge without confirmation.

# Modes

Read the user's intent from how the skill was invoked.

## Default — audit & resolve

1. Run `task doctor` (or `bash ~/dotfiles/bin/dotfiles-doctor.sh`). Show the report.
2. Walk each flagged item and resolve it (see **Resolving drift**). Confirm before any mutation.
3. If you changed tracked files, commit + push + draft PR.
4. End with a one-line state: healthy, or what's left and the command to finish it.

## Add a package ("install X", "add X to my dotfiles")

1. Identify formula vs cask (`brew info X` if unsure).
2. Add `brew "X"` or `cask "X"` to the right category in the Brewfile (keep groups tidy; match existing ordering). If it's a runtime that mise should own (node/python/etc.), prefer `mise/config.toml` instead.
3. `brew bundle install --file ~/dotfiles/Brewfile`.
4. If the tool needs shell config (alias, PATH, activation), add it to the repo copy (`zsh/.zshrc` etc.), not the installed file, then `./install.sh`.
5. Commit + push + draft PR.

## Remove a package ("uninstall X")

1. Remove its line from the Brewfile (and any related shell config in the repo).
2. `brew uninstall X` (or `--cask`). Then `brew autoremove` to drop newly-orphaned deps.
3. `./install.sh` if shell config changed. Commit + push + draft PR.

# Resolving drift

**Installed but not in Brewfile** — for each, ask the user: *add to the repo* (it's wanted → add the line, no reinstall needed) or *uninstall* (cruft → `brew uninstall [--cask] X`). Never assume. This is exactly where a blind cleanup would delete wanted tools. Watch for renamed casks (e.g. an old name lingering alongside its new one) — those are safe to uninstall once the new name is tracked.

**In Brewfile but not installed** — `brew bundle install --file ~/dotfiles/Brewfile` to install the missing ones.

**Outdated packages** — run `brewup` (brew + mise upgrade) or `task upgrade`. For pinned/risky upgrades, mention what's changing before running.

**Broken / missing / non-symlink paths** — `./install.sh` fixes missing or broken links. A real file where a symlink belongs means it was edited directly: move the content into the repo copy, delete the in-place file, then `./install.sh`.

**Uncommitted changes / unpushed commits** — surface them; offer to commit (conventional message) and push.

**mise runtimes outdated or untrusted** — `mise upgrade`; if a config-trust error appears, `mise trust ~/dotfiles/mise/config.toml`.

# Making it regular & visible

`task doctor` is the visible dashboard — fast and read-only. The `dotfiles-doctor` shell alias runs it from anywhere. For a recurring nudge, offer `/schedule` (a periodic cloud run) or `/loop`. Don't set up scheduling unless the user asks.

# What not to do

- Don't run `brew install`/`cask install`/`mise use` outside the Brewfile / mise config flow.
- Don't force a cleanup before reconciling the Brewfile.
- Don't edit `~/.zshrc`, `~/.gitconfig`, `~/.claude/*`, etc. in place — only their `~/dotfiles` sources.
- Don't reimplement the audit inline — call the doctor script so the checks stay single-sourced.
- Don't commit secrets, and don't add error handling or commentary the repo doesn't already use.
