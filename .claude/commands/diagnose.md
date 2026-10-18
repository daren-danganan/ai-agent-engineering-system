---
description: Diagnose and fix a hard bug or perf regression - red loop first, root cause, regression test (debugger)
argument-hint: [the symptom, as observed]
---
Restate the symptom in your own words in two lines (what the user sees, what they expected). Then spawn the `debugger` subagent with the symptom, any repro steps, logs or artifacts I gave, and the area if known.

When it returns:

- `NO LOOP` → tell me exactly what it needs (access, a captured artifact, permission for temporary instrumentation). Do not guess at a fix.
- `ROOT CAUSE ONLY` or `FAILED` → show me the hypotheses with their evidence and what blocked the fix.
- `FIXED` → spawn `verifier` in verify mode on the original symptom. Then show me: what was broken, the root cause, the fix, and the failing-then-passing loop output verbatim.

On my go-ahead to commit: commit the regression test first (`test: reproduce <symptom>`), then the fix on top (`fix: <root cause>`), so the history shows red then green. If the debugger reported no correct seam for a regression test, suggest `/improve-architecture` for that area. Suggest `/retro` to ask what would have prevented the bug.

Symptom: $ARGUMENTS
