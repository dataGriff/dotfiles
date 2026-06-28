# The Method Loop

How I work, as a single reconciling loop. I author **intent**; everything downstream
is a continuous reconciliation of *desired state* against *current state* until the two
match, then I judge the result and the loop turns again.

```mermaid
---
title: "Method Loop — where you touch it"
---
flowchart TD
    OP(["YOU · operator"])
    INTENT["INTENT<br/><i>impact · goal · destination · purpose</i>"]

    subgraph RECONCILE["reconcile · fast · output is disposable"]
        direction TB
        SPEC["SPEC<br/><i>desired state + constraints</i>"]
        PLAN["PLAN<br/><i>desired − current</i>"]
        SYSTEM["SYSTEM<br/><i>current state of the thing</i>"]
    end

    FEEDBACK["FEEDBACK<br/><i>observations</i>"]

    %% loop edges (0-6)
    INTENT -->|specify| SPEC
    SPEC -->|desired| PLAN
    SYSTEM -. current .-> PLAN
    PLAN -->|build| SYSTEM
    SYSTEM -->|release| FEEDBACK
    FEEDBACK -->|improve| SPEC
    FEEDBACK -->|status| INTENT

    %% operator touchpoints (7-9)
    OP ==>|"① initiate · author"| INTENT
    OP -->|"refine"| SPEC
    FEEDBACK -->|"judge"| OP

    classDef kept fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:2px;
    classDef ephemeral fill:#fff7ed,stroke:#ea580c,color:#7c2d12,stroke-width:2px,stroke-dasharray:5 4;
    classDef operator fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:2px;
    class INTENT,SPEC,SYSTEM,FEEDBACK kept;
    class PLAN ephemeral;
    class OP operator;

    linkStyle 1,2,3 stroke:#16a34a,stroke-width:2px;
    linkStyle 0,4,5,6 stroke:#94a3b8,stroke-width:1.5px;
    linkStyle 7,8,9 stroke:#d97706,stroke-width:2px;
```

## Reading the loop

**Kept vs ephemeral.** Four artifacts are durable and worth maintaining — `INTENT`,
`SPEC`, `SYSTEM`, `FEEDBACK` (green). `PLAN` (orange, dashed) is disposable: it's just
`desired − current` recomputed whenever either side moves, so it's never edited directly
or stored for long.

**The reconcile core.** `SPEC` (desired state + constraints) and `SYSTEM` (current state)
are continuously diffed into `PLAN`, which is built back into `SYSTEM`. This runs fast and
often; the output of each pass is throwaway.

**Operator touchpoints.** I only ever touch three places: I **author** `INTENT` (①), I
**refine** `SPEC`, and I **judge** `FEEDBACK`. Everything else reconciles on its own.

**Two return edges.** `FEEDBACK → SPEC` *improves* the desired state from what was
observed; `FEEDBACK → INTENT` reports *status* back up, so intent stays honest about
what's actually happening.

## Where each stage lives in this repo

This repo currently materialises the **INTENT** stage only. The rest are documented
placeholders the loop will grow into — they live per-project (in the repos of the things
I build), not here.

| Stage | Artifact | In this repo |
| --- | --- | --- |
| **INTENT** | impact · goal · destination · purpose | `claude/intent.md` (the inbox) → `claude/okrs/active/` (the prioritised suite) |
| SPEC | desired state + constraints | _future_ |
| PLAN | desired − current (ephemeral) | _future; per-project, never stored_ |
| SYSTEM | current state of the thing | the things I build (per-project repos) |
| FEEDBACK | observations · status | _future_ |

## The INTENT stage today

Intent is handled in two moves, both driven by the `/intent` skill:

1. **Discover** — surface what I actually intend (impact, goal, destination, purpose) and
   capture each as raw intent in `claude/intent.md`. No OKR shape is forced yet.
2. **Prioritise** — rank the inbox, pick a small current suite, and promote the top
   intents into OKRs (via the `/okr` skill) under `claude/okrs/active/`. Each active OKR
   is injected into every Claude Code session by the `SessionStart` hook.

So the path is: **`/intent` discover → `claude/intent.md` → `/intent` prioritise →
`/okr` → `claude/okrs/active/` → injected every session.**
