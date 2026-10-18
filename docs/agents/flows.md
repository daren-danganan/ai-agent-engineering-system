# Flows

Which command to reach for, and in what order. Each command drives one or more agents in `.claude/agents/`; the judgment they apply is in [`principles.md`](principles.md).

## The roster

| Agent | Runs as | Job | Writes |
|---|---|---|---|
| `griller` | the main conversation | Interview you until the design tree is resolved, keep the glossary and ADRs current, then synthesize the spec and tickets | glossary, `docs/adr/`, `.scratch/<slug>/` |
| `scout` | subagent, read-only | Explain how a subsystem works and why it was built that way, with file and commit evidence | nothing |
| `architect` | subagent, read-only | Produce one candidate design (usage-first type sketch), or survey the codebase for deepening opportunities | nothing |
| `prototyper` | subagent | Answer one design question with throwaway code and report what it observed | `.scratch/<slug>/prototypes/` only |
| `implementer` | subagent | Build one ticket test-first at agreed seams and prove it on the real artifact | code and tests for that ticket |
| `verifier` | subagent | Independently prove a claim on the real artifact, or create and maintain the feature map | evidence; the feature map in map mode |
| `debugger` | subagent | Build a red feedback loop for a bug, find the root cause, fix it with a regression test | the fix and its test |
| `reviewer` | subagent, read-only | Review a diff on one axis: Standards or Spec | nothing |
| `retro` | subagent, read-only | Propose environment fixes after a session, each at the strongest layer of the correction ladder | nothing |

Subagents cannot spawn subagents or talk to you. The main conversation (running a command) does all spawning, judging, committing, and asking.

## Main flow: idea → shipped

1. **`/grill <idea>`** — align. The griller restates your goal, then works the design tree in rounds. Facts it can look up go to `scout`; empirical forks go to `/prototype`; only decisions come to you. Resolved terms land in the glossary as they settle.
2. **`/prototype <question>`** *(optional, any time)* — when a question needs a runnable answer. The decision comes back into the grilling; the code is thrown away.
3. **`/to-spec`** — the griller writes `.scratch/<slug>/spec.md` from the conversation, after confirming the seams it will test at. No new interview.
4. **`/design <spec or ticket>`** *(when the work crosses a function boundary)* — `scout` grounds, two `architect` runs on different models design it twice, the main conversation judges and writes `.scratch/<slug>/design.md`.
5. **`/to-tickets`** — the griller splits the spec into tracer-bullet tickets under `.scratch/<slug>/issues/`, each with blocking edges and a `Verify with` check. You approve the breakdown.
6. **`/implement <.scratch/slug>`** — on a `build/<slug>` branch: for each ready ticket, a fresh `implementer` builds it, an independent `verifier` proves it, the main conversation commits it. At the end, two `reviewer`s (Standards, Spec) review the branch, the `verifier` adds the feature to the feature map, and you decide on the merge. The spec's `Status:` goes `building` → `shipped`.
7. **`/retro`** — the `retro` agent proposes changes to the environment so the next run goes better.

Keep steps 1–5 in one conversation: the spec and tickets need the grilling as a primary source. Each ticket in step 6 runs in a fresh subagent, so its context starts clean.

**Skip planning** for a typo, a one-file fix, or a question. Planning is rigor; spend it where being wrong is expensive.

## On-ramps

- **Something's broken** → **`/diagnose <symptom>`**. The `debugger` refuses to theorize until it has one command that goes red on this bug. Then `/retro` to ask what would have prevented it.
- **A design question** → **`/design <question>`** directly, without a spec.
- **"How does X work?" / "Why is Y like this?"** → ask plainly; the main conversation sends it to `scout`.
- **"Does it actually work?"** → **`/verify <feature or claim>`**. **`/verify map`** creates or refreshes the feature map.
- **Review a branch or PR** → **`/review <fixed point>`**.
- **"Where are we?"** → **`/status [slug]`**. Every feature's status and ticket counts, read from `.scratch/`.

## Upkeep

- **`/improve-architecture [area]`** — `architect` in survey mode finds deepening opportunities in the code that changes most. Pick one and it goes into `/grill`.
- **`/retro`** — after any session that went sideways.
- **`/verify map`** — whenever user-facing features changed, so the feature map doesn't drift.

## Phase boundaries

Between phases, pick the first that fits: continue in this conversation (the next phase needs this one as a primary source) → clear (nothing here matters next) → **`/handoff`** (moving to another harness, directory, or person) → a subagent (the next task runs without you) → compact (with an instruction about what the next phase needs). Never mid-phase.
