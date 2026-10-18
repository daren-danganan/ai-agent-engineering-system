# 03: The griller and the principles use the glossary terms

**What to build:** The griller's question-sorting rules and the principles' lines on decisions versus empirical forks use the glossary terms "taste question" and "empirical fork" and point to `CONTEXT.md`, instead of each wording the line its own way. The griller still sends empirical forks to `/prototype` and asks the human taste questions; only the wording and the single source of the definition change.

**Blocked by:** None (can start immediately)

**Status:** done

**Verify with:** a static grep over the griller agent file and the principles doc (both terms present, a pointer to `CONTEXT.md`, no competing definition of taste left), plus the existing grill journey in the feature map still passing on a fresh drive.

- [ ] The griller's sorting rules name "taste question" and "empirical fork" and reference the glossary
- [ ] The principles' two sorting lines use the same terms and reference the glossary
- [ ] No file other than `CONTEXT.md` defines what a taste question is
- [ ] The grill journey passes on a fresh drive

## Comments

- Commit: 70c3d0d.
- Verifier: PASS. Static grep: only CONTEXT.md defines taste. Grill journey passed every step on a fresh sandbox (run 20261018-102421-6713). proto-taste and proto-layout re-driven after the description change, no regression. Observation: a /grill with a mixed idea sorted the name question to the human and the layout question to /prototype.
- Implementer assumptions: reworded the feature-map summary at features/prototype.md:3; left historical run records alone; removed the bracketed examples from the griller's empirical-fork bullet in favor of quoting the glossary test; added a griller bullet for mixed questions; the prototyper description keeps its routing examples and points to CONTEXT.md.
