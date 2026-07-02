# Handoff — 2026-07-02 (local)

- **Date/time:** 2026-07-02
- **Platform used:** Claude Code (cloud/container session)
- **Repo / path:** `adgoldman9/usl-command-tools`, branch `claude/usl-ai-os-handoff-atila7`
- **Task:** User asked to establish a default surface for accessing Windows,
  PowerShell, projects, workflows, data, and app building. Clarified with the
  user that this means: make **Windows Claude Code** the daily driver, and
  document/wire that as the default in the repo's operating instructions.
  This cloud session cannot touch Windows/PowerShell/CRM itself (Execution
  Surface Routing Rule), so the work here is repo-only: setup guide + routing
  doc updates.
- **Files changed:**
  - Added `docs/windows-claude-code-daily-driver.md` — one-time setup,
    per-session checklist, daily workflow, script quick reference, and
    guidance on when a cloud session is still appropriate.
  - `docs/usl-ai-os-access-protocol.md` — Execution Surface Routing Rule now
    states Windows Claude Code is the default surface and links the new doc.
  - `docs/ai-platform-sync-matrix.md` — split the single "Claude Code /
    Cowork" row into "Claude Code (Windows, local)" (default daily driver)
    and "Claude Code / Cowork (cloud/container)" (repo-only fallback).
  - `AGENTS.md` — added a "Default surface" pointer near the top, before the
    Core Operating Rules.
  - `README.md` — added the new doc to the AI Context Bus doc list.
  - `context/USL_FILE_INDEX.md` — indexed the new doc.
  - `context/USL_MEMORY_LEDGER.md` — added the default-surface rule under
    AI-platform operating rules.
- **Decisions made:** Windows Claude Code is now the documented default
  surface for Windows/PowerShell/CRM/Phase-folder/build work; cloud/container
  sessions are explicitly the fallback for repo-only work. No change to the
  underlying access rules (cloud still cannot push without approval, still
  cannot touch the CRM/USL AI OS, still cannot fabricate Windows results).
- **Validation:** `python scripts/build_context_snapshot.py` and
  `python scripts/validate_context_bus.py` run after these edits (see git
  status / commit for result).
- **Risks:** None — docs/context only, no CRM mutation, no source-file
  moves, no push performed without approval (repo protocol blocks push/PR
  updates unless Andrew explicitly approves; this session held commits
  locally and asked before pushing).
- **Next action:** Andrew reviews the new doc and routing changes; once
  approved, push this branch and open/update the PR. On the Windows machine,
  follow `docs/windows-claude-code-daily-driver.md` for one-time setup, then
  run `tools\usl-status.ps1` to confirm access before starting work.
- **Copy/paste prompt for next platform:**

      Read docs/windows-claude-code-daily-driver.md and
      docs/usl-ai-os-access-protocol.md. If on Windows, run
      tools\usl-status.ps1 first, then proceed with normal USL work per
      AGENTS.md / CLAUDE.md. If on a cloud/container session, repo-only work
      only.
