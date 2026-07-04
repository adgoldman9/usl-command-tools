# CLAUDE.md

Claude Code loads this file automatically. It imports the shared USL agent
instructions, then adds Claude-specific notes.

@AGENTS.md

## Claude-Specific Notes

- **Context first.** At the start of meaningful work, read
  `context/USL_CONTEXT_SNAPSHOT.md`, `context/USL_ACTIVE_TASKS.md`, and the latest
  file in `context/handoffs/`. The repo context files are the memory — not
  Claude's native memory.
- **Do not trust native Claude memory as the only record.** Claude memory does not
  cross to ChatGPT or Codex. Anything that must persist across vendors or sessions
  goes into the repo context files and a handoff.
- **Use plan mode for risky or far-reaching changes.** Propose a plan before
  editing when a change touches many files, the CRM, security posture, or anything
  release-related.
- **Prefer patch + report.** Make the change, then report what changed, how to
  test, and what remains. Keep changes scoped and reviewable.
- **Write handoff summaries.** After meaningful work, write a handoff in
  `context/handoffs/` and update the ledger, file index, and active tasks. Run
  `python scripts/build_context_snapshot.py` and
  `python scripts/validate_context_bus.py` before committing.
- **Approval gates.** Never mark anything release-ready, publish, share
  externally, or invite suppliers without Andrew's explicit approval.
- **No secrets, no controlled data.** See `AGENTS.md` — these rules are absolute.

## Where Things Live

- Architecture: `docs/ai-context-bus.md`
- Daily/weekly SOP: `docs/ai-context-bus-sop.md`
- Platform matrix: `docs/ai-platform-sync-matrix.md`
- Claude-internal sync (appendix): `docs/claude-app-sync.md`
- Context files: `context/`
- Context tooling: `scripts/`, `tools/`

## USL AI OS protocol

Use docs/usl-ai-os-access-protocol.md as the standing access, CRM, communication, and safety protocol for this repo.

