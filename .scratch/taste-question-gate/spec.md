# Taste question gate for the prototyper

Status: ready-for-agent

## Problem Statement

The prototyper is supposed to refuse taste questions and build for empirical forks, but nothing defines the difference. Three places word the line differently (the principles, the griller's sorting rules, the prototyper's own gate), so the model treats "is the name nicer?" and "which layout reads better?" as the same kind of question. On 2026-10-17 `/prototype is the name 'scout' nicer than 'explorer'?` built a study instead of refusing, because the caller reworded the question into something measurable and the prototyper accepted it. A stricter gate tried during debugging on 2026-10-18 then refused a genuine layout question. The 2026-10-18 fix to `/prototype` stops the command from rewording, but the prototyper itself still cannot hold the line.

## Solution

Define **taste question**, **empirical fork** and **mixed question** once, in the glossary (`CONTEXT.md`), using one test: would seeing it built change anyone's answer? The prototyper's gate applies that test to the question as stated, ignoring any coaching from the caller about what to measure, and refuses mixed questions as a whole while naming the measurable part. The griller and the principles sort questions with the same terms instead of their own wording.

## User Stories

1. As a user, I want `/prototype` to refuse a taste question like "is the name 'scout' nicer than 'explorer'?", so that no time is spent pretending an experiment can settle preference.
2. As a user, I want `/prototype` to build for "which layout reads better: a table or a grouped list?", so that a question settled by looking at variants side by side still gets a prototype.
3. As a user, I want the refusal to name any measurable part of a mixed question in one line, so that I can ask that part separately if I want it.
4. As a user, I want a refusal to leave no files behind, so that a refused question costs nothing to clean up.
5. As the griller, I want to sort taste questions to the human and empirical forks to `/prototype` using the same definition the prototyper applies, so that what I send is not refused.
6. As any caller of the prototyper, I want the gate to judge the question itself regardless of how I frame or coach it, so that the gate does not depend on every caller being careful.
7. As a maintainer, I want the definition in one place, so that a future change to it cannot drift between files.
8. As the verifier, I want feature-map journeys for both directions (refuse taste, build empirical), so that over-refusal and under-refusal are both caught.

## Implementation Decisions

- The glossary (`CONTEXT.md`, written during grilling on 2026-10-18) is the single definition of taste question, empirical fork and mixed question. Other files use these terms and do not restate competing definitions.
- The test: a question is a taste question when seeing it built would not change anyone's answer; it is an empirical fork when looking at or running the built thing would change or settle the answer. The words in the question ("nicer", "better") do not decide it.
- Prototyper gate: applied to the question as stated, before any building. Caller hints about what to measure or build are ignored for the gate decision. The gate includes one short example of each kind: the name question (taste) and the layout question (empirical).
- Mixed questions are refused as a whole. The one-line reason may name the measurable part; the prototyper never builds it on its own initiative.
- The griller's question-sorting rules and the principles' "decisions belong to the human / empirical fork" lines are reworded to use the glossary terms.
- Unchanged: the literal `NOT A PROTOTYPE QUESTION` token followed by a one-line reason; the prototyper writes only under `.scratch/<slug>/prototypes/`; the prototyper's workflow and report format; `/prototype`'s word-for-word pass-through and recording steps.

## Testing Decisions

- Seams under test:
  1. Feature-map journeys driven through the real `claude` CLI by the verify-agent-system harness: `proto-taste`, a new `proto-layout`, and `proto-1`. Catches end-to-end gate behavior, coaching resistance, and no writes on refusal. Misses stability beyond the sampled runs.
  2. Static wording check with grep: the three files use the glossary terms, none keeps a competing taste definition, the token and the write-confinement rule are unchanged. Cheap and certain about text, blind to behavior.
- What a good test is here: observed behavior of a fresh drive (tool rows, the prototyper's own hand-back, `git status --porcelain -uall`), never the main agent's summary of it.
- Prior art: `proto-taste` and `proto-1` in the prototype feature file; the debugger's repeated-trial tally (N fresh sandboxes, `TALLY refused_clean=<n> built=<n>`) from 2026-10-18.

## Proof on the real artifact

- Taste refused: drive `/prototype is the name 'scout' nicer than 'explorer'?` on 3 fresh launches. Each run: the prototyper's hand-back starts with `NOT A PROTOTYPE QUESTION`, `git status --porcelain -uall` prints nothing, no `.scratch/` exists.
- Coaching resisted: drive the prototyper with the taste question plus caller coaching to measure proxies (the framing seen in the 2026-10-17 failure). It still refuses. Add this as a `proto-taste-coached` step in the prototype feature file.
- Layout built: drive `/prototype which layout reads better: a table or a grouped list?` on 3 fresh launches. Each run builds variants under `.scratch/` only and returns a `## Prototyper` report. Add this as a new `proto-layout` journey in the prototype feature file.
- Empirical still built: `proto-1` passes as recorded today.
- Static: grep shows the three agent/doc files use "taste question" and "empirical fork", and the token and write rule are present verbatim.

## Out of Scope

- The prototyper's workflow, variants, report format and cleanup.
- `/prototype`'s recording and deletion steps (fixed on 2026-10-18).
- Syncing the global install in `~/.claude` (`install-global.sh`).
- Renaming any agent.

## Further Notes

- ASSUMPTION: one short example of each kind in the prototyper's gate is enough; examples were what tipped the model during debugging.
- ASSUMPTION: syncing `~/.claude` is a separate piece of work; `/grill` and `/to-spec` in this session ran from that stale global copy.
- Risk: model behavior varies between runs; 3 of 3 runs is a sample, not a guarantee.
- No ADR: the decision is easy to reverse and not surprising.
