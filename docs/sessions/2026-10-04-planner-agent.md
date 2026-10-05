# Session — 2026-10-04 — Planning agent

**Participants:** Daren, Claude

## Summary
Created the `planner` agent, which interviews the user to produce a spec (goal, audience, existing/added/changed/removed, scope, tools, acceptance criteria, approach options, build order) before any build work starts.

## Items discussed
- Need an agent that asks: what we're building, what exists, what's being removed, build order
- It should build requirements, scope, tools, audience, goal, and acceptance criteria by interviewing the user
- It should suggest how to reach the goal quickly, efficiently, and with the best quality
- Claude Code subagents can't converse with the user mid-run, so planner runs interactively via `claude --agent planner` or `/plan-feature`; when delegated, it drafts and returns questions

## Decisions
- D-003 — Plan before build; planner owns `docs/specs/`

## Changes made
- Added `.claude/agents/planner.md`, `.claude/commands/plan-feature.md`
- Added `docs/specs/_TEMPLATE.md`, `docs/specs/README.md`
- Added procedure P-002, guideline G-004; amended G-002; updated `CLAUDE.md` and doc-keeper's file table

## Action items
- [ ] Try planner on the next real feature and refine the interview — owner: Daren — due: TBD

## Open questions
- What is out of scope for now? (carried over)
