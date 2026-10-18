# 01: Verify harness foreign-project mode

**What to build:** The verify harness can launch a sandbox from a small fixture project that is not this repo (its own unrelated bookstore `CONTEXT.md`, no kit terms), and drive it with user scope loaded so the globally installed kit's agents and commands run there. `doctor` skips the repo-diff checks in this mode. The skill docs and feature-map README describe how to use it and that it runs against the real `~/.claude`.

**Blocked by:** None (can start immediately)

**Status:** done

**Verify with:** `launch` with the fixture, `doctor` passes, then one drive of `/prototype` with the existing taste question: the stream shows the globally installed prototyper loaded from user scope inside the fixture sandbox.

- [x] A fixture project ships with the verify skill, with a bookstore-domain `CONTEXT.md` and no kit terms
- [x] `launch` has an option that copies the fixture instead of this repo, still `git init` + baseline commit
- [x] A drive option adds user scope (`--setting-sources user,project,local`); the default drive is unchanged
- [x] `doctor` skips its repo diffs in fixture mode and still checks auth
- [x] `cleanup` still removes the sandbox's projects entry
- [x] Skill docs and feature-map README describe the mode
