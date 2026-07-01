# USL Session Handoffs

One file per AI session, so the next platform can pick up without rebuilding
context. Handoffs are part of the system of record (the repo context layer).

## File naming

```text
context/handoffs/YYYY-MM-DD-platform-handoff.md
```

Examples: `2026-06-28-claude-code-handoff.md`, `2026-06-28-chatgpt-handoff.md`.
Add a suffix if there are multiple in one day (`-2`, `-pm`, etc.).

## Handoff format

Copy this template into the new handoff file and fill it in:

```markdown
# Handoff — YYYY-MM-DD HH:MM (local)

- **Date/time:**
- **Platform used:**            (Claude Code / Claude Desktop / ChatGPT / Codex / ...)
- **Repo / path:**              (repo + branch + relevant paths)
- **Task:**                     (what this session worked on)
- **Files changed:**            (added / modified / removed)
- **Decisions made:**           (also record durable ones in USL_MEMORY_LEDGER.md)
- **Validation:**               (tests/scripts run + results)
- **Risks:**                    (anything to watch; approval gates touched)
- **Next action:**              (the single next step)
- **Copy/paste prompt for next platform:**

      (a reusable prompt block the next platform can run verbatim)
```

## Rules

- No secrets and no controlled data in handoffs.
- Record durable decisions in `USL_MEMORY_LEDGER.md`, new artifacts in
  `USL_FILE_INDEX.md`, and task changes in `USL_ACTIVE_TASKS.md`.
- After writing a handoff, run `scripts/build_context_snapshot.py` and
  `scripts/validate_context_bus.py`, then commit.
