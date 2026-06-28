---
name: intent
description: Discover what the user intends to do (the upstream of OKRs), capture it in the intent inbox, then prioritise the top intents into a live OKR suite.
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, Skill
---

Run the **INTENT** stage of the user's Method Loop (see `docs/method.md`). Intent is the
apex of the loop: first *discover* what the user wants to be true and why, then *prioritise*
the strongest intents into a committed OKR suite.

The inbox lives at `~/dotfiles/claude/intent.md` (a living document — read and edit it in place,
never recreate it). Promoted OKRs land in `~/dotfiles/claude/okrs/active/`. These are the
source-controlled originals; `~/.claude/intent.md` and `~/.claude/okrs/` symlink to them and are
what gets injected into every session. Always read and write the `~/dotfiles/...` paths — the
Edit tool refuses to write through the `~/.claude/...` symlinks.

# Modes

Pick the mode from the user's argument:
- `discover` → run **Discover** only.
- `prioritise` → run **Prioritise** only.
- no argument → Read `~/dotfiles/claude/intent.md`. If it has no `raw` or `prioritised` intents,
  start with **Discover**. Otherwise ask whether to discover more or prioritise what's there.

# Intent block format

Each intent is a block under `## Live intents` in `~/dotfiles/claude/intent.md`:

```
### <short name>
- **Purpose:** why this matters / the destination
- **Impact:** who or what changes if this happens
- **Conviction:** <n>/10
- **Status:** raw | prioritised | promoted → [okr](okrs/active/<file>.md)
- **Captured:** <YYYY-MM-DD>
```

Get today's date with `date +%F` when capturing.

# Discover

Goal: surface the user's real intent and capture each as a block. Do **not** force OKR
shape here — no metrics, baselines, or targets yet. That's the next stage's job.

Interview around the four INTENT facets from the loop. Ask conversationally, one theme at
a time — don't dump all four as a form:

- **Purpose** — *"What do you want to be true that isn't yet? Why does it matter to you?"*
- **Impact** — *"Who or what is different if this happens?"*
- **Goal / destination** — *"What does 'done' or 'arrived' look like — the state you're aiming at?"*
- **Conviction** — *"How strongly do you hold this right now, 1–10?"*

Surface **multiple** intents — when one is captured, ask *"What else is pulling at you?"*
until the user is empty. Keep each one tight; an intent is a direction, not a plan.

For each intent:
- If it's really an initiative or task ("build X", "migrate Y"), ask *what it's in service
  of* and capture that higher purpose as the intent — note the task under Purpose.
- Append (or update) its block in `~/dotfiles/claude/intent.md` with **Status: raw**.

After capturing, give a one-line summary of what landed (names only). Don't restate the file.

# Prioritise

Goal: turn the inbox into a small, honest, current suite of OKRs.

1. **Read** `~/dotfiles/claude/intent.md` and list every `raw` and `prioritised` intent.
2. **Rank** them. Weigh impact × conviction against rough effort/cost — say the ordering
   out loud with one line of reasoning each. A suite is a *focus*: recommend the top few
   (typically 3 or fewer active OKRs), and name what's being deliberately left in the inbox.
3. **Confirm** the selection with `AskUserQuestion` (multi-select the intents to promote now).
4. **Promote** each selected intent:
   - Mark it **Status: prioritised** in the inbox first.
   - Invoke the `okr` skill to coach a full OKR for that intent. Pass the intent's Purpose,
     Impact and any discovered context as the objective context so the user isn't re-asked
     what they've already said. Tell `okr` to write to
     `~/dotfiles/claude/okrs/active/<year>-<period>-<slug>.md`.
   - When the OKR is written, update the intent's status to
     **promoted → [okr](okrs/active/<file>.md)** with the real filename.
5. Confirm the new suite: list the active OKR filenames and note that they'll be injected
   into the next session.

Reuse `okr` for all OKR authoring — never re-implement OKR coaching here.

# What not to do

- Don't force intent into metrics/targets during **Discover** — that's premature.
- Don't recreate `~/dotfiles/claude/intent.md` or reorder unrelated blocks — edit in place.
- Don't promote everything. A suite that contains all intents isn't prioritised.
- Don't duplicate the `okr` skill's coaching — call it.
- Don't add emojis to the inbox or OKR files.
