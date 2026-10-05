# Spec — Architect agent (technical advisor to planner)

- **ID:** S-001 · **Status:** Built
- **Date:** 2026-10-04 · **Owner:** Daren · **Planned by:** planner
- **Related:** F-002 (planner) · F-001 (doc-keeper) · D-003 · D-004 · M3

## 1. Goal
- **What:** An `architect` agent that raises the technical questions a plan must answer (data source, storage, failure handling, etc.) and suggests related features, feeding answers into planner's spec.
- **For whom:** `planner` (as a subagent) and Daren (directly via `/tech-review`).
- **Problem / why now:** planner covers goal/scope/criteria well but its "Constraints & tools" phase is thin on technical design, so storage, failure, and data-source decisions get made ad hoc during building.
- **Success metric:** Every technical spec has all 8 technical topics answered (or marked `TBD`/`ASSUMPTION`/`N/A — reason`) before it is `Approved`.

## 2. What exists
| Existing item | Where | Reuse / extend / leave alone |
|---|---|---|
| F-002 planner | `.claude/agents/planner.md` | Extend — new Technical design phase + final review; stays sole interviewer and sole writer of `docs/specs/` |
| Spec template | `docs/specs/_TEMPLATE.md` | Extend — add "Technical design" section |
| `/plan-feature` command | `.claude/commands/plan-feature.md` | Reuse as pattern for `/tech-review` |
| F-001 doc-keeper | `.claude/agents/doc-keeper.md` | Reuse — records the session, F-003, decision |

## 3. Changes
**Add**
- `.claude/agents/architect.md` — read-only technical advisor subagent
- `.claude/commands/tech-review.md` — run architect directly on an idea or spec path

**Change**
- `planner.md` — Phase 5 becomes "Technical design" (absorbs Constraints & tools; spawns architect for technical features, skips with a one-line reason otherwise); Phase 9 adds an architect final review before approval — impact: F-002 — regression check: F-002 `Verify with` checks (RC-1)
- `docs/specs/_TEMPLATE.md` — add "Technical design" section (8 topics) — impact: future specs only — regression check: planner still writes a valid spec (RC-1)
- `docs/procedures/plan-a-feature.md` (P-002) — mention architect step (via doc-keeper)

**Remove**
- none

## 4. Scope
- **In scope (MVP):** architect agent; planner design phase + final review + skip rule; template section; `/tech-review` command.
- **Later:** post-build code review by architect; retro-review of past specs; architecture/data-flow diagrams; per-topic checklist files and a sample-spec test fixture (option C).
- **Out of scope:** architect editing any file.

## 5. Constraints & tools
- **Stack / tools / agents:** Claude Code subagent. architect tools: Read, Glob, Grep, Bash (inspection only), WebSearch, WebFetch.
- **Deadline:** none
- **Non-functional:** architect is read-only; ≤5 suggested features per run; keep output scannable.
- **Must not change:** planner is the only interviewer and the only writer of `docs/specs/` (D-003); auto-routing rules (D-004).

## 6. Acceptance criteria
- [ ] AC-1 — Given a technical feature request, when planner finishes Scope, then it spawns architect and asks Daren architect's questions, each with a suggested answer.
- [ ] AC-2 — Given architect runs, then its output covers all 8 topics (data source, storage, failure handling, security & privacy, performance & cost, testing strategy, observability, suggested features); non-applicable topics are marked "N/A — reason".
- [ ] AC-3 — Given architect suggests features, then there are ≤5, each with reason + reuse note; Daren picks must-have / later / drop; later items go to the spec's *Later* list.
- [ ] AC-4 — Given a draft spec, when planner reaches final confirmation, then architect runs a final review and gaps are raised before "approved".
- [ ] AC-5 — Given a non-technical request, then planner skips architect and says why in one line.
- [ ] AC-6 — Given `/tech-review <idea or spec path>`, then architect returns questions and findings and edits no files.
- [ ] AC-7 — Given an approved technical spec, then its "Technical design" section has all 8 topics answered or marked TBD/ASSUMPTION/N/A.
- [ ] RC-1 (regression) — F-002 `Verify with` checks still pass (interview, auto-routing, typo skip).
- [ ] RC-2 (regression) — F-001 `Verify with` check still passes.

## 7. Approach
| Option | Reuses | Tools | Effort | Risks / trade-offs |
|---|---|---|---|---|
| A. Fastest | planner only | — | S | Technical checklist inside planner; no separate perspective; not runnable alone |
| B. Balanced | planner, plan-feature pattern, template | subagent + command | M | Two subagent calls per technical feature (slightly slower planning) |
| C. Most robust | as B | + checklist files, test fixture | L | More to maintain before value is proven |

**Recommended:** B — matches the chosen design, keeps planner as single interviewer and D-003 intact; C extras can follow. · **Chosen:** B

## 8. Build order
| # | Slice | Areas / files | Depends on | Verify with | Size |
|---|---|---|---|---|---|
| 1 | architect agent with 8-topic output format | `.claude/agents/architect.md` | — | AC-2, AC-6 on a sample idea | M |
| 2 | `/tech-review` command | `.claude/commands/tech-review.md` | 1 | AC-6 | S |
| 3 | Technical design section in template | `docs/specs/_TEMPLATE.md` | — | template renders all 8 topics | S |
| 4 | planner design phase + final review + skip rule | `.claude/agents/planner.md` | 1, 3 | AC-1–AC-5, RC-1 | M |
| 5 | End-to-end dry run on a sample technical feature | — | 4 | AC-7, RC-1, RC-2 | S |
| 6 | Record via doc-keeper (F-003, decision, P-002) | `docs/` | 5 | F-003 entry exists | S |

## 9. Risks, assumptions & open questions
- **Risks:** Planning gets longer for technical features; architect questions may overlap planner's — mitigated by planner merging/deduplicating before asking.
- **Assumptions:** ASSUMPTION: Claude Code subagents can be spawned from the main conversation while it is acting as planner (same mechanism as doc-keeper).
- **Open questions:** none
