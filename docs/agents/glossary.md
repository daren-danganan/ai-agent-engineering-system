# Agent kit glossary

The agent kit's own terms. Definitions only; the kit's agents and docs use these terms as written here. They travel with the kit (`install-global.sh` installs this file), so they mean the same in every project. A project's own terms live in that project's glossary (`CONTEXT.md`, see `docs/agents/domain.md`), never here; this file changes only by editing the kit repo.

## Glossary

- **Empirical fork**: a design question where looking at or running a built thing would change or settle the answer. Which layout reads better side by side, which approach is faster, whether a tool handles a case. Settled with `/prototype`, not by asking the human.
- **Taste question**: a design question where seeing it built would not change anyone's answer. Whether a name is nicer, which style someone prefers. A decision for the human; never prototyped.
- **Mixed question**: a taste question that also contains a measurable part. Treated as a taste question as a whole; the measurable part may be named, and asked separately as its own empirical fork.
