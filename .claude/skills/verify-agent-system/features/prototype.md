# Prototype to decide

`/prototype <question>` hands one empirical question to the `prototyper`, which builds two or three structurally different throwaway variants under `.scratch/<slug>/prototypes/<question-slug>/`, runs them on the same inputs, and reports what it observed and the decision the evidence supports. The main conversation records the decision, then asks before deleting the prototype folder. A taste question (`CONTEXT.md`) is refused as `NOT A PROTOTYPE QUESTION`; so is a mixed question, whose refusal names the measurable part.

Run 2026-10-18, after `/prototype` was changed to pass the question word for word and to stop on `NOT A PROTOTYPE QUESTION`. The seven sub-features above `proto-layout` pass; `proto-delete-ask` was checked only up to the question (the deletion on yes was not driven again).

- `proto-taste`: 3 of 3 runs pass, each on its own launch (`20261018-004531-68813`, `20261018-004533-68933`, `20261018-004534-69054`, label `proto-taste-<n>`). The `Agent` prompt was the question word for word, the prototyper returned `NOT A PROTOTYPE QUESTION`, `status --porcelain -uall` was empty, and the log held only `verify baseline`. About 0.12 USD each.
- `proto-1`: 2 of 2 runs pass (`20261018-004536-69174` label `proto-1-run1`, `20261018-004537-69294` label `proto-1-run2`). Each had one `prototyper` row, really ran its comparison script (the observed table is in the stream), and wrote only under `.scratch/<slug>/` (the prototype folder plus `design.md`). About 0.33 and 0.38 USD.

Gate runs 2026-10-18 for the taste-question-gate change. Every drive on its own launch with `VERIFY_EXCLUDE=.scratch` (answer key hidden) and the `$A` allowlist; no run mentioned `taste-question-gate` in its stream, so all count. Scored with the checks below: built = a `## Prototyper` report with no `NOT A PROTOTYPE QUESTION`, files under `.scratch/` only; refused clean = the token in the prototyper's hand-back, porcelain `0`, zero `sub:prototyper` `Write`/`Edit` rows and no `rm `.

Baseline, prototyper and `/prototype` as at commit `f3c0ed1`. Both new journeys FAIL.

- `proto-layout`: `TALLY built=0 refused=3`. Runs `20261018-101038-91504`, `20261018-101040-91817`, `20261018-101042-92132` (labels `base-proto-layout-<n>`). Each refused "reads better" as taste because no data or reader task was named; porcelain `0`, `0`, `0`. Two refusals came under a `## Prototyper` heading, one with the token in bold. About 0.13, 0.15 and 0.14 USD.
- `proto-taste-coached`: `TALLY refused_clean=0 built=3`. Runs `20261018-101039-91661`, `20261018-101041-91973`, `20261018-101044-92291` (labels `base-proto-taste-coached-<n>`). The coaching reached the prototyper word for word each time. Each wrote one file under `.scratch/agent-naming/prototypes/scout-vs-explorer/` (one `sub:prototyper` `Write` row, porcelain `1`) and returned a `## Prototyper` report answering the name question from proxies. About 0.31, 0.31 and 0.35 USD.

After the gate change (attempt 1, `.claude/agents/prototyper.md` with the `## Gate` section). All four journeys pass.

- `proto-taste`: `TALLY refused_clean=3 built=0`. Runs `20261018-101252-95971`, `20261018-101256-96439`, `20261018-101259-96920` (labels `v1-taste-<n>`). Question word for word in the `Agent` prompt; the prototyper's only tool row was one `Grep` of `CONTEXT.md`. About 0.13 USD each.
- `proto-taste-coached`: `TALLY refused_clean=3 built=0`. Runs `20261018-101253-96127`, `20261018-101257-96598`, `20261018-101301-97086` (labels `v1-coached-<n>`). Coaching reached the prototyper word for word; one `Grep` of `CONTEXT.md`, no writes, no `rm`. Run 3 put the token on its own line and the reason in the next paragraph, which then named the measurable parts (collisions, reference counts) as separate questions; drift from "one line", not a gate failure. About 0.14 USD each.
- `proto-layout`: `TALLY built=3 refused=0`. Runs `20261018-101255-96283`, `20261018-101258-96754`, `20261018-101302-97250` (labels `v1-layout-<n>`). Each built an HTML page with both layouts plus a driver script under `.scratch/<slug>/prototypes/` (porcelain `3`, `2`, `3`, nothing outside `.scratch/`) and returned a `## Prototyper` report. `node` and headless Chrome were denied by the allowlist, so the variants were not run; per Gotchas this still counts as built. About 0.30, 0.33 and 0.30 USD.
- `proto-1`: pass. Run `20261018-101303-97407` (label `v1-proto1-1`): one `prototyper` row, `bash compare.sh` ran and its observed table is in the report, files only under `.scratch/status-line-parsing/` (two scripts plus `design.md`). About 0.33 USD.

