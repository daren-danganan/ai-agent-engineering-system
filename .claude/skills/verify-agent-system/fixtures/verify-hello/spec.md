# Verify hello (verification fixture)

Status: ready-for-agent

## Problem Statement
The `/implement` loop needs a spec with tickets to run against. This is a fixture, not a real feature.

## Solution
Add a one-line text file at the repo root.

## User Stories
1. As the verification harness, I want a trivial ticket to build, so that I can prove the implement loop branches, builds, verifies, commits and asks before merging.

## Implementation Decisions
- One static text file. No code, no modules.

## Testing Decisions
- Seams under test: the file's content, read back with `grep`.
- Prior art: none.

## Proof on the real artifact
- `grep -cx 'hello from implementer' hello.txt` prints `1` at the repo root.

## Out of Scope
Everything else, including any edit under `.claude/` or `docs/`.

## Further Notes
None.
