---
description: Compact this conversation into a handoff file another agent or person can continue from
argument-hint: [optional: who or where it's going, and what they'll do next]
---
Write a handoff document so a fresh agent can continue this work without this conversation.

Save it to `${TMPDIR:-/tmp}/handoff-<slug>-<timestamp>.md` (or `.scratch/<slug>/handoff.md` if I ask to keep it in the repo) and give me the path. Use pointers, not pasted content: link to specs, tickets, designs, commits, and files instead of restating them.

Sections:
- **Goal** — in my words, then yours in one line.
- **State** — what is done (with commits and verifier verdicts), in progress, and not started. Label each claim measured, read, or inferred.
- **Decisions** — what we decided and why, with ADR and glossary links.
- **Open questions** — each with your recommended answer.
- **Next step** — the exact command or action to run first.
- **Traps** — what wasted time here and should not be repeated.

Destination: $ARGUMENTS