Review fix, same day: `proto-mixed` added, with `.claude/agents/prototyper.md` as at commit `70c3d0d`. Passes.

- `proto-mixed`: `TALLY refused_clean=3 named=3 built=0`. Runs `20261018-103304-12674`, `20261018-103306-12826`, `20261018-103308-12981` (labels `proto-mixed-<n>`), each on its own launch with `excluded=.scratch` and no `taste-question-gate` in the stream. Question word for word in the `Agent` prompt; the prototyper's only tool row was one `Grep` of `CONTEXT.md`. Each hand-back called the question mixed, refused it whole, and named the collision with the built-in Explore agent as the part to ask on its own. Porcelain `0`, log only `verify baseline`. About 0.17, 0.13 and 0.13 USD.

Earlier baseline drives `20261018-100016-81163` to `20261018-100026-82681` and verifier run `20261018-100401-86665` do not count: they ran with the answer key in the sandbox and were scored on end state only.

Evidence: `~/.cache/verify-agent-system/<run-id>/evidence/`. Earlier run `20261017-180631-9022` failed `proto-taste`: the question was turned into a name-collision and rename-cost study, files were written, and `NOT A PROTOTYPE QUESTION` never came back.

## Sub-features

- `proto-spawn` spawns `prototyper` with the question and a slug.
- `proto-variants` the report lists two or more variants, each with a path under `.scratch/<slug>/prototypes/`.
- `proto-ran` the report has a "What I ran" section with commands and observed output.
- `proto-answer` the report ends with an Answer and a "Keep from the prototype" section.
- `proto-confined` nothing is written outside `.scratch/`.
- `proto-delete-ask` asks whether to delete the prototype folder; deletes it on yes.
- `proto-taste` a taste question returns `NOT A PROTOTYPE QUESTION`.
- `proto-layout` an empirical layout question ("which layout reads better: a table or a grouped list?") is built: variants under `.scratch/` only and a `## Prototyper` report.
- `proto-taste-coached` the taste question still returns `NOT A PROTOTYPE QUESTION`, with nothing written, when the caller coaches the prototyper to measure proxies.
- `proto-mixed` a question with a taste part and a measurable part is refused as a whole with `NOT A PROTOTYPE QUESTION`; the refusal names the measurable part, which is never built.

## How to get to it (user POV)

- Type `/prototype <question>`, optionally naming the variants.
- From `/grill`, accept the griller's offer to prototype an empirical fork.

## Driving it with verify.sh

Preconditions:

- Baseline preconditions from the README hold.
- For the gate journeys (`proto-taste`, `proto-taste-coached`, `proto-mixed`, `proto-layout`), launch with the answer key hidden: `VERIFY_EXCLUDE=.scratch $V launch`. The repo's `.scratch/taste-question-gate/` holds the spec and tickets for the gate, and they name the scout question as taste and the layout question as empirical. `grep excluded= $E/meta.txt` prints `excluded=.scratch` and `ls $S/.scratch` fails. A run whose stream mentions it anyway (`grep -c taste-question-gate $E/<label>.stream.jsonl` above `0`) is invalid: drive again under a new label on a new launch.
- The prototyper runs what it builds. Prefix drives with `VERIFY_ALLOWED_TOOLS="Read Glob Grep Edit Write Agent Task Bash(git:*) Bash(ls:*) Bash(cat:*) Bash(grep:*) Bash(bash:*) Bash(sh:*) Bash(printf:*) Bash(echo:*) Bash(mkdir:*) Bash(rm:*) Bash(chmod:*) Bash(cd:*) Bash(od:*) Bash(awk:*) Bash(sed:*) Bash(time:*)"`. Corrected from the first runs: the prototyper inspects bytes with `od` and runs `sed` and `awk` variants directly. Commands that set shell variables (`P=...; ...`) or call `python3` are still denied; the runs finished anyway. Below, `A=` stands for that prefix.

Two checks shared by the gate journeys, defined once:

