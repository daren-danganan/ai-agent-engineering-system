# Procedure — Plan a feature with planner

- **ID:** P-002 · **Version:** 4 · **Owner:** Daren · **Last updated:** 2026-10-04
- **Use when:** Before building, changing, or removing anything that touches more than one file.

## Prerequisites
- Claude Code running in this repo (loads `.claude/agents/planner.md` and `.claude/commands/plan-feature.md`)

## Steps
1. Describe the feature you want — the agent routes it to the planner automatically. (Or run `/plan-feature <idea>` / `claude --agent planner`; say "skip planning" to opt out.)
2. Answer one phase at a time; reply "yes" to accept planner's suggested answers.
3. For technical features (data, storage, integrations, failure-prone steps), planner brings in `architect` after Scope: confirm or override its **Simple / Complex** verdict, then answer its technical questions (Simple: ≤4; Complex: all 8 topics plus a System redesign and a spike as slice 1) and pick must-have / later / drop for each suggested feature. Non-technical features skip this step. (To get a technical review on its own, run `/tech-review <idea or spec path>`.)
4. Review the acceptance criteria and build order planner proposes; edit anything wrong.
5. Pick an approach (planner recommends one). For Complex features, architect runs a final review first; then say "approved".
6. Invoke doc-keeper with the brief planner gives you (P-001).
7. Build slice 1 from the spec; run its "Verify with" check before moving on.

## Done when
- `docs/specs/<date>-<slug>.md` exists with status `Approved` and is listed in `docs/specs/README.md`.

## Pitfalls
- Delegating planner as a subagent can't interview you — it returns a draft plus questions. Use the command for real planning. (unverified)
- Adding scope mid-interview: park it under *Later* unless it's required for the goal.

## Revision history
| Version | Date | Change | Source |
|---|---|---|---|
| 1 | 2026-10-04 | Created | [session](../sessions/2026-10-04-planner-agent.md) |
| 2 | 2026-10-04 | Step 1: feature requests auto-route to planner | [session](../sessions/2026-10-04-planner-auto-routing.md) |
| 3 | 2026-10-04 | Added architect technical-design step and final review | [session](../sessions/2026-10-04-architect-agent.md) |
| 4 | 2026-10-04 | Simple/Complex verdict; final review for Complex only | [session](../sessions/2026-10-04-architect-complexity.md) |
