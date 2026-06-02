---
name: okr
description: Interactively coach the user through writing Google-style OKRs (1 Objective + 3–5 measurable Key Results), then save them as markdown.
allowed-tools: Read, Write, Bash, AskUserQuestion
---

Coach the user through drafting a Google-style OKR set, then write it as a markdown file.

# Principles to enforce while coaching

Google-style OKRs have specific properties. Push back when the user's draft violates them — don't silently accept.

- **Objective:** qualitative, inspirational, time-bound. A direction, not a metric.
  - ✅ "Make onboarding feel effortless"
  - ❌ "Increase signups by 20%" — that's a Key Result.
- **Key Results:** 3–5 per objective. Measurable, outcome-focused, each with a baseline and target.
  - ✅ "D7 retention 22% → 35%"
  - ❌ "Launch new signup flow" — that's an initiative/output, not an outcome.
- **Ambition:** the sweet spot for a final score is ~0.7. If every KR looks easily hit, it's a roofshot — challenge it. (Applies to Aspirational KRs; Committed KRs are scored binary, see Mode below.)
- **Confidence:** captured at draft time on a 1–10 scale.
- **Evidence:** every KR must have a named, linkable reporting source — dashboard, query, report, or data location (Aspirational), or a PR/ticket/doc/demo link (Committed). KRs are time-bound *targets* on metrics or deliverables that should persist beyond the timeframe; the reporting outlives the OKR. If no source exists yet, **building it is a dependency, not optional** — capture it in Notes.
- **Mode (Aspirational vs Committed):**
  - **Aspirational** KRs are measurable, ambitious, scored 0.0–1.0 (~0.7 = success).
  - **Committed** KRs are binary deliverables — must-ship work, scored 1.0 or 0.0, with a clear Definition of Done. Reserve for compliance work, contracted deliverables, or hard-deadline ships.
  - **Mixed** OKRs combine both, with separate tables.
  - When the user proposes a Committed KR, double-check it's genuinely binary and not a measurable outcome in disguise. If the deliverable's purpose is to move a metric, the metric is the better KR.

When the user proposes something that violates these, name the violation, suggest a rewrite, and ask whether to accept.

# Flow

## Step 1 — Scope & timeframe

Use `AskUserQuestion` with three questions:
- Scope: Personal / Team / Org / Product
- Timeframe: pick a quarter (Q1–Q4) of a given year, an H1/H2, or custom
- Mode: Aspirational (measurable targets) / Committed (binary deliverables) / Mixed (some of each)

Record all three for later. The mode drives how Step 4 prompts and how Step 7 renders the table(s).

## Step 2 — Context (optional but encouraged)

Ask in plain text:

> **"Any context I should know about the current situation? Either point me at files (e.g. PRD, strategy doc, previous OKRs, retro notes, dashboard exports) and I'll read them, or paste/describe the situation directly. Say 'skip' if there's nothing relevant."**

Handle the response:
- **Files mentioned:** Read each in full using parallel Read calls. Glob first if the user gives a directory or pattern.
- **Free-text pasted/described:** capture it as-is.
- **"skip" or similar:** move straight to Step 3.

Use what you learn throughout the rest of the flow:
- Critique the **Objective** against any stated strategy or prior goals — flag if it contradicts or duplicates them.
- Ground **KR baselines** in real numbers from the context rather than asking the user to look them up again.
- Calibrate **ambition** flags against what the context says about current trajectory (a 2x jump may be a roofshot or a moonshot depending on history).
- Capture surfaced caveats, dependencies, or assumptions for the **Notes** section.

After ingesting, give the user a one-line summary of what you took away (e.g. "Got it — read the Q1 retro and the product strategy doc; main themes are X, Y, Z."). Don't dump quotes back.

## Step 3 — Objective

Ask in plain text: **"What's the objective?"**

Critique the response against the principles above. If it's a metric in disguise, an output ("Launch X"), or has no qualitative aspiration, propose a rewrite in one line and ask the user to confirm or push back. Iterate until they accept.

## Step 4 — Key Results

Aim for 3 KRs, allow up to 5 total across both types. Branch on the mode chosen in Step 1.

### Mixed mode

For each KR, first ask: **"Is KR N aspirational (measurable target) or committed (binary deliverable)?"** Then follow the relevant branch below.

### Aspirational KR prompts

- "**KR N — what are you measuring?**"
- "**Baseline (current value, with unit)?**"
- "**Target (with unit)?**"
- "**Where will this be reported?** Paste a link to the dashboard, query, report or data source. If it doesn't exist yet, say so and we'll log it as a dependency."

