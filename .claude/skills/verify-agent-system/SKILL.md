---
name: verify-agent-system
description: Drive this repo's Claude Code agents (griller, scout, architect, prototyper, implementer, verifier, debugger, reviewer, retro) and slash commands (/grill, /to-spec, /to-tickets, /design, /implement, /review, /status, /diagnose, /prototype, /verify, /retro, /handoff, /improve-architecture) through the real `claude` CLI in a disposable copy of the repo, and capture proof. Use after changing anything under .claude/agents, .claude/commands or CLAUDE.md, or when asked to verify, prove, or regression-check that an agent or command still behaves as written.
---

# Verify the agent engineering system

The "app" in this repo is a set of prompt files: the agents in `.claude/agents/` and the slash commands in `.claude/commands/`, steered by `CLAUDE.md` and `docs/agents/`. A user touches it by typing a slash command or a request into Claude Code. There is no server and nothing to build.

Verification means running the real `claude` CLI against those files and reading what it did. Everything goes through one helper, `verify.sh`, in this folder. Run it from the repo root:

```bash
V=.claude/skills/verify-agent-system/verify.sh
```

Read `features/README.md` before driving, then use the matching feature file as the recipe.

## Launch

```bash
$V launch
```

This copies the current working tree (tracked and untracked files, including uncommitted edits, minus ignored files and minus this skill) into a fresh sandbox, makes it its own git repo on branch `main` with one `verify baseline` commit, and prints the run id, sandbox path and evidence path. It is ready when the last line is `ready`.

- Every launch gets its own directory under `~/.cache/verify-agent-system/<run-id>/`, so runs can sit side by side.
- The sandbox never contains this skill, so inside it `/verify` and the map step of `/implement` see a project with no verification skill.
- Later commands act on the most recent launch. To target another run, prefix the command with `VERIFY_RUN=<run-id>`.
- Never drive the real repo. The agents write files, create branches and commit; that belongs in the sandbox.
- The sandbox is a snapshot. After editing an agent or command in the repo, clean up and launch again.
- `VERIFY_EXCLUDE="<folder> ..."` keeps those folders out of the sandbox and records them as `excluded=` in `meta`. Use it when a file in the repo would hand a drive its expected answer, such as a spec that names the verdict a journey checks.

### Foreign-project mode

```bash
$V launch --fixture foreign-bookstore
```

Proves the kit as `install-global.sh` installs it, in a project that is not this repo. The sandbox holds only `fixtures/<name>/` (git-initialized the same way), so no agent, command or doc of this repo is in it. `meta` records `mode=foreign` and `fixture=<name>`.

- Drives of a foreign run default to `--setting-sources user,project,local`, so the agents and commands in `~/.claude` load. Each drive records the sources it used in `<label>.setting-sources.txt`.
- The kit under test is the real `~/.claude`, not the working tree. Run `./install-global.sh` from the branch being proven first; it backs up whatever it replaces. A throwaway `CLAUDE_CONFIG_DIR` is not an option: it is not logged in (measured 2026-10-18), and installed pointers name `~/.claude` literally.
- User scope also brings your other global agents, commands, MCP servers and `~/.claude/CLAUDE.md` into the drive. Check `tools.tsv` routing as usual.
- `fixtures/foreign-bookstore/` is a small bookstore project whose `CONTEXT.md` is its own glossary (Title, Copy, Special order, Hold shelf) with no kit terms, so an agent that reads `CONTEXT.md` for kit terms finds the wrong glossary and the read shows in `tools.tsv`.

## Doctor

```bash
$V doctor
```

Read-only. It checks that the sandbox came from a launch, is its own git repo and is not the real repo, that `claude` is on `PATH` and logged in, and that the sandbox's agents, commands, scripts, `docs/agents/` and `CLAUDE.md` still match the repo working tree. In foreign-project mode it skips those repo diffs and instead checks that the sandbox holds no `.claude/agents` and that the kit is installed in `~/.claude` (the prototyper, `/prototype`, `agent-kit/principles.md`). It ends with `healthy` (exit 0) or `unhealthy` (exit 1). Run it first whenever a drive looks wrong; a `FAIL` on the "match the repo working tree" lines means the sandbox is stale. The login check reads `claude auth status`, which can pass at launch and expire before a drive: a `result.md` of `Failed to authenticate` means the drive never reached the model. `drive` prints a warning when it sees that; log in with `claude auth login` in a terminal and drive again under a new label.

## Drive

```bash
$V drive <label> "<what the user would type>"
$V drive --continue <label> "<the user's next reply>"
```

Each drive is one user turn sent to `claude -p` inside the sandbox. Use the literal text a user would type, such as `/design <question>`. `--continue` sends a follow-up turn in the same conversation, which is how you answer a question the agent asked. Labels must be unique within a run.

