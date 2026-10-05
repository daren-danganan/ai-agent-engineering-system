# Feature Registry

Every built feature, where it lives, and how to verify it still works. Check here before building something new — reuse first.

### F-001 — Documentation agent (doc-keeper)
- **Status:** Done
- **Location:** `.claude/agents/doc-keeper.md`, `docs/` (incl. `GUIDELINES.md`, `procedures/`)
- **Verify with:** Ask Claude Code "use doc-keeper to record this session"; confirm a new file in `docs/sessions/` and an updated `STATUS.md`
- **Depends on / used by:** —
- **Last changed:** 2026-10-04
- **Planned change (S-003, not yet changed):** doc-keeper will own `docs/ASSUMPTIONS.md` and may edit only the Status field + specs README row for In progress / Ready for review / Built (slice 4, D-007 planned)

### F-002 — Planning agent (planner)
- **Status:** Done
- **Location:** `.claude/agents/planner.md`, `.claude/commands/plan-feature.md`, `docs/specs/`
- **Verify with:** Run `/plan-feature add a hello-world script`; confirm planner reads docs first, asks one phase at a time with suggested answers, and after approval writes `docs/specs/<date>-<slug>.md` plus a row in `docs/specs/README.md`
- **Also verify:** say "I want to add a hello-world script" (no command) — the agent announces it is planning first and starts Phase 0; say "fix the typo in README" — it does not route to planner
- **Also verify (S-001):** plan a technical feature — planner spawns architect after Scope and asks its questions; plan a non-technical one — planner says it is skipping architect and why
- **Also verify (S-002):** planner shows architect's Simple/Complex verdict and lets you override; Simple skips the final review (says so); Complex gets a System redesign section, spike as slice 1, and a final review
- **Depends on / used by:** F-001 (hands off to doc-keeper), F-003 (spawns architect)
- **Last changed:** 2026-10-04 (D-005: Technical design phase + architect final review; D-006: Simple/Complex branching)
- **Planned change (S-003, not yet changed):** Phase 8 will fill a Skill column and tag each Verify with auto/manual; Output points to `/build-feature`; spec template gains new statuses (slice 6)

### F-003 — Technical advisor agent (architect)
- **Status:** Done (dry-run tested; live planner flow not yet verified)
- **Location:** `.claude/agents/architect.md`, `.claude/commands/tech-review.md`, "Technical design" section in `docs/specs/_TEMPLATE.md`
- **Verify with:** Run `/tech-review I want to pull my bike rides from Strava nightly and keep a queryable history`; confirm the output has all 8 topics (or N/A — reason), questions with suggested answers, ≤5 suggested features tagged must-have/later/drop, and that no files changed
- **Also verify (S-002):** output starts with a Complexity verdict. `/tech-review make /tech-review accept a GitHub issue URL` → Simple (≤4 questions, no System redesign); `/tech-review replace docs/ with a SQLite database and migrate existing docs` → Complex (rules listed, System redesign + spike)
- **Depends on / used by:** used by F-002 (planner Phase 5 and final review); specs S-001, S-002
- **Last changed:** 2026-10-04 (D-006: complexity verdict)
- **Planned change (S-003, not yet changed):** new "build consult" input mode with short answer format; builder becomes a caller (slice 5)

### F-004 — Builder agent
- **Status:** Planned
- **Location:** `.claude/agents/builder.md`, `.claude/commands/build-feature.md`, `.claude/skills/`, `docs/ASSUMPTIONS.md`
- **Verify with:** auto — `.claude/skills/README.md` has registry + inline template; `.claude/skills/agent-markdown/SKILL.md` frontmatter valid (name + description). manual — dry-run a toy spec on throwaway branch `build/toy-dry-run`
- **Depends on / used by:** depends on F-001, F-002, F-003
- **Last changed:** 2026-10-04 (planned in [S-003](specs/2026-10-04-builder-agent.md), [session](sessions/2026-10-04-builder-agent-planning.md))
