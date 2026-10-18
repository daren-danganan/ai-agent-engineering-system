---
description: Answer one design question with throwaway code instead of debate (prototyper)
argument-hint: [the question, and optionally the variants to compare]
---
Spawn the `prototyper` subagent with the question below and the `<slug>` of the work it belongs to (from this conversation, or a short kebab-case slug of the question). Show me its report.

Then: record the decision where it belongs (the current grilling, the spec's Implementation Decisions, or `design.md`), inlining anything under "Keep from the prototype". Ask me whether to delete `.scratch/<slug>/prototypes/<question-slug>/`; delete it on yes.

Question: $ARGUMENTS
