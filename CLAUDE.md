## How work flows here

Agents live in `.claude/agents/`, commands in `.claude/commands/`. Which to use when: `docs/agents/flows.md`. The judgment they share: `docs/agents/principles.md`.

- **Building, adding, changing or removing a feature** → say "This is a new feature, so I'll grill it first (say 'skip planning' to go straight to building)", then run the `/grill` procedure in this conversation. Skip it for a typo, a one-file fix, a question, or when a `.scratch/<slug>/` spec already covers the request.
- **Something broken, failing or slow** → `/diagnose`.
- **"How does X work" / "why is Y like this"** → spawn `scout`. Look facts up; never ask the user what the code can tell you.
- **Done means proven on the real artifact**, not "it compiles". Use the feature map in `.claude/skills/verify-agent-system/features/`.

## Agent skills

### Issue tracker

Issues and specs live as local markdown files under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage roles, unchanged: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
