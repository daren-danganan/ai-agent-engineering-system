# Session — 2026-10-04 — Architect complexity verdict (Simple / Complex)

**Participants:** Daren, main agent (acting as planner), architect (dry run)

## Summary
Daren asked architect to decide whether a feature is simple (affects few components) or complex (needs system-level redesign). Auto-routed to planner; spec S-002 approved; built and dry-run tested on one Simple and one Complex sample.

## Items discussed
- Verdict changes depth **and** process (not just a label)
- Complex if any rule applies: C1 shared data model/interface, C2 migration, C3 new infrastructure, C4 touches ≥3 features/components, C5 cross-cutting concern (security, auth, core agent workflow)
- Architect proposes, Daren confirms/overrides; override recorded in the spec
- Planner keeps its technical / non-technical gate; architect classifies technical features only
- Later: a "Medium" tier; re-classifying during the build

## Decisions
- D-006 — Architect classifies technical features Simple / Complex (see DECISIONS.md)

## Changes made
- Spec S-002 — `docs/specs/2026-10-04-architect-complexity.md`
- architect: complexity rules C1–C5, "Complexity verdict" block first in output, Simple = relevant topics + ≤4 questions, Complex = all 8 topics + ≤8 questions + "System redesign" section + spike; final review re-checks verdict and runs for Complex only — `.claude/agents/architect.md`
- planner: shows verdict for confirm/override, Simple vs Complex depth, re-check rule when Add/Change grows, spike as slice 1 for Complex, final review only for Complex, Complex adds a D-### to the doc-keeper brief, Definition of Ready updated — `.claude/agents/planner.md`
- Spec template: Complexity header field and Technical design line; new "5a. System redesign" section — `docs/specs/_TEMPLATE.md`
- Dry run (direct mode): "/tech-review accepts a GitHub issue URL" → Simple, no rules, 1 component, 4 questions, no redesign section; "replace docs/ with SQLite + CLI" → Complex, C1–C5, 7 components, 8 questions, System redesign + 1-day spike (AC-1, AC-2, AC-3 architect part, AC-6 pass)

## Action items
- [ ] Live Claude Code planning session to verify planner side: verdict confirm/override (AC-4), Simple skips final review (AC-2), re-check rule (AC-5) — owner: Daren — due: TBD

## Open questions
- none
