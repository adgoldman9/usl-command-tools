# USL Active Tasks

Current in-flight tasks. Keep aligned with the CRM (the CRM is the system of record
for structured state). `scripts/build_context_snapshot.py` includes this file in
`USL_CONTEXT_SNAPSHOT.md`.

| # | Task | Status | Owner | Notes |
| --- | --- | --- | --- | --- |
| 1 | CRM Phase 2C — app/config loader alignment | Authorized / pending | — | Confirm loader alignment; update gate when complete |
| 2 | CRM Phase 2D — manual smoke test | Pending | — | Follows 2C |
| 3 | AI Context Bus patch | In progress | — | This patch: docs + context files + scripts |
| 4 | GCC SharePoint/OneDrive remediation plan | Pending | — | External sharing remediation |
| 5 | LLM provider abstraction design | Planned | — | Vendor-agnostic provider layer |
| 6 | Cerebras live integration | Parked | — | Parked until prioritized |
| 7 | Agent conversation archive consolidation | **COMPLETE** | — | Ran 2026-07-04 on Windows. 1,139 candidates, 202 copied, 213 duplicates skipped, 222 skipped for secret/pattern review (see `agent_conversation_archive\Migration_Reports\conversation_archive_skipped_items.md`), 0 copy failures. Originals untouched. |
| 8 | USL OS consolidation Phase 1B cross-source overlay | Tool ready / run pending | — | `tools/usl-phase1b-cross-source-overlay.ps1`; SAGE, read-only, destructive gate LOCKED; run on Windows |
| 9 | DIBC-RFS-26-02 (DMRE) CRM save — local only | **COMPLETE** | — | Saved 2026-07-04 on Windows Claude Code. Backup at `control_backup_20260704_113008`. Row added to `crm_pipeline_activity_log.csv` (rank 002, TOP) and `apollo_sequence_task_board.csv`. NOT_SUBMITTED. Protected actions: NONE. |
| 10 | CI: context-bus validation workflow | Done | — | `.github/workflows/context-bus-validate.yml`; rebuilds + validates snapshot on every PR/push to main |
| 11 | Claude Code permission allowlist | Done (initial pass) | — | `.claude/settings.json`; only 1 transcript available to mine so far — re-run the `fewer-permission-prompts` skill after more sessions accumulate |
| 12 | CRM save protocol standardization | Done | — | Expanded save procedure in `usl-ai-os-access-protocol.md` + `/crm-save` slash command in `.claude/commands/crm-save.md` |
| 13 | GitHub branch protection on `main` | **COMPLETE** | — | Set up via GitHub Rulesets (2026-07-04): targets `main`, requires PR before merging, requires the `validate` (GitHub Actions) status check. Confirmed via API: `main` now reports `protected: true` |
| 14 | LLM provider abstraction layer | Parked — no concrete integration point yet | — | No code in this repo calls an LLM API directly; building an abstraction now would be speculative. Revisit once a specific tool needs it |
| 15 | Windows Claude Code cleanup (duplicate install, update) | **COMPLETE** | — | Done 2026-07-04. npm-global reinstalled fresh at latest (2.1.201); `/doctor` no longer flags multiple installations. Old unused native install (`.local\share\claude`, v2.1.87) left on disk — harmless, optional to delete. Note: auto-updates now shows "disabled (config)" — was enabled before, minor, not urgent |
| 16 | Weekly SOP automation via Windows Task Scheduler | Recommended / pending on Windows | — | Schedule `tools\usl-status.ps1` + `tools\usl-local-access-verification.ps1` per `docs/ai-context-bus-sop.md`; Claude Code cron is session-scoped (7-day max), not suitable — use Task Scheduler |
| 17 | Calendar auto-reminders from CRM follow_up_date | Built / first live run pending on Windows | — | Approved. `/crm-save` now creates a follow-up event as its last step; `/crm-calendar-sync` batch-syncs existing rows (dry-run list first, then confirm). Confirmed this session's Calendar connector is `adgoldman9@gmail.com`. Cannot test from cloud — no CRM data accessible here; first real run must happen on Windows |

## Notes

- Update Status as tasks move. Close finished tasks during the weekly review.
- New tasks added here should also exist in the CRM where they are structured
  project items.