Critique each:
- If it isn't measurable, push back.
- If it's an output verb ("launch", "build", "ship", "release"), suggest the outcome it's meant to drive and offer a rewrite — or ask whether it should be a Committed KR instead.
- If baseline → target looks trivial relative to the timeframe, flag it as a roofshot.
- If the evidence source doesn't exist yet, capture it as a dependency in Notes. Don't accept "we'll figure it out later" — name the missing reporting work.

### Committed KR prompts

- "**KR N — what's the deliverable?**" (e.g. "Migrate to consolidated postgres instance", "Publish public API v1 docs")
- "**Definition of Done — what concretely proves it's shipped?**" (a list of criteria, not vibes — e.g. "Cutover complete, old DB read-only, zero open P1 bugs against new instance")
- "**Where will completion be evidenced?**" (PR link, ticket, doc, demo URL — or TBD)

Critique each:
- If it's secretly measurable (the real goal is to move a metric), suggest making it Aspirational instead.
- If the Definition of Done is vague ("it works", "users like it"), push back and ask for concrete criteria.
- If there's no evidence source, capture as a dependency in Notes.

### General

After KR 3, ask whether to add a KR 4 (and then 5). Stop at 5 — never write more.

## Step 5 — Confidence

Ask: **"On a scale of 1–10, how confident are you in hitting these?"**

- If ≥ 8: "That suggests these may not be ambitious enough — want to revisit?"
- If ≤ 3: "That's low — are the KRs realistic, or is the timeframe wrong?"

Either way, accept the user's final answer.

## Step 6 — Output path

Default filename: `okrs/<year>-<quarter-or-period>-<slugified-objective>.md` in the current working directory. Confirm the path with the user before writing. If the directory doesn't exist, create it via Bash (`mkdir -p`).

Slug rules: lowercase, hyphens for spaces, strip punctuation, max ~6 words.

## Step 7 — Write the file

Use this exact template (fill the placeholders, omit unused KR lines, don't add anything else):

```markdown
# <Objective>

**Scope:** <scope>
**Timeframe:** <timeframe>
**Confidence at draft:** <n>/10
**Score:** —

## Objective

<Objective as a full sentence — qualitative and aspirational.>

## Key Results

_KRs are time-bound targets on metrics or deliverables that should continue to be tracked beyond the timeframe. Each KR points to a reporting source in **Evidence** — that source should outlive this OKR._

**Render based on mode:**

**If Aspirational only** — single table:

| #   | Metric     | Baseline → Target          | Current | Progress | Status | Evidence            |
| --- | ---------- | -------------------------- | ------- | -------- | ------ | ------------------- |
| KR1 | \<metric\> | \<baseline\> → \<target\>  | —       | —        | —      | \<link or TBD\>     |

_Update **Current** as data lands. **Progress** = `(current − baseline) ÷ (target − baseline) × 100%`. **Status**: `On track` / `At risk` / `Off track` / `Done`. **Evidence**: dashboard/query/report URL, or `TBD` if reporting still needs to be built (and listed in Notes as a dependency)._

**If Committed only** — single table:

| #   | Deliverable     | Definition of Done | Status      | Evidence        |
| --- | --------------- | ------------------ | ----------- | --------------- |
| KR1 | \<deliverable\> | \<DoD criteria\>   | Not started | \<link or TBD\> |

_**Status**: `Not started` / `In progress` / `Done` / `Blocked`. **Evidence**: PR/ticket/doc/demo URL, or `TBD`._

**If Mixed** — two tables, sharing one KR numbering sequence (KR1, KR2, KR3...) split across them by type. Render the Aspirational table first under a `### Aspirational` subheading, then the Committed table under a `### Committed` subheading. Use the same table formats and helper notes shown above.

## Notes

<Any caveats, assumptions, or dependencies surfaced during coaching. Omit this section if none.>

---

_Score 0.0–1.0 at end of timeframe. ~0.7 is "successful". 1.0 = perfect, suggests it wasn't ambitious enough._
```

After writing, print only the path and a one-line confirmation. Don't restate the full file content.

# What not to do

- Don't accept "launch X" / "build Y" / "ship Z" as an **Aspirational** KR without challenging it. (They're fine in **Committed** mode — that's the whole point.)
- Don't write more than 5 KRs total (across both tables in Mixed mode).
- Don't pre-fill the **Score** field — that's for end-of-timeframe.
- Don't let a Committed KR through with a fuzzy Definition of Done.
- Don't add a preamble explaining what OKRs are; the user knows.
- Don't add emojis to the output file.
