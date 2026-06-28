# About me
I am a technical product manager and principal engineer. I work across 
full-stack development, data engineering, DevOps, and program management.

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

# Working Code Management
- Always create a branch, commit, and open a draft PR automatically without asking — for both code and content changes. Draft PRs are pre-authorized as a routine, non-outward-facing step. Only confirm before marking a PR ready for review or merging.
- Commit and push as often as possible aiming to prompt for a full request and merge when you have an appropriate deliverable.

# Conventions
- Commit messages: conventional commits format (feat:, fix:, chore:, etc.)
- Stack, tooling, and code style are defined per-project in a local CLAUDE.md. Do not assume language or framework defaults.
- Reduce duplication between what AI agents, developers, and CI run. Prefer single Taskfile task or mise task references that all three invoke, so versions and tooling stay consistent across contexts.


# Goals & focus
- My active objectives are a *suite* of OKRs, injected each session from `~/.claude/okrs/active/` (may be empty — if so, ignore this section).
- This suite is the prioritised output of my intent. Raw intent lives upstream in `~/.claude/intent.md`; the `/intent` skill discovers it and promotes the top items into OKRs. The full method is in `docs/method.md`.
- Treat the suite as my current intent. When I propose substantial new work, briefly check it against these objectives.
- If a request is a side quest (not serving an active objective), do it but flag it in one line: which objective it diverges from, or that it serves none.
- Flag and proceed — never block or interrogate. Keep it to a single line.
- These are portfolio-level. Per-project goals, when present, take precedence for in-project task decisions.

# Configuration management
- All global configuration file changes must be made in ~/dotfiles and source controlled there — never edit config files directly in their installed locations (e.g. ~/.zshrc, ~/.claude/settings.json, etc.).
- Never put secrets, credentials, API keys, or PII into dotfiles. These must be handled as documented in the dotfiles repo (`.zshrc.local` for env vars, 1Password CLI for credentials).
