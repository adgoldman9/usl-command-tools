# Handoff — 2026-06-28 16:10 (local)

- **Date/time:** 2026-06-28 16:10 local
- **Platform used:** Claude Code / Cowork
- **Repo / path:** `usl-command-tools` @ `claude/saved-memory-sync-access-kukbtk`; `docs/`, `context/`, `scripts/`, `tools/`, `.chatgpt/`, `.codex/`, `AGENTS.md`, `CLAUDE.md`
- **Task:** Implement the USL AI Context Bus patch (Active Task #3). Demote the Claude sync doc to an appendix and add the repo-backed cross-vendor context layer.
- **Files changed:**
  - Added: `docs/ai-context-bus.md`, `docs/ai-context-bus-sop.md`, `docs/ai-platform-sync-matrix.md`, `CLAUDE.md`, `.chatgpt/USL_PROJECT_INSTRUCTIONS.md`, `.codex/USL_CODEX_INSTRUCTIONS.md`, `context/USL_CONTEXT_SNAPSHOT.md` (generated), `context/USL_MEMORY_LEDGER.md`, `context/USL_FILE_INDEX.md`, `context/USL_ACTIVE_TASKS.md`, `context/handoffs/README.md`, `scripts/build_context_snapshot.py`, `scripts/validate_context_bus.py`, `tools/export-usl-context.ps1`
  - Modified: `AGENTS.md` (now the shared agent contract), `README.md`, `docs/README.md`, `docs/claude-app-sync.md` (now an appendix)
- **Decisions made:** Repo context files are the cross-vendor memory; native vendor memory is never the system of record. Source-of-truth order: CRM/database → repo context → Google Drive → chats. Recorded in `USL_MEMORY_LEDGER.md`.
- **Validation:** `python -m py_compile` on both scripts (OK); `build_context_snapshot.py` (wrote snapshot); `validate_context_bus.py` → PASS. PowerShell not available in this environment, so `tools/export-usl-context.ps1` was not executed (review-only).
- **Risks:** Documentation + local tooling only — no external APIs, no secrets, no controlled data, CRM untouched. PowerShell helper untested in CI (no pwsh here).
- **Next action:** Complete the one-time manual setup (load context files into the ChatGPT Project, point Claude/Codex at the repo), then advance CRM Phase 2C (Active Task #1).
- **Copy/paste prompt for next platform:**

      Read context/USL_CONTEXT_SNAPSHOT.md, context/USL_ACTIVE_TASKS.md, and the
      latest file in context/handoffs/. Follow AGENTS.md and your platform
      instruction file. Then work Active Task #1 (CRM Phase 2C app/config loader
      alignment). Do not touch controlled folders or the CRM database. End by
      writing a handoff in context/handoffs/ and updating the ledger/tasks.