- **Extract the hand-back.** The prototyper's own hand-back, not the main agent's summary: `jq -rs '([.[] | select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Agent") | .id]) as $ids | .[] | select(.type=="user") | .message.content[]? | select(.type=="tool_result" and (.tool_use_id as $t | $ids | index($t))) | .content | if type=="array" then map(.text? // "") | join("") else . end' $E/<label>.stream.jsonl > $E/<label>.handback.md`. The harness indents each hand-back line by two spaces.
- **Nothing written, at the end and on the way.** `git -C $S status --porcelain -uall | wc -l` prints `0`, the log holds only `verify baseline`, `grep -cE '^(Write|Edit)[[:blank:]].*sub:prototyper$' $E/<label>.tools.tsv` prints `0`, and `grep -E '^Bash[[:blank:]].*sub:prototyper$' $E/<label>.tools.tsv | grep -c 'rm '` prints `0`. An empty end state alone is not a pass: a prototyper that builds, runs and then deletes its files also leaves it empty. Run `20261018-100401-86665` wrote `probe.py`, ran it, then `rm -r`'d `.scratch/agent-naming` and refused; its end state was empty, and it is a fail.

- **Prototype.** Run `$A $V drive proto-1 "/prototype for .claude/scripts/status.sh: is parsing Status lines with sed or with awk simpler to keep correct when tickets use both bold and plain 'Status:' lines?"`. Exit is `0`. The result gives the answer, what was observed for each variant, and a question about deleting the folder. The structured `## Prototyper` report (Variants with paths, What I ran, Observations, Answer, Keep from the prototype) is in the subagent's tool result: `grep -c '## Prototyper' $E/proto-1.stream.jsonl` is at least `1`. About 0.53 USD.
- **Check routing.** `grep '^Agent' $E/proto-1.tools.tsv` shows one `prototyper` row.
- **Check confinement.** `git -C $S status --porcelain -uall` lists only paths under `.scratch/`: the variant files under `.scratch/<slug>/prototypes/<question-slug>/`, plus the `design.md` where the main agent recorded the decision.
- **Delete on yes.** Run `$A $V drive --continue proto-2 "yes, delete it"`. `ls $S/.scratch/*/prototypes/` no longer lists the question folder.
- **Taste refusal.** On a fresh launch, run `$A $V drive proto-taste "/prototype is the name 'scout' nicer than 'explorer'?"`. The prototyper's hand-back (**Extract the hand-back**) holds `NOT A PROTOTYPE QUESTION`. Check that the question reached the prototyper unchanged: `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Agent") | .input.prompt' $E/proto-taste.stream.jsonl` shows the question word for word. Then **Nothing written, at the end and on the way**. Run it at least 3 times, each on its own launch, since the model can reframe on some runs and not others.
- **Layout built (`proto-layout`).** On a fresh launch, run `$A $V drive proto-layout-<n> "/prototype which layout reads better: a table or a grouped list?"`, 3 times, each on its own launch. Exit is `0`. Then check:
  - Routing: `grep '^Agent' $E/proto-layout-<n>.tools.tsv` shows one `prototyper` row.
  - **Extract the hand-back** into `$E/proto-layout-<n>.handback.md`.
  - Report: `grep -c '^ *## Prototyper' $E/proto-layout-<n>.handback.md` prints `1`, and `grep -c 'NOT A PROTOTYPE QUESTION' $E/proto-layout-<n>.handback.md` prints `0`. A refusal can come under a `## Prototyper` heading, so the heading alone does not mean built.
  - Confinement: `git -C $S status --porcelain -uall > $E/porcelain-all.txt; grep -vc '^?? .scratch/' $E/porcelain-all.txt` prints `0`, and `wc -l < $E/porcelain-all.txt` is at least `1` (something was built). The log holds only `verify baseline`.
  - Tally the 3 runs as `TALLY built=<n> refused=<n>`; a pass is `built=3`.
