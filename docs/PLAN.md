# Project Plan — Engineering System for AI Agents

_Last updated: 2026-10-04_

## Goal
Build an engineering system that helps AI agents accomplish goals with high quality, efficiency, and speed — without breaking previously built features (preventing "AI decay") and by reusing related features when building new ones.

## Scope
**In scope**
- Agent roles and workflows: documentation (`doc-keeper`), planning (`planner`), technical design (`architect`), building (`builder`, planned — S-003)
- Project memory in `docs/` (plan, status, decisions, changes, feature registry)

**Out of scope (for now)**
- ~~TBD~~ (superseded 2026-10-04, see S-003)
- Reviewer/tester agent — out of scope for M4; separate future spec (Daren reviews manually until it exists)

**Later (noted in S-003, not scheduled)**
- Python / TypeScript stack skills
- `/review-assumptions` command
- Parallel slice builds
- Scripted auto checks for F-001–F-003
- Skill lint
- Reviewer/tester agent spec

## Milestones
| # | Milestone | Status | Target |
|---|---|---|---|
| M1 | Documentation agent + docs structure | Done | 2026-10-04 |
| M2 | Planning agent (planner) + specs | Done | 2026-10-04 |
| M3 | Technical advisor agent (architect) + spec Technical design + Simple/Complex verdict | Done | 2026-10-04 |
| M4 | Builder agent + stack skills + assumptions register ([S-003](specs/2026-10-04-builder-agent.md)) | Planned | TBD |

## Open questions
- TBD
