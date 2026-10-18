# 03: The griller and principles use the kit glossary

**What to build:** The griller's question sorting and the principles' taste-question / empirical-fork lines point to the kit glossary. The griller keeps writing resolved terms into the project glossary, and both the griller and "Shared language" say the kit glossary changes only by editing the kit repo. Reinstalled, no installed kit file points to `CONTEXT.md` for kit terms.

**Blocked by:** 02

**Status:** done

**Verify with:** run `install-global.sh` with `CLAUDE_HOME` set to a temp dir and grep the installed tree: no kit-term pointer to `CONTEXT.md` in the installed prototyper, griller or principles; `~/.claude/agent-kit/glossary.md` pointers present; `NOT A PROTOTYPE QUESTION` and the write-confinement rule unchanged. Plus the spec's source grep.

- [x] Griller step 3 sorts by the kit glossary
- [x] Griller step 4 still writes project terms to the project glossary, plus the one-line kit-glossary rule
- [x] Principles' two "how the two fit together" lines point to the kit glossary
- [x] "Shared language" stays project-level and gains the kit-glossary rule
- [x] Real `~/.claude` reinstalled from this branch
