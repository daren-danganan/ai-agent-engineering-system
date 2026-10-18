# Hand off the work

`/handoff [destination]` writes a handoff document a fresh agent or person can continue from, with the sections Goal, State, Decisions, Open questions, Next step and Traps. It points to specs, tickets, commits and files instead of pasting them, and gives the user the path. By default the file goes to the temp directory; asked to keep it in the repo, it goes to `.scratch/<slug>/handoff.md`.

Proven 2026-10-17, run `20261017-180605-7401` (handoff-0, handoff-1): `handoff-sections`, `handoff-pointers`, `handoff-labels`, `handoff-readonly` and the in-repo `handoff-path` pass. The default temp-directory path passed only in an earlier run (`20261017-174547-74176`, handoff-tmp) that loaded the user-scope copy of the command; that copy's text is identical. Evidence: `<run>/evidence/handoff-*.result.md` and `handoff-*.file.md`.

## Sub-features

- `handoff-sections` the file has Goal, State, Decisions, Open questions, Next step and Traps.
- `handoff-pointers` State and Decisions cite paths and commit hashes, not pasted content.
- `handoff-labels` State claims are labeled measured, read or inferred.
- `handoff-path` the reply gives the file path; by default under `${TMPDIR:-/tmp}`, or `.scratch/<slug>/handoff.md` when asked.
- `handoff-readonly` touches no file but the handoff itself.

## How to get to it (user POV)

- Type `/handoff`, or `/handoff <who or where it is going and what they will do next>`.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- A conversation worth handing off. Run `$V seed-tickets`, then `$V drive handoff-0 "/status"`, so the conversation has state to describe. Use the `/status` allowlist from `status.md` plus `Edit Write Bash(date:*) Bash(grep:*)` for every drive here; `/handoff` needs `Write` and stamps the file name with `date`.

- **Hand off into the repo.** Run `$V drive --continue handoff-1 "/handoff to another agent who will run /implement; keep it in the repo"`. Exit is `0`. The result names `.scratch/verify-hello/handoff.md` (or another `.scratch/<slug>/handoff.md`).
- **Check the file.** `cat $S/.scratch/*/handoff.md` has headings or bold labels for Goal, State, Decisions, Open questions, Next step and Traps, and the Next step names `/implement .scratch/verify-hello`.
- **Check confinement.** The only new path in `$E/handoff-1.state.txt` porcelain is the handoff file.
- **Default location.** On a fresh conversation, run `$V drive handoff-tmp "/handoff"`. The result gives a path under the temp directory. Copy it into `$E/` before cleanup.

## Gotchas

- The default location worked: `Write` to `/tmp/handoff-<slug>-<timestamp>.md` was allowed. `printenv TMPDIR` was denied, so the agent fell back to `/tmp`. Copy the file into `$E/` and delete it from `/tmp` before cleanup; cleanup does not touch `/tmp`.
- A fresh `/handoff` with no prior turn still writes a file and says there was nothing to carry over. If an older `handoff.md` sits in `.scratch/`, it reads that one too.
- A handoff of an empty conversation is thin by design; drive it after at least one real turn.
