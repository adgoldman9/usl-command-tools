# Handoff — 2026-07-02 (local, follow-up)

- **Date/time:** 2026-07-02
- **Platform used:** Claude Code (cloud/container session)
- **Repo / path:** `adgoldman9/usl-command-tools`, branch `claude/usl-ai-os-handoff-atila7`
- **Task:** Follow-up to the Windows-daily-driver handoff. User asked for
  Claude Code to have the **same operating parity as Windows Codex** for
  local USL task execution — explicit approved-capability list (read/write
  approved OneDrive paths, read/write the repo, run PowerShell 7, create
  Phase folders/reports, update CRM CSVs only when explicitly instructed,
  backup-before-edit, completion labels/audit reports) — with all existing
  safety rules unchanged (no external sends, no supplier contact, no
  bid/quote submission, no public links, no destructive cleanup, no
  deleting/moving/renaming/archiving source data, no push/PR update without
  approval, no staging `phase1b_run.log`, PR #2 stays draft, destructive
  cleanup gate stays `LOCKED`).
- **Files changed:** `docs/windows-claude-code-daily-driver.md` — added
  "Approved local capabilities" and "Safety rules (unchanged — do not loosen
  for this setup)" sections, enumerating exactly the capability/rule split
  above so it's the canonical spec. `context/USL_CONTEXT_SNAPSHOT.md`
  regenerated.
- **Decisions made:** Parity means equal *capability* on the Windows
  surface, not loosened *rules*. No change was made to any blocked-action
  rule, approval gate, or the Execution Surface Routing Rule itself — this
  session (cloud) still cannot touch Windows/CRM directly and did not
  attempt to.
- **Validation:** `python scripts/build_context_snapshot.py` and
  `python scripts/validate_context_bus.py` — PASS.
- **Risks:** None — docs only. No CRM mutation, no source-file moves, no
  push performed without approval.
- **Next action:** Once pushed/merged, the Windows Claude Code session
  should treat `docs/windows-claude-code-daily-driver.md` as the capability
  spec going forward; no other repo changes are needed to achieve parity —
  it was already documented, this just makes the capability/rule boundary
  explicit and unambiguous.
- **Copy/paste prompt for next platform:**

      Read docs/windows-claude-code-daily-driver.md in full, including the
      Approved local capabilities and Safety rules sections. Operate within
      that capability list exactly; do not treat "daily driver" as license
      to skip backups, CRM-trigger conditions, or any approval gate.
