# Spec — Architect complexity verdict (Simple / Complex)

- **ID:** S-002 · **Status:** Built · **Complexity:** Simple (extends 3 existing files; confirmed by Daren)
- **Date:** 2026-10-04 · **Owner:** Daren · **Planned by:** planner
- **Related:** F-003 (architect) · F-002 (planner) · S-001 · D-005

## 1. Goal
- **What:** architect classifies every technical feature as **Simple** (affects a small number of components) or **Complex** (needs system-level redesign), and planning depth/process follows the verdict.
- **For whom:** planner, Daren
- **Problem / why now:** S-001 gives every technical feature the same full pass — too heavy for small changes, and not enough structure for real redesigns.
- **Success metric:** every technical spec records a confirmed verdict with the triggered rules; Complex specs have a System redesign section and a spike as slice 1; Simple plans ask ≤4 technical questions.

## 2. What exists
| Existing item | Where | Reuse / extend / leave alone |
|---|---|---|
| F-003 architect | `.claude/agents/architect.md` | Extend — verdict rules + Simple/Complex output |
| F-002 planner | `.claude/agents/planner.md` | Extend — confirm verdict, branch final review/spike, re-check rule |
| Spec template | `docs/specs/_TEMPLATE.md` | Extend — Complexity field + System redesign section |
| `/tech-review` | `.claude/commands/tech-review.md` | Leave alone — shows architect output as-is (verdict included) |

## 3. Changes
**Add**
- Complexity verdict rules (C1–C5) and "Complexity verdict" output block in architect
- "System redesign" output section (Complex only) in architect and spec template

**Change**
- architect.md — depth branches on verdict — impact: F-003, F-002 — regression check: F-003 Verify with (RC-1)
- planner.md — Phase 5 shows verdict and lets Daren override; Phase 8 spike-first for Complex; Phase 9 final review only for Complex; re-check verdict if Add/Change grows — impact: F-002 — regression check: F-002 Verify with (RC-2)
- `_TEMPLATE.md` — Complexity header field, section 5a System redesign — impact: future specs — regression check: planner writes a valid spec (RC-2)

**Remove**
- Final review for Simple technical features (was always-on in S-001) — dependents: F-002 — migration: none — remove after: slice 3

## 4. Scope
- **In scope (MVP):** verdict rules, Simple/Complex output branches, planner confirm/override + branching + re-check, template fields.
- **Later:** a "Medium" tier; re-classifying during the build.
- **Out of scope:** changing planner's technical / non-technical gate.

## 5. Technical design
- **Complexity:** Simple — touches 3 agent/template files of one subsystem; no data model, infra, or migration.
- Data source / Storage / Failure handling / Security / Performance / Observability: N/A — prompt-only change to Markdown agent definitions.
- **Testing strategy:** dry-run architect on one Simple and one Complex sample idea.
- **Architect final review:** N/A — Simple.

## 5b. Constraints & tools
- Must not change: planner is sole interviewer and sole writer of `docs/specs/` (D-003); architect read-only (D-005); planner's technical gate (D-005).

## 6. Acceptance criteria
- [ ] AC-1 — Given architect runs, then output starts with a Complexity verdict: Simple/Complex, triggered rules, affected components (+ count), one-line reason.
- [ ] AC-2 — Given Simple, then ≤4 questions, no System redesign section, and planner skips the final review saying so.
- [ ] AC-3 — Given Complex, then all 8 topics covered, System redesign section filled (current → target, affected components/interfaces, migration & rollback, decision to record), slice 1 is a time-boxed spike, final review runs, and doc-keeper brief includes a new D-###.
- [ ] AC-4 — Given a verdict, planner shows it to Daren before the technical questions; Daren can override; override recorded in the spec.
- [ ] AC-5 — Given Add/Change lists grow after Phase 5, then planner asks architect to re-check the verdict.
- [ ] AC-6 — `/tech-review` output includes the verdict.
- [ ] RC-1 — F-003 Verify with still passes. RC-2 — F-002 Verify with still passes. RC-3 — F-001 Verify with still passes.

## 7. Approach
**Chosen:** extend existing files only (M). No new agents or commands.

## 8. Build order
| # | Slice | Areas / files | Depends on | Verify with | Size |
|---|---|---|---|---|---|
| 1 | Verdict rules + Simple/Complex output in architect | `.claude/agents/architect.md` | — | AC-1, AC-2, AC-3 (architect part) | M |
| 2 | Complexity field + System redesign in template | `docs/specs/_TEMPLATE.md` | — | sections present | S |
| 3 | planner confirm/override, branching, re-check | `.claude/agents/planner.md` | 1, 2 | AC-2–AC-5 (planner part), RC-2 | M |
| 4 | Dry run: one Simple, one Complex sample | — | 1 | AC-1–AC-3, AC-6, RC-1 | S |
| 5 | Record via doc-keeper | `docs/` | 4 | F-003/F-002 entries updated | S |

## 9. Risks, assumptions & open questions
- **Risks:** borderline features misclassified — mitigated by Daren's confirmation and the re-check rule.
- **Assumptions:** none
- **Open questions:** none
