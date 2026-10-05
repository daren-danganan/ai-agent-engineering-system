# Decision Log

Append-only. To reverse a decision, add a new entry that supersedes it.

## D-001 — Keep project documentation as Markdown in the repo
- **Date:** 2026-10-04 · **Status:** Accepted
- **Context:** Agents and humans need a shared, durable record of plan, status, discussions, and changes.
- **Decision:** Store docs in `docs/` as Markdown, maintained by the `doc-keeper` Claude Code subagent.
- **Alternatives considered:** Claude Project docs (not versioned with code); both (duplication risk).
- **Consequences:** Docs are versioned alongside code; every task should end with a doc-keeper update.
- **Source:** [session](sessions/2026-10-04-doc-keeper-setup.md)

## D-002 — doc-keeper also maintains procedures and guidelines
- **Date:** 2026-10-04 · **Status:** Accepted
- **Context:** Repeatable processes and standing rules need a home so agents follow them consistently.
- **Decision:** Add `docs/GUIDELINES.md` (rules, `G-###`) and `docs/procedures/` (step-by-step how-tos, `P-###`), both maintained by doc-keeper.
- **Alternatives considered:** A single combined file (mixes rules with how-tos; harder to scan).
- **Consequences:** doc-keeper captures new rules and procedures from every session.
- **Source:** [session](sessions/2026-10-04-doc-keeper-setup.md)

## D-003 — Plan before build; planner owns docs/specs/
- **Date:** 2026-10-04 · **Status:** Accepted
- **Context:** Agents build better and break less when goal, scope, changes, acceptance criteria, and build order are agreed up front.
- **Decision:** Add a `planner` agent that interviews the user and writes specs to `docs/specs/`. Planner is the only agent besides doc-keeper that writes in `docs/`, and only in `docs/specs/`.
- **Alternatives considered:** Skill-only (no agent file to reuse as a subagent); doc-keeper writing specs (mixes recording with planning).
- **Consequences:** Non-trivial work starts with `/plan-feature`; G-002 amended; new G-004.
- **Source:** [session](sessions/2026-10-04-planner-agent.md)

## D-004 — Auto-route feature requests to the planner
- **Date:** 2026-10-04 · **Status:** Accepted
- **Context:** Relying on the user to remember `/plan-feature` means feature work can start unplanned.
- **Decision:** When the main agent judges a message to be a feature request (build/add/change/remove), it announces and runs the planner inline before building. Skips: existing approved spec, one-file bug fix/typo, explicit "skip planning", questions/reviews.
- **Alternatives considered:** Keyword hook on user prompts (brittle, misfires on questions); planner as auto-delegated subagent (can't interview the user).
- **Consequences:** Routing rule lives in `CLAUDE.md`; planner gains an "auto-routed" mode; G-004 updated.
- **Source:** [session](sessions/2026-10-04-planner-auto-routing.md)

## D-005 — Architect as read-only technical advisor to planner
- **Date:** 2026-10-04 · **Status:** Accepted
- **Context:** planner's "Constraints & tools" phase was thin on technical design, so storage, failure handling, and data-source choices got made ad hoc during building.
- **Decision:** Add an `architect` subagent. For technical features, planner spawns it after Scope (design pass) and before approval (final review). Architect is read-only and returns questions with suggested answers across 8 topics plus ≤5 suggested features; planner stays the only interviewer and only writer of `docs/specs/` (D-003 unchanged). Also runnable directly via `/tech-review`.
- **Alternatives considered:** Checklist inside planner only (no separate perspective, not runnable alone); planner switching hats inline (context bloat); architect writing the spec's Technical design section (would amend D-003/G-002); architect on every feature (slow for process/doc changes).
- **Consequences:** Spec template gains "Technical design"; planner Phase 5/9 and Definition of Ready updated; technical planning takes two extra subagent calls.
- **Source:** [session](sessions/2026-10-04-architect-agent.md) · [spec](specs/2026-10-04-architect-agent.md)

## D-006 — Architect classifies technical features Simple / Complex
- **Date:** 2026-10-04 · **Status:** Accepted
- **Context:** D-005 gave every technical feature the same full architect pass and final review — too heavy for small changes, too little structure for real redesigns.
- **Decision:** Architect issues a Complexity verdict before its questions. Complex if any of C1 shared data model/interface, C2 migration, C3 new infrastructure, C4 ≥3 features/components, C5 cross-cutting concern; otherwise Simple. Simple: relevant topics only, ≤4 questions, no final review. Complex: all 8 topics, System redesign section, spike as slice 1, final review, new D-### recorded. Daren confirms or overrides each verdict; planner re-checks it if scope grows. Planner's technical / non-technical gate is unchanged.
- **Alternatives considered:** Label only (no behavior change); component count only (misses migrations/infra on small features); architect's unguided judgment (inconsistent); architect deciding without confirmation; architect also doing the non-technical gate (extra subagent call on every plan).
- **Consequences:** Refines D-005 (final review now Complex-only). Spec template gains Complexity field and "5a. System redesign".
- **Source:** [session](sessions/2026-10-04-architect-complexity.md) · [spec](specs/2026-10-04-architect-complexity.md)
