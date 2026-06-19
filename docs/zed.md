# Zed Day-1 Tutorial

**What you will learn:** how to actually use Zed productively from the first session. Install is already covered in [Part 8 of the setup guide](setup.md) — this doc picks up the moment Zed opens for the first time.

**Prerequisite:** Zed installed via the Brewfile and `~/.config/zed/settings.json` symlinked from `~/dotfiles/zed/settings.json`. If either is missing, run `./install.sh && brew bundle --file=~/dotfiles/Brewfile` first.

**Time:** 20–30 minutes for the full walkthrough.

---

## 1. First Launch

Open Zed (`open -a Zed` or via Raycast / Spotlight). On first launch you will see:

- The **One Dark** theme with **JetBrains Mono Nerd Font** — that is the config working.
- Line numbers shown relative to the cursor — `relative_line_numbers: true` is on.
- A **welcome screen** in the centre with recent projects and quick links.
- A prompt or banner inviting you to **Sign In to Zed** — accept it. Sign in is what activates **Edit Predictions** (Zeta), Zed's inline AI completion. Free tier is 2,000 completions per month and is enough to evaluate it.

If you skip the sign-in for now, Zed still works — you just lose Zeta until you sign in later via `CMD + SHIFT + P` → "Sign In".

---

## 2. The Five Keys You Need on Day One

Memorise these. Everything else can wait.