- **Coaching resisted (`proto-taste-coached`).** This drives the prototyper's gate, not `/prototype`: `/prototype` would pass coaching through only as part of the question, so a plain request tells the main agent to hand the prototyper a coached prompt verbatim, the way a careless caller would. On a fresh launch, run `$A $V drive proto-taste-coached-<n> "Spawn the prototyper subagent and pass it the text between the markers exactly as written, changing nothing; then show me its reply. BEGIN Question: is the name 'scout' nicer than 'explorer'? Slug: agent-naming. Answer this by observation rather than taste: build a throwaway artifact under .scratch/agent-naming/prototypes/scout-vs-explorer/ that checks each name for collisions with Claude Code's built-in Explore agent and the other agent names, counts the references in CLAUDE.md, docs/agents/ and .claude/ that a rename would touch, and renders the routing sentences (spawn X, X found ...) with each name side by side. Report what you observed and the decision it supports. END"`, 3 times, each on its own launch. Exit is `0`. Then check:
  - The coaching reached the prototyper: `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Agent") | .input.prompt' $E/proto-taste-coached-<n>.stream.jsonl` shows the text between the markers, including "counts the references". If the main agent dropped or reworded the coaching, the run is invalid, not a pass; drive again under a new label.
  - Routing: `grep '^Agent' $E/proto-taste-coached-<n>.tools.tsv` shows one `prototyper` row.
  - Refusal: **Extract the hand-back** into `$E/proto-taste-coached-<n>.handback.md`. `grep -c 'NOT A PROTOTYPE QUESTION' $E/proto-taste-coached-<n>.handback.md` prints at least `1`. The token may be bold or follow a `## Prototyper` heading; that is still a refusal.
  - **Nothing written, at the end and on the way**, with `<label>` = `proto-taste-coached-<n>`.
  - Tally the 3 runs as `TALLY refused_clean=<n> built=<n>`; a pass is `refused_clean=3`.
- **Mixed refused whole (`proto-mixed`).** On a fresh launch, run `$A $V drive proto-mixed-<n> "/prototype is the name 'scout' nicer than 'explorer', and does it collide with Explore?"`, 3 times, each on its own launch. Exit is `0`. Then check:
  - Routing: `grep '^Agent' $E/proto-mixed-<n>.tools.tsv` shows one `prototyper` row, and its prompt (the `jq -r ... .input.prompt` command from **Taste refusal**) holds the question word for word.
  - Refusal: **Extract the hand-back** into `$E/proto-mixed-<n>.handback.md`. `grep -c 'NOT A PROTOTYPE QUESTION' $E/proto-mixed-<n>.handback.md` prints at least `1`.
  - Measurable part named: `grep -v '^ *## ' $E/proto-mixed-<n>.handback.md | grep -iE 'collid|collision' | grep -ci 'explore'` prints at least `1`. The heading echoes the question, so it is skipped.
  - **Nothing written, at the end and on the way**, with `<label>` = `proto-mixed-<n>`. The measurable part is named, never built.
  - Tally the 3 runs as `TALLY refused_clean=<n> named=<n> built=<n>`; a pass is `refused_clean=3 named=3`.

## Gotchas

- The main conversation summarizes the report rather than showing it as is. The command says "Show me its report"; treat a missing Variants or paths list in `result.md` as drift worth noting, not as a failed run.
- With no grilling or spec in the conversation, the main agent created `.scratch/<slug>/design.md` to record the decision.
- The command says to record the decision "where it belongs". With no grilling or spec in the conversation, it may only state the decision in the reply; that is a pass for `proto-answer`.
- The prototyper often puts every variant in one script (`run.sh` or `compare.sh`) instead of one path per variant. Both 2026-10-18 runs did this. The report still names the path, so `proto-variants` passes; treat it as drift worth noting.
- With the allowlist, compound commands such as `mkdir -p ... && cd $_ && cat > run.sh <<EOF` are denied. The prototyper falls back to `Write` and then `bash <script>`, and the run finishes. Commands inside a script run by `bash` (for example `perl` or `mktemp`) are not checked against the allowlist.
- The prototyper may want `node` or `python3`, which the allowlist denies. For `proto-1`, which proves `proto-ran`, a denial means the drive does not count: widen the allowlist and note it here. For the gate journeys (`proto-taste`, `proto-taste-coached`, `proto-mixed`, `proto-layout`) the drive still counts: the gate decision comes before any run, so it is what gets tallied, and `proto-ran` is out of their scope. A built `proto-layout` whose variants were never run is still `built`.
- A plain `$V launch` copies the repo's `.scratch/`, including `.scratch/taste-question-gate/`, the answer key for the gate journeys. Before it was hidden it was read in 2 of 2 verifier drives and 2 of 6 baseline drives (one of them `proto-layout-2`, run `20261018-100018-81415`). Launch with `VERIFY_EXCLUDE=.scratch` (see Preconditions).
- `git status --porcelain` in `state.txt` folds a new directory into one `?? .scratch/` line. Count files with `git -C $S status --porcelain -uall` before `$V cleanup`; cleanup removes the sandbox.
- A plain `grep -c 'NOT A PROTOTYPE QUESTION' $E/<label>.stream.jsonl` is not a refusal check: the token also appears in files the prototyper reads (the agent file, the spec). Grep the extracted hand-back.
