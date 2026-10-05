# Guidelines

Standing rules for everyone working on this project — humans and agents. Retired rules are struck through, not deleted.

### G-001 — Read project memory before starting work
- **Rule:** Read `docs/STATUS.md`, `docs/PLAN.md`, `docs/FEATURES.md`, and relevant `docs/procedures/` before starting a task.
- **Why:** Avoids duplicate work and reuses existing features.
- **Applies to:** all agents
- **Since:** 2026-10-04 (D-001)

### G-002 — Record every task through doc-keeper
- **Rule:** After any task or discussion, invoke `doc-keeper` with a brief; other agents do not edit `docs/` directly (exception: `planner` writes `docs/specs/`, D-003).
- **Why:** Keeps documentation complete and consistently formatted.
- **Applies to:** all agents
- **Since:** 2026-10-04 (D-001)

### G-003 — Every feature is verifiable
- **Rule:** Every entry in `FEATURES.md` has a `Verify with` check, and that check is re-run when the feature is touched.
- **Why:** Prevents new work from silently breaking old features.
- **Applies to:** all agents
- **Since:** 2026-10-04 (setup session)

### G-004 — Plan before you build
- **Rule:** Any new feature, change, or removal that touches more than one file starts from an `Approved` spec in `docs/specs/`. Feature requests are routed to the planner automatically (CLAUDE.md, D-004); the user can say "skip planning".
- **Why:** Agreed scope, acceptance criteria, and build order keep work fast and prevent regressions.
- **Applies to:** all agents
- **Since:** 2026-10-04 (D-003)
