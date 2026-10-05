# Engineering System for AI Agents

## Project memory lives in `docs/`
- **Before starting work:** read `docs/STATUS.md`, `docs/PLAN.md`, `docs/FEATURES.md`, and `docs/GUIDELINES.md`. Follow any matching procedure in `docs/procedures/`. Reuse existing features before building new ones.
- **After finishing any task or discussion:** invoke the `doc-keeper` subagent with a short brief — what was discussed, decided, and changed, plus any open questions. Do not skip this step.
- Do not edit `docs/` directly from other agents; route updates through `doc-keeper` so formats stay consistent.

## Feature requests go to the planner first
If the user's message asks to **build, add, create, change, replace, or remove a feature** (or describes something new they want the system to do), do not start building. The planner takes over:

1. Say in one line: "This looks like a new feature — I'll plan it with the planner first (say 'skip planning' to go straight to building)."
2. Read `.claude/agents/planner.md` and act as the planner **in this conversation** (interactive mode, same as `/plan-feature`). Do not delegate it as a subagent — a subagent can't interview the user.
3. Build only after the spec in `docs/specs/` is `Approved`, following its build order.

Skip the planner when:
- an `Approved` spec in `docs/specs/` already covers the request — build from it;
- it's a bug fix, typo, or small change confined to one file;
- the user says "skip planning" (note the skip in the doc-keeper brief);
- it's a question, explanation, or review — nothing is being built.

If unsure whether a request counts as a feature, ask once: "Plan this first, or just do it?"

