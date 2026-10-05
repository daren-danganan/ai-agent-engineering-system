# Session — 2026-10-04 — Auto-route feature requests to planner

**Participants:** Daren, Claude

## Summary
When the agent judges a user message to be a new-feature request, the planner now takes over automatically before any building.

## Items discussed
- Daren wants the planner to take over whenever the agent thinks a new feature is being requested
- The planner must run inline in the main conversation (a subagent can't interview the user)
- Skip cases needed so small fixes and questions aren't slowed down

## Decisions
- D-004 — Auto-route feature requests to the planner

## Changes made
- Routing rule — `CLAUDE.md`
- Auto-routed mode — `.claude/agents/planner.md`
- G-004 updated; P-002 → v2; F-002 verify steps extended

## Action items
- [ ] Verify auto-routing with a feature request and a one-file fix — owner: Daren — due: TBD

## Open questions
- Is "one file" the right threshold for skipping planning?
