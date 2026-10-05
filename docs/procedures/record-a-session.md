# Procedure — Record a session with doc-keeper

- **ID:** P-001 · **Version:** 1 · **Owner:** Daren · **Last updated:** 2026-10-04
- **Use when:** A task, work session, or discussion has ended.

## Prerequisites
- Claude Code running in this repo (so `.claude/agents/doc-keeper.md` is loaded)

## Steps
1. Write a short brief: what was discussed, decided, and changed; new rules or procedures; open questions.
2. In Claude Code, say: "Use doc-keeper to record this session: <brief>".
3. Review doc-keeper's report and resolve anything listed under "Needs attention".

## Done when
- A new file exists in `docs/sessions/` and `docs/STATUS.md` shows today's date.

## Pitfalls
- A vague brief produces vague docs — name files, decisions, and owners.

## Revision history
| Version | Date | Change | Source |
|---|---|---|---|
| 1 | 2026-10-04 | Created | [session](../sessions/2026-10-04-doc-keeper-setup.md) |
