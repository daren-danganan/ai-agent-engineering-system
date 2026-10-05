# Session — 2026-10-04 — Builder agent planning (S-003)

**Participants:** Daren, main agent (acting as planner, auto-routed via CLAUDE.md), architect (design pass + final review)

## Summary
Daren asked for an agent that builds according to the plan, uses stack-specific skills (stack, conventions, language) depending on the feature, and tells doc-keeper about assumptions to review later. Auto-routed to planner; spec [S-003](../specs/2026-10-04-builder-agent.md) **Approved** by Daren on 2026-10-04. Complexity: **Complex** (C1, C4, C5), confirmed by Daren. Architect final review found 7 gaps (Q1–Q7), all resolved and applied to the spec. Nothing built yet — status **Planned**.

## Items discussed
- Trigger: builder runs automatically after spec approval (CLAUDE.md step 3, switched in slice 7) and via `/build-feature <spec> [--from N]`
- Orchestration: main agent orchestrates; one fresh builder subagent per slice, sequential (parallel slices = Later). Builder never asks the user — it logs assumptions or returns `BLOCKED`
- Skills: native Claude Code skills at `.claude/skills/<stack>/SKILL.md`; registry + template inline in `.claude/skills/README.md` (no `_template/` folder — every folder there loads as a skill). MVP skills: template + `agent-markdown`. Missing stack → builder drafts an unreviewed skill and logs an assumption
- Skills hold stack conventions; `GUIDELINES.md` keeps cross-cutting G-### rules; G-### wins on conflict
- Assumptions register `docs/ASSUMPTIONS.md`, owned by doc-keeper: `A-###` with source, decided by, alternatives, impact, status Open / Confirmed / Rejected; relayed per slice; Open count shown in STATUS "Needs attention"
- Builder consults architect directly (`Agent(architect)`) via a new architect build-consult mode
- Git required: clean tree, branch `build/<slug>` per spec, commit per slice, 2 fix attempts then scoped rollback, merge `--no-ff` only after Built
- Checks tagged auto / manual; a failed manual check counts as a fix attempt
- Spec status flow: Approved → In progress → Ready for review → Built; doc-keeper may edit only the Status field + specs README row for these
- Review/test agent (Daren has one in mind) is a separate future spec; on its sign-off doc-keeper marks Built. Until it exists, Daren reviews manually
- Approach B (balanced), 7 slices: 1 spike (30 min) · 2 git baseline + skills registry · 3 `agent-markdown` skill · 4 `ASSUMPTIONS.md` + doc-keeper + D-007 · 5 builder + `/build-feature` + architect consult, toy dry-run on throwaway branch · 6 spec template + planner Phase 8 · 7 CLAUDE.md step 3 + P-003
- Later: Python/TS skills, `/review-assumptions`, parallel slices, scripted auto checks for F-001–F-003, skill lint, reviewer/tester agent spec

## Decisions
- Approach B and the design choices above, as recorded in S-003 (approved by Daren)
- **Planned, not yet in effect:** D-007 — spec status flow (In progress / Ready for review / Built) and doc-keeper status-only spec edits, amending D-003 / G-002. Lands in build slice 4; not appended to `DECISIONS.md` yet

## Changes made
- Spec S-003 written by planner — `docs/specs/2026-10-04-builder-agent.md`, row in `docs/specs/README.md`
- F-004 Builder agent registered as Planned; F-001–F-003 noted as to-be-changed by S-003 — `docs/FEATURES.md`
- M4 defined (Planned, S-003) + Later scope notes — `docs/PLAN.md`
- `docs/STATUS.md`, `docs/CHANGELOG.md` updated
- Confirmed `Agent` is the correct tool name (Task renamed to Agent; Task still an alias) per https://code.claude.com/docs/en/sub-agents — resolves STATUS item

## Action items
- [ ] Run slice 1 spike prompt in Claude Code and record results (a)–(d) — owner: Daren — due: TBD
- [ ] Run `git init` + baseline commit (slice 2 prerequisite) — owner: Daren — due: TBD
- [ ] Build S-003 slices 2–7 — owner: main agent / builder — due: TBD
- [ ] Plan the reviewer/tester agent spec — owner: Daren + planner — due: TBD

## Open questions
- Slices 5–7 change builder's own files, so they are built by the main agent directly (spec ASSUMPTION)
- Spec assumptions to verify in spike: `Agent(architect)` restricts builder to spawning only architect; subagent spawn depth default allows builder → architect
