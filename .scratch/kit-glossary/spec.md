# Kit glossary that travels with the global install

Status: ready-for-agent

## Problem Statement
The taste-question-gate work (2026-10-18) defined **taste question**, **empirical fork** and **mixed question** in this repo's `CONTEXT.md`, and made the prototyper, the griller and the principles point there. Those terms belong to the agent kit, not to this repo. `install-global.sh` copies the agents into `~/.claude` for every project, and in any other project `CONTEXT.md` is that project's own glossary, or missing. So outside this repo the griller's question sorting and the principles' "decisions vs. empirical forks" rule point at the wrong file, and the prototyper's gate survives only because it quotes the test inline. The user has already run the installer, so their `~/.claude` carries these broken pointers today.

## Solution
The kit gets its own glossary file, installed alongside the principles, and every kit-term pointer moves to it. Each project's `CONTEXT.md` stays that project's glossary. In a different project with the kit installed globally, the agents read the kit's definitions, `/prototype` still refuses a taste question, and it still builds a layout question. The verify harness gains a lasting foreign-project mode, so this check (and future checks of kit pointers) runs against a project that is not this repo.

## User Stories
1. As a kit user in another project, I want the griller to sort my questions as taste questions or empirical forks using the kit's definitions, so that it asks me only decisions.
2. As a kit user in another project, I want `/prototype` to refuse a taste question, so that no throwaway code gets built for a question that seeing it built would not settle.
3. As a kit user in another project, I want `/prototype` to still build an empirical fork such as a layout comparison, so that the gate does not over-refuse.
4. As a kit user whose project has its own `CONTEXT.md`, I want the kit to leave that file as my project's glossary, so that kit terms do not mix with my domain terms.
5. As a kit user, I want resolved terms from a grilling to land in my project's glossary, never in the kit glossary, so that the next install does not silently overwrite them.
6. As the kit maintainer, I want one definition of each kit term, so that competing definitions cannot creep back in.
7. As the kit maintainer, I want this repo's `CONTEXT.md` to point to the kit glossary, so that a later grilling here does not write the kit terms back into it.
8. As the kit maintainer, I want to re-run the installer and have it ship the glossary with rewritten pointers, so that my existing global install is repaired.
9. As the kit maintainer, I want the verify harness to drive a foreign fixture project with the globally installed kit, so that every kit pointer can be proven outside this repo.
10. As an agent reading the prototyper, I want the one-line test and per-term actions still inline, so that the gate works even if the glossary cannot be read.

