---
name: macos-setup
description: Configure this Mac's system settings end to end — applies the tracked `defaults` (Dock, trackpad, keyboard, scrolling, clock), verifies them, then audits and walks through the manual GUI/third-party settings (login items, Stats, Itsycal, desktops, Chrome default). One invocation covers everything; the underlying scripts still run standalone. Use after a clean install, on a new machine, or to reconcile macOS settings drift.
allowed-tools: Bash, Read, AskUserQuestion
---

The single entry point for getting this Mac's settings right. Running the skill covers **both** layers — the scriptable `defaults` and the manual GUI bits — so the user never has to remember to run two things. The documented intent is `docs/setup.md` Part 5 (system) and Part 6 (menu bar); the per-setting target values live there and in `macos/settings.sh`.

**Orchestrate, never reimplement.** Drive `task macos` and `task doctor` for the deterministic layer rather than issuing `defaults write` inline — same principle as the dotfiles skill calling `dotfiles-doctor.sh`. The scripts stay the single source of truth.

# Flow (default invocation)

1. **Apply** — run `task macos` (i.e. `macos/apply.sh`). Show what it set. This restarts Dock/Control Centre and reverts any drift to the tracked values.
2. **Verify** — run `task doctor` and surface its **section 6 (macOS settings)** result, confirming the deterministic layer took. Resolve any ⚠ before moving on.
3. **Audit the manual settings** it can read, comparing each to the documented target:
   - **Login items** → `osascript -e 'tell application "System Events" to get the name of every login item'` — expect Stats, Itsycal, Time Out, Raycast, Hidden Bar, Alt-Tab.
   - **Stats** → `defaults read eu.exelban.Stats` — CPU% + MEM% shown, clock format `HH:mm`. This is where digital menu-bar time comes from (system clock is intentionally analogue).
   - **Itsycal** → `defaults read com.mowglii.ItsycalApp` — menu-bar date. Itsycal 0.15+ replaced the old date-format string with toggles: expect `ShowDayOfWeekInIcon = 1`, `ShowMonthInIcon = 1`, `MenuBarIconType = 1` (the day number always shows) → renders "Sun 28 Jun", i.e. the documented `E d MMM`. Do not look for a `format`/`DateFormat` key; it doesn't exist in current versions.
   - **Desktop-switch hotkeys** → `defaults read com.apple.symbolichotkeys` — `CTRL+1/2/3` for Desktops 1–3.
   - **Chrome default browser** → report whether Chrome is the current default handler.
4. **Report** per item: ✓ matches intent / ⚠ drifted / — can't detect.
5. **Guide** the GUI steps that can't be set safely from a script, confirming as the user completes each:
   - Three Mission Control desktops + assign apps (Dev / Comms / PM per Part 5).
   - Stats first-time config (CPU%/MEM%/clock `HH:mm`), if the audit showed it unset.
   - Itsycal menu-bar date, if its toggles are off: Preferences → enable **Show day of week** and **Show month** (Itsycal 0.15+ has no format-string field).
   - Login items for the six menu-bar apps, if any are missing.
   - Set Chrome as default browser, if it isn't.

# Modes

- **Default** (`/macos-setup`) — full flow, steps 1–5.
- **Audit only** (`/macos-setup check`) — skip step 1 (no apply); run steps 2–5 read-only. Use to inspect drift without restarting Dock or changing anything.

# Rules

- Don't issue `defaults write` for the tracked settings inline — go through `task macos` so `macos/settings.sh` stays the one source of truth. To change a tracked value, edit `macos/settings.sh` (then it flows to apply + doctor).
- Don't try to script the manual items (login items, Stats/Itsycal config, desktops) — they're fragile or GUI-only; audit what's readable and walk the user through the rest.
- The system menu-bar clock stays **analogue** by design — digital time is Stats' job. If the user wants digital time and it's missing, the fix is Stats config, not flipping `IsAnalog`.
- If you edit tracked files (e.g. `macos/settings.sh`), follow the working-code workflow: branch, commit (conventional), push, draft PR. Applying defaults and GUI guidance alone need no PR.
- macOS only — this skill is a no-op elsewhere.
