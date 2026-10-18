---
description: Retrospective - fix the agents' environment at the strongest layer of the correction ladder (retro)
argument-hint: [optional session transcript path, git range, or focus]
---
Spawn the `retro` subagent. In its brief, give it the session transcript path (default: the newest `.jsonl` for this repo under `~/.claude/projects/`), plus a 5-10 line summary of this session's corrections, failures and retries if we are in the session being reviewed.

Show me its findings, most severe first. Ask which to apply. Apply only the ones I approve, one commit each, highest layer first. For every new check, run it against the past mistake it targets and show that it fails there. Add each applied rule and what enforces it to the rule table in `docs/agents/principles.md` under "Improving the system".

Input: $ARGUMENTS