| Shortcut | What it does |
|---|---|
| `CMD + SHIFT + P` | Command palette — searchable index of every Zed action |
| `CMD + P` | Quick-open any file in the project by name |
| `CMD + SHIFT + F` | Project-wide search across every file |
| `CMD + J` | Toggle the integrated terminal |
| `CMD + \` | Toggle the left panel (project tree / agent panel) |

The command palette is the single most important shortcut. When you do not know how to do something, hit `CMD + SHIFT + P` and type what you want — Zed will surface the action and its keybinding.

The full shortcut table lives in [docs/shortcuts.md](shortcuts.md#zed).

---

## 3. Opening a Project

Zed is project-rooted: you open a folder, not individual files.

```bash
cd ~/dev/your-repo
zed .
```

Or from the welcome screen: **Open Folder** and pick a directory.

**Multi-root workspaces:** drag a second folder into the project panel and Zed will show both repos side by side in the tree. Useful for monorepos or for editing a service and its client at the same time.

**Project panel:** toggle with `CMD + \`. Use the arrow keys to move; `ENTER` to open; `a` to add a file; `d` to delete; `r` to rename. Each binding is discoverable via the command palette.

Reference: <https://zed.dev/docs/getting-started>

---

## 4. Vim Mode Primer

`vim_mode: true` is on in your config, so Zed opens in normal mode every time. Here is the absolute minimum you need:

| Key | Action |
|---|---|
| `i` | Enter insert mode (start typing) |
| `ESC` | Return to normal mode |
| `:w` | Save the current buffer |
| `:q` | Close the current buffer (`:wq` to save and close) |
| `:e <path>` | Open a file by path |
| `h j k l` | Left / down / up / right |
| `w` / `b` | Jump forward / backward by word |
| `gg` / `G` | Top / bottom of file |
| `/foo` | Search for `foo` forward (`n` next, `N` previous) |
| `dd` | Delete the current line (puts it on the clipboard) |
| `yy` | Yank (copy) the current line |
| `p` | Paste after the cursor |
| `u` | Undo |
| `CMD + R` | Redo |

Three things your `vim` block in `settings.json` does that you should know about:
- **`use_system_clipboard: "always"`** — `y` and `p` use the macOS clipboard. Copy in Zed, paste in any other app.
- **`use_smartcase_find: true`** — `/Foo` is case-sensitive; `/foo` matches both cases.
- **`highlight_on_yank_duration: 200`** — yanked text flashes briefly so you can see what was copied.

Reference: <https://zed.dev/docs/vim>

---

## 5. The Agent Panel — Claude as Your Pair

Your `agent_servers.claude-acp` block (already in `settings.json`) wires Claude into Zed's Agent Panel.

**One-time setup:**

1. Open the Agent Panel — `CMD + SHIFT + A` (or `CMD + SHIFT + P` → "Agent: Toggle Panel").
2. In the new thread selector, choose **Claude Agent** (not the default "Zed Agent").
3. Inside the thread, type `/login` and press `ENTER`.
4. Authenticate with your **Anthropic API key** or your **Claude Code** subscription, whichever you use.
5. Send a test prompt: "summarise the README in this repo".

After login the same Claude Agent thread is available in every project — no per-repo setup. Threads keep history; close and reopen them from the panel header.

Reference: <https://zed.dev/docs/ai/external-agents>

---

## 6. Edit Predictions (Zeta)

Distinct from the Agent Panel. Edit Predictions is **inline ghost-text** as you type — a faded suggestion of the next few tokens or the rest of a line. Press `TAB` to accept.

Your config uses `"edit_predictions": { "provider": "zed" }` — Zed's own Zeta model. You activated this with the sign-in in step 1. Free tier is 2,000 predictions per month; Zed Pro removes the cap.

**Two AI features, two purposes:**
- **Zeta** (inline ghost-text) for fast, low-friction completion as you write code.
- **Claude Agent Panel** for conversation, refactoring across files, "explain this", planning.

Reference: <https://zed.dev/docs/ai/edit-prediction>

---

## 7. Language Servers and Extensions

Zed ships with built-in language servers for many languages (TypeScript, Python, Rust, Go, JSON, YAML, Markdown, …). Open a file in a supported language and Zed bootstraps the LSP automatically — no install step.

**Inlay hints** are on globally (`inlay_hints.enabled: true`). For any LSP that supports them, you will see inferred types and parameter names rendered inline in faded text. TypeScript and Rust are excellent demos.

**Extensions** — `CMD + SHIFT + X` opens the extensions panel. Add language packs, themes, and tools here. Examples worth installing as you encounter them:

- **Astro**, **Svelte**, **Vue** — frontend frameworks
- **Terraform**, **HCL** — IaC
- **GitHub Theme** if you prefer GitHub's palette

Reference: <https://zed.dev/docs/extensions>

---

## 8. Project-Specific Settings

When a project needs different conventions from your global defaults, drop a `.zed/settings.json` at the repo root. Zed merges it on top of your global config when you open that project.

Example for a Python repo that wants 4-space tabs and ruff-driven formatting:

```json
{
  "languages": {
    "Python": {
      "tab_size": 4,
      "format_on_save": "language_server"
    }
  }
}
```

Commit this file to the repo — it documents the team's editor expectations alongside the code. Other Zed users get the same behaviour for free.

Reference: <https://zed.dev/docs/configuring-zed>

---

## 9. Git Integration

Your `git` settings block gives you:

- **Change markers** in the gutter (`git_gutter: "tracked_files"`) — added / modified / deleted lines visible while you edit.
- **Inline blame** on the active line after a brief pause — author and commit message inline, no panel switching.
- **Staged-hollow hunk style** — hollow markers for hunks that are staged but not committed; solid for unstaged changes.

Combine with the terminal (`CMD + J`) and the `gs` / `ga` / `gc` aliases from `.zshrc` — you rarely need to leave Zed for routine git operations.

---

## 10. Where to Go Next

- **All keybindings:** [docs/shortcuts.md#zed](shortcuts.md#zed) — App commands and Vim motions reference.
- **Official Zed docs:** <https://zed.dev/docs> — full settings reference, every keybinding, language-specific guides.
- **Settings reference:** <https://zed.dev/docs/configuring-zed> — every key you can set in `settings.json`.
- **VS Code, side by side:** Part 7 of the setup guide. Use VS Code for Docker / Remote SSH / OpenAPI work; Zed for everything else.

Editing this config: change `~/dotfiles/zed/settings.json` (the symlink target). Zed reloads on save. Commit the change to track it.
