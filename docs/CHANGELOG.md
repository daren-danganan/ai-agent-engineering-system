# Changelog

Newest first.

## 2026-10-04
### Docs
- Spec S-003 Builder agent + stack skills (Approved, Complex) written by planner — `docs/specs/2026-10-04-builder-agent.md`, `docs/specs/README.md` ([session](sessions/2026-10-04-builder-agent-planning.md))
- F-004 Builder agent added as Planned; planned S-003 changes noted under F-001–F-003 — `docs/FEATURES.md`
- M4 defined (Planned) + out-of-scope and Later notes — `docs/PLAN.md`
- Next up, recently done, resolved `Agent` tool-name item — `docs/STATUS.md`
- Session note — `docs/sessions/2026-10-04-builder-agent-planning.md`
### Changed
- architect: Simple/Complex verdict (rules C1–C5), depth branches on it, System redesign section for Complex — `.claude/agents/architect.md` (D-006, [session](sessions/2026-10-04-architect-complexity.md))
- planner: confirm/override verdict, re-check rule, spike-first and final review for Complex only — `.claude/agents/planner.md` (D-006)
- Spec template: Complexity field + "5a. System redesign" — `docs/specs/_TEMPLATE.md`
- P-002 v4 — `docs/procedures/plan-a-feature.md`
### Added
- Spec S-002 — `docs/specs/2026-10-04-architect-complexity.md`
### Added
- `architect` technical-advisor agent and `/tech-review` command — `.claude/agents/architect.md`, `.claude/commands/tech-review.md` (D-005, [session](sessions/2026-10-04-architect-agent.md))
- First spec S-001 — `docs/specs/2026-10-04-architect-agent.md`
### Changed
- planner: Phase 5 "Technical design & constraints" spawns architect; Phase 9 adds architect final review; Definition of Ready adds 8-topic check; `Agent` tool added — `.claude/agents/planner.md` (D-005)
- Spec template: "Technical design" section added — `docs/specs/_TEMPLATE.md`
- P-002 v3: architect step — `docs/procedures/plan-a-feature.md`
### Changed
- Feature requests auto-route to planner — `CLAUDE.md`, `.claude/agents/planner.md`, G-004, P-002 v2 (D-004, [session](sessions/2026-10-04-planner-auto-routing.md))
### Added
- `planner` agent and `/plan-feature` command — `.claude/agents/planner.md`, `.claude/commands/plan-feature.md` ([session](sessions/2026-10-04-planner-agent.md))
- Spec template and index — `docs/specs/_TEMPLATE.md`, `docs/specs/README.md`
- G-004 and P-002; G-002 amended (D-003)
- `doc-keeper` documentation subagent — `.claude/agents/doc-keeper.md`
- Docs structure — `docs/PLAN.md`, `STATUS.md`, `DECISIONS.md`, `CHANGELOG.md`, `FEATURES.md`, `sessions/`
- Project instructions — `CLAUDE.md`
- Guidelines and procedures — `docs/GUIDELINES.md`, `docs/procedures/` (P-001); doc-keeper updated to maintain them (D-002)
