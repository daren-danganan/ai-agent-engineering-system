---
description: Answer one design question with throwaway code instead of debate (prototyper)
argument-hint: [the question, and optionally the variants to compare]
---
Spawn the `prototyper` subagent with the question below, word for word, and the `<slug>` of the work it belongs to (from this conversation, or a short kebab-case slug of the question). Do not reword, sharpen or reframe the question, and do not suggest what to build or measure: deciding whether the question can be prototyped is the prototyper's call. Show me its report.

If the report is `NOT A PROTOTYPE QUESTION`, stop there: record nothing and write no files.

Otherwise: record the decision where it belongs (the current grilling, the spec's Implementation Decisions, or `design.md`), inlining anything under "Keep from the prototype". Ask me whether to delete `.scratch/<slug>/prototypes/<question-slug>/`; delete it on yes.

Question: $ARGUMENTS
