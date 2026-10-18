---
description: Design it twice - two architect runs on different models, judged into one sketch
argument-hint: [spec path, ticket path, or a design question]
---
Design the input below before any code is written. You orchestrate and judge; the `architect` subagents design. Edit no product code.

Input: $ARGUMENTS

1. **Ground.** Spawn `scout` on the area the input touches: how it works today and why. Read its report.
2. **Design it twice.** In one message, spawn two `architect` subagents in **design** mode, in parallel, each with the input path or question and the scout report:
   - Runner A: `model: "opus"`, no lens.
   - Runner B: `model: "sonnet"`, lens: "a structurally different shape from the obvious one; assume the first idea is wrong".
3. **Judge.** Compare the candidates on: interface depth (more hidden behind less), seam placement and test surface, locality of change, red flags remaining, and fit with the glossary and ADRs. Take the stronger candidate as the base and graft specific parts from the other only where they clearly win. If both share a weakness, say so.
4. **Write** `.scratch/<slug>/design.md` (the slug from the spec's folder, or a new one for a bare question):
   - Caller usage, data shape, sketch, seams (from the chosen design).
   - Synthesis decision: which base, what was grafted, what was rejected and why.
   - The rejected alternative in three lines, so nobody re-proposes it without new evidence.
   - Open unknowns, each with the prototype that would settle it.
5. **Reply** with a table of the two candidates (shape, depth, main risk), your pick and why in three lines, and the path. If an unknown needs a runnable answer, recommend `/prototype` for it. If a decision is hard to reverse, surprising, and a real trade-off, offer an ADR.
