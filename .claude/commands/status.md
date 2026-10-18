---
description: Where every feature stands - spec status and ticket progress from .scratch/
argument-hint: [optional slug]
---
Run `.claude/scripts/status.sh $ARGUMENTS` and show me its output as is.

Then add at most three lines:
- the next command for anything actionable: a feature with ready tickets → `/implement .scratch/<slug>`; one with no tickets → `/to-tickets`; one stuck at `building` with every ticket done → finish it with `/implement .scratch/<slug>`;
- any ticket with `needs-info`, `needs-triage` or a missing blocker, which needs me.

Do not edit any file. Feature and ticket states are defined in `docs/agents/triage-labels.md`.
