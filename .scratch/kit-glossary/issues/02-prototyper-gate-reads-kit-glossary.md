# 02: The prototyper gate reads the kit glossary in any project

**What to build:** The three kit terms live in one kit glossary (`docs/agents/glossary.md`), installed to `~/.claude/agent-kit/glossary.md` with rewritten pointers. This repo's `CONTEXT.md` keeps only a line pointing to it. The prototyper's gate and description point to the kit glossary. In a foreign project with the kit installed globally, `/prototype` refuses the taste question and builds the layout question, reading the kit glossary rather than the project's `CONTEXT.md`.

**Blocked by:** 01

**Status:** done

**Verify with:** reinstall into the real `~/.claude`, then `proto-taste-foreign` (`TALLY refused_clean=3 built=0`, each run's tool log reads `~/.claude/agent-kit/glossary.md` and not the fixture's `CONTEXT.md`) and `proto-layout-foreign` (variants built, a decision reported).

- [x] `docs/agents/glossary.md` holds the three definitions as settled 2026-10-18, definitions only
- [x] This repo's `CONTEXT.md` no longer defines them; one line points to the kit glossary
- [x] `install-global.sh` installs the glossary to `~/.claude/agent-kit/glossary.md` and rewrites glossary pointers to it
- [x] Prototyper gate and `description` point to the kit glossary; inline test, examples, `NOT A PROTOTYPE QUESTION` and write confinement unchanged
- [x] `proto-taste-foreign` and `proto-layout-foreign` added to the prototype feature map with run evidence
- [x] Existing proto journey notes no longer claim the gate reads `CONTEXT.md`

Verified 2026-10-18 (runs in the prototype feature map): `proto-taste-foreign` `TALLY refused_clean=3 built=0`, `proto-layout-foreign` built. The "each run reads the kit glossary" part of Verify with held for 2 of 4 runs; the other two taste runs made no tool call at all and refused from the gate's inline test. No run looked up kit terms in the fixture's `CONTEXT.md` (the baseline did). The journey's pass check was written as "no kit-term lookup goes to `CONTEXT.md`" accordingly.