## Implementation Decisions
- **Kit glossary.** A new kit doc, `docs/agents/glossary.md`, holds the three definitions exactly as settled on 2026-10-18 (the one test: would seeing it built change anyone's answer?). It is the single definition. Definitions only.
- **This repo's `CONTEXT.md`.** The three terms are removed; one line says the agent kit's own terms live in the kit glossary. It remains this repo's project glossary.
- **Installer.** `install-global.sh` installs the glossary to `~/.claude/agent-kit/glossary.md` alongside principles, flows and triage-labels, and its rewrite rules turn repo-relative glossary pointers into `~/.claude/agent-kit/glossary.md`, the same way principles pointers are rewritten.
- **Prototyper.** Its gate and its `description` frontmatter point to the kit glossary instead of `CONTEXT.md`. The inline test, the per-term examples and actions, the `NOT A PROTOTYPE QUESTION` token and the write-confinement rule are unchanged.
- **Griller.** Step 3's question sorting points to the kit glossary. Step 4 keeps writing resolved terms into the project glossary named by the domain doc, plus one line: the kit glossary changes only by editing the kit repo.
- **Principles.** The two "how the two fit together" lines on taste questions and empirical forks point to the kit glossary. "Shared language" stays about the project glossary and gains the same one-line rule about who edits the kit glossary.
- **Verify harness foreign-project mode.** A small fixture project ships with the verify skill, with an unrelated glossary (a bookstore domain, no kit terms) as its `CONTEXT.md`. `launch` gains a fixture option that copies the fixture into the sandbox instead of this repo. A drive option loads user scope (`--setting-sources user,project,local`) so the globally installed agents and commands load. `doctor` skips its repo-diff checks in this mode. The drive runs against the real `~/.claude`, because a throwaway `CLAUDE_CONFIG_DIR` is not logged in (observed on 2026-10-18) and the installed pointers literally name `~/.claude`.
- **Delivery.** One PR stacked on `spec/taste-question-gate` (PR #1), so `main` never holds agents pointing at definitions a global install cannot find.

## Testing Decisions
- Seams under test (confirmed 2026-10-18):
  1. Feature-map journeys in the foreign fixture through the real `claude` CLI, kit installed into the real `~/.claude`: `proto-taste-foreign` (3 runs) and `proto-layout-foreign`. Catches gate behavior and which glossary the prototyper reads; misses griller and principles wording; costly and nondeterministic.
  2. Installer output: run the installer with `CLAUDE_HOME` set to a temp dir and grep the installed tree. Catches the glossary being installed, rewritten pointers, no kit-term `CONTEXT.md` left in the installed prototyper, griller or principles, and the token and write-confinement rule unchanged; blind to behavior.
  3. Source grep in the repo: `CONTEXT.md` holds only the pointer line, the kit glossary holds the three definitions, project-glossary references still name `CONTEXT.md` / the domain doc. Catches drift and competing definitions; misses installer rewrites.
- What a good test is here: observe the installed files and the CLI's tool log, never the harness's internals.
- Prior art: `proto-taste`, `proto-taste-coached`, `proto-mixed` and `proto-layout` journeys and their tallies in the prototype feature map; the static wording check in `.scratch/taste-question-gate/spec.md`.

## Proof on the real artifact
- **Repair the install.** Run this branch's `install-global.sh` (it backs up replaced files). `~/.claude/agent-kit/glossary.md` exists and holds the three definitions.
- **`proto-taste-foreign`** (new feature-map entry in the prototype map): in the fixture sandbox, `/prototype` with the existing taste question, 3 runs. Pass: `TALLY refused_clean=3 built=0`, nothing written, and each run's tool log shows the prototyper reading `~/.claude/agent-kit/glossary.md` and not the fixture's `CONTEXT.md`.
- **`proto-layout-foreign`** (new entry): in the fixture sandbox, `/prototype` with the existing layout question. Pass: variants built under `.scratch/<slug>/prototypes/`, a decision reported, and the same glossary read observable.
- **Static check of the installed tree**: no kit-term pointer to `CONTEXT.md` in the installed prototyper, griller or principles; `NOT A PROTOTYPE QUESTION` and the write-confinement rule unchanged.
- Update the verify skill's docs and feature-map README with the foreign-project mode (how to launch with a fixture, the user-scope drive, that it uses the real `~/.claude`).
- Refresh the existing prototype journeys' notes that record "one `Grep` of `CONTEXT.md`" so they describe the new glossary read.

## Out of Scope
- `docs/agents/domain.md` not being installed globally. It is a separate defect, taken up in its own session (branch `claude/angry-borg-510818`, commit 7260194, which also edits the installer's rewrite rules; whichever lands second rebases).
- Any other kit pointers that do not resolve in a global install.
- Isolated, logged-in config dirs for sandboxes (`claude setup-token`).
- Changing the definitions themselves, or the prototyper's gate logic.

## Further Notes
- ASSUMPTION: agents' Read/Grep expand `~/.claude/...` the same way they do for the principles pointers already installed.
- ASSUMPTION: with `--setting-sources user,project,local`, the globally installed `/prototype` command and prototyper load in the fixture, and nothing else in the user's scope interferes.
- ASSUMPTION: the `grill-glossary` journey's `?? CONTEXT.md` expectation was already off before this change (`CONTEXT.md` is tracked on the branch). Left as is.
- Risk: the proof edits the real `~/.claude`; the installer's backup is the rollback.
- No ADR: the move is easy to reverse.
