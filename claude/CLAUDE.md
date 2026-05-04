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

# Conventions
- Commit messages: conventional commits format (feat:, fix:, chore:, etc.)
- Stack, tooling, and code style are defined per-project in a local CLAUDE.md. Do not assume language or framework defaults.
- Reduce duplication between what AI agents, developers, and CI run. Prefer single Taskfile task or mise task references that all three invoke, so versions and tooling stay consistent across contexts.

# Configuration management
- All configuration file changes must be made in ~/dotfiles and source controlled there — never edit config files directly in their installed locations (e.g. ~/.zshrc, ~/.claude/settings.json, etc.).
- Never put secrets, credentials, API keys, or PII into dotfiles. These must be handled as documented in the dotfiles repo (`.zshrc.local` for env vars, 1Password CLI for credentials).
