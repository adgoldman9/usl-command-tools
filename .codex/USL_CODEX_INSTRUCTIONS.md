# USL Codex Instructions

Codex-specific operating instructions for the USL AI Context Bus. Codex is the
repo patch / testing workspace. Read `AGENTS.md` first — it is the shared contract;
this file adds Codex specifics.

See `docs/ai-context-bus.md` for the full architecture.

## Operating Rules

- **Operate on repo files.** Make changes as patches to files in this repository.
  Read `context/USL_CONTEXT_SNAPSHOT.md` and `context/USL_ACTIVE_TASKS.md` before
  starting.
- **Run tests where available.** If a module has tests or a validation script
  (e.g. `scripts/validate_context_bus.py`), run it and report results.
- **Never touch controlled folders.** No CUI, ITAR, drawings, TDP, cFolders, or
  supplier-restricted data. Do not read these into the model, upload, or commit
  them.
- **Create a patch report.** For every task: files added, files modified,
  validation run, validation result, what it solves, what it does not solve.
- **Do not use external APIs unless explicitly authorized.** No API keys, secrets,
  or outbound integrations beyond normal git usage.
- **Update context handoff files after work.** Write a handoff in
  `context/handoffs/` and update the ledger, file index, and active tasks. Run
  `python scripts/build_context_snapshot.py` and
  `python scripts/validate_context_bus.py` before committing.
- **Respect approval gates.** Do not mark anything release-ready, publish, or
  enable external access without Andrew's approval.

## Setup (once)

Open the same repo / branch and point Codex to:

- `AGENTS.md`
- `.codex/USL_CODEX_INSTRUCTIONS.md` (this file)
- `context/USL_CONTEXT_SNAPSHOT.md`
