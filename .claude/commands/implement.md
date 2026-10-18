---
description: Build a spec's tickets one at a time - implementer builds, verifier proves, I commit, reviewers close out
argument-hint: [.scratch/<slug> or one ticket path] [--parallel]
---
Build the tickets below. You run the loop; `implementer` builds each ticket, `verifier` proves it independently. You never write product code yourself and never edit the spec, except its `Status:` line.

Input: $ARGUMENTS

## Before the first ticket

1. Read the spec and every ticket in `.scratch/<slug>/issues/`. Build the task graph from each ticket's `Blocked by`. Stop if there are no tickets (suggest `/to-tickets`).
2. Stop if this is not a git repo or `git status --porcelain` is not empty. Ask me to commit or stash; do not do it for me.
3. Check the spec's `Status:`. `shipped` → stop and tell me it already shipped. `building` → this is a resumed build; switch to `build/<slug>` and skip step 4.
4. Create branch `build/<slug>` from the current branch and note the base branch for the end. Set the spec's `Status:` to `building` and commit it alone as `<slug>: start build`.

## The loop

The **frontier** is every ticket whose status is `ready-for-agent` and whose blockers are all `done`. Take the lowest-numbered frontier ticket.

1. **Build.** Spawn a fresh `implementer` with pointers only: the ticket path, the spec path, `design.md` if present, the done tickets with their commit hashes.
2. **Act on its Status.**
   - `BLOCKED` → ask me its question with its options, recommended first. Re-spawn a fresh implementer with my answer in the brief.
   - `FAILED` → re-spawn once, fresh, with the failure output. If it fails again, roll back only this ticket's files (`git restore` the edited ones, delete the added ones), stop, and tell me what failed.
   - `DONE` with a `needs user` check → give me the exact steps and wait for my result. A failure I report counts as `FAILED`.
   - `DONE` → step 3.
3. **Prove.** Spawn `verifier` in **verify** mode on the ticket path. It did not write the code, so it can grade it. `FAIL` or `INCONCLUSIVE` → treat as `FAILED` above, with the verifier's evidence in the brief.
4. **Commit** only the files in the implementer's report, staged so any regression test lands in the same commit as its fix, with message `<slug> #<NN>: <ticket title>`. Set the ticket's `**Status:**` to `done` and append under `## Comments`: the commit hash, the verifier's verdict line, and the implementer's assumptions.
5. **Report** one line to me: ticket, commit, verdict. Recompute the frontier and continue.

With `--parallel`, and only when two or more frontier tickets touch disjoint areas: spawn their implementers in one message with `isolation: "worktree"`, then verify and merge each into `build/<slug>` one at a time. Shared files serialize. Without the flag, build one ticket at a time.

## After the last ticket

1. **Review.** Run the `/review` procedure against the base branch (`.claude/commands/review.md`), with the spec as the spec source.
2. **Fix** every Act-on finding with one fresh `implementer` (brief: the findings and the files), then verify and commit as above with message `<slug>: review fixes`.
3. **Map.** If the project has a verification skill (`.claude/skills/verify-*/`), spawn `verifier` in **map** mode with `maintain` and the spec path, so the entries its *Proof on the real artifact* section names are added or refreshed. Commit what it wrote as `<slug>: feature map`. If there is no verification skill, ask me whether to run `create` now (a bigger job); if I say no, skip and say so in the summary.
4. **Summarize:** tickets built with commit hashes, verifier verdicts, checks I ran, review findings and what was done with each, feature-map files written or "skipped", and every assumption from every ticket in one list.
5. **Ask** whether to merge `build/<slug>` into the base branch with `--no-ff`. Do not merge without my answer.
   - Yes → set the spec's `Status:` to `shipped`, commit it as `<slug>: shipped`, then merge.
   - No → leave the spec at `building`. `/status` will show it as built but not shipped.
