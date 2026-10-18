# 02: The prototyper gate reads the kit glossary in any project

**What to build:** The three kit terms live in one kit glossary (`docs/agents/glossary.md`), installed to `~/.claude/agent-kit/glossary.md` with rewritten pointers. This repo's `CONTEXT.md` keeps only a line pointing to it. The prototyper's gate and description point to the kit glossary. In a foreign project with the kit installed globally, `/prototype` refuses the taste question and builds the layout question, reading the kit glossary rather than the project's `CONTEXT.md`.

**Blocked by:** 01

**Status:** ready-for-agent

**Verify with:** reinstall into the real `~/.claude`, then `proto-taste-foreign` (`TALLY refused_clean=3 built=0`, each run's tool log reads `~/.claude/agent-kit/glossary.md` and not the fixture's `CONTEXT.md`) and `proto-layout-foreign` (variants built, a decision reported).

- [ ] `docs/agents/glossary.md` holds the three definitions as settled 2026-10-18, definitions only
- [ ] This repo's `CONTEXT.md` no longer defines them; one line points to the kit glossary
- [ ] `install-global.sh` installs the glossary to `~/.claude/agent-kit/glossary.md` and rewrites glossary pointers to it
- [ ] Prototyper gate and `description` point to the kit glossary; inline test, examples, `NOT A PROTOTYPE QUESTION` and write confinement unchanged
- [ ] `proto-taste-foreign` and `proto-layout-foreign` added to the prototype feature map with run evidence
- [ ] Existing proto journey notes no longer claim the gate reads `CONTEXT.md`
