# 01: Add hello file

**What to build:** a file `hello.txt` at the repo root whose only line is `hello from implementer`.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

**Verify with:** `grep -cx 'hello from implementer' hello.txt` prints `1` (`0` means the content is wrong).

- [ ] `hello.txt` exists at the repo root
- [ ] Its only line is exactly `hello from implementer`