- The drive runs with `--setting-sources project,local` (`user,project,local` in foreign-project mode), so the sandbox's own commands run. Without it, a same-named command in `~/.claude/commands/` (from `install-global.sh`) replaces the sandbox's copy; this was measured on 2026-10-17. Agents resolve to the project copy either way. Never set `VERIFY_SETTING_SOURCES` to include `user` on a repo launch; use `launch --fixture` to test the global install.
- The drive runs with `--permission-mode acceptEdits` and a tool allowlist: file tools, `Agent`, web tools, and `Bash` limited to `git`, `ls`, `cat`, `date`, `test` and `grep`. A command outside the list is denied, and the agent reports that instead of running it. A compound command (`a; b`, `a && b`) needs every part allowed, and a command with `$(...)`, `$VAR` or `<(...)` is denied regardless. The drive's `result` event lists every denial under `permission_denials`: `jq -c 'select(.type=="result") | .permission_denials' $E/<label>.stream.jsonl`. Widen it for one drive with `VERIFY_ALLOWED_TOOLS="..."` only when a feature's own check needs it; `/status`, `/diagnose` and `/prototype` do, and their feature files give the exact list.
- Claude Code refuses writes under `.claude/` in `-p` mode, even with `Write` allowed (measured 2026-10-17 on `/retro`). A journey whose product change lands under `.claude/` (a retro fix, `/verify map create`, a ticket that edits an agent) cannot finish in a drive; record it as blocked.
- The account's claude.ai connectors still load with `--setting-sources project,local`. A trailing line about unauthorized Gmail or Drive connectors in `result.md` is noise; ignore it.
- Each drive is capped at 3 USD (`VERIFY_BUDGET_USD` to change). Multi-agent commands (`/design`, `/implement`) can exceed it; raise the cap per drive.
- Extra arguments after the prompt are passed to `claude` unchanged.
- `/implement` needs a spec with tickets in a clean tree. `$V seed-tickets` copies `fixtures/verify-hello/` (a spec and one ticket that adds `hello.txt`) into the sandbox's `.scratch/` and commits it.
- `/diagnose` needs a real bug. `$V seed-bug` copies `fixtures/sum-bug/` (`tools/sum.sh`, which drops the last line of a file without a trailing newline, and `tools/numbers.txt`) into the sandbox and commits it.
- `$V state <label>` records the sandbox's git state on its own, for a before/after pair.

## Evidence

Every drive writes these files to `~/.cache/verify-agent-system/<run-id>/evidence/`:

| File | What it proves |
|---|---|
| `<label>.prompt.txt` | The exact user input. |
| `<label>.result.md` | The final answer as the user would read it. |
| `<label>.tools.tsv` | Every tool call in the turn, one per line: tool, target, and who made it (`main`, or `sub:<subagent>`). An `Agent` row names the subagent that ran. |
| `<label>.state.txt` | Sandbox git state after the turn: branch, branches, `status --porcelain`, log, files changed since baseline. |
| `<label>.exit.txt`, `<label>.stderr.txt` | Exit code and stderr of the `claude` process. |
| `<label>.setting-sources.txt` | The `--setting-sources` the drive used. |
| `<label>.stream.jsonl` | The full event stream, including subagent output, cost and turn count. |
| `meta.txt` | Mode (`repo` or `foreign`, with `fixture=`), repo path, repo HEAD, the folders kept out with `VERIFY_EXCLUDE` (`excluded=`, trailing slashes stripped), number of uncommitted files copied in, and the `claude` version. |

Proof standards:

- Drive the user's path: the slash command or the plain request. Do not call a subagent directly to prove a command that is supposed to route to it.
- Show the action and the result: the prompt file together with the result file, not the result alone.
- Check side effects in `state.txt` next to the answer. A command documented as read-only is proven only by an empty `status --porcelain` and an unchanged log; a build is proven by the branch, the commit and the file contents, not by the agent saying it is done.
- Check routing in `tools.tsv`. An answer in the right format with no `Agent` row for the expected subagent means the main agent improvised. To check what the main agent itself did, filter on the third column: `awk -F'\t' '$3=="main"' $E/<label>.tools.tsv`.
- Inside a drive, the Bash tool reports `grep` exit 1 (no match) as success with no output. A `Verify with` check that relies on `grep -q` exit codes reads as passing when it fails. Fixtures use checks that print their result (`grep -c` printing `1` or `0`).
- Model output varies between runs. Assert on the structure the agent files promise (headings, status values, file paths, commit message shape), never on exact wording.
- Report an entry point you could not drive, with the command you tried. Do not count it as verified through a different entry point.

## Cleanup

```bash
$V cleanup
```

Removes the sandbox of the current run and the session transcripts Claude Code stored for that sandbox path. It keeps `evidence/` and `meta`. It refuses to delete a directory that has no `meta` file from a launch. Run it after every run, including failed ones. There are no long-lived processes to stop: each drive is a `claude` process that exits on its own.

To remove old evidence, delete `~/.cache/verify-agent-system/<run-id>/` by hand once the proof is no longer needed.

## Helpers

- `verify.sh` is the only helper. Subcommands: `launch [--fixture <name>]`, `doctor`, `drive [--continue] <label> <prompt> [claude args]`, `state <label>`, `seed-tickets`, `seed-bug`, `cleanup`.
- `fixtures/verify-hello/` is the spec and ticket that `seed-tickets` installs.
- `fixtures/foreign-bookstore/` is the foreign project that `launch --fixture foreign-bookstore` copies.
- `fixtures/sum-bug/` is the buggy script that `seed-bug` installs: `bash tools/sum.sh tools/numbers.txt` prints `6`, expected `10`.
- Requirements: `claude` (logged in), `git`, `jq`.
