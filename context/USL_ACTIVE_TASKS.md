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
| 7 | Agent conversation archive consolidation | Tool ready / run pending | — | `tools/consolidate-agent-conversations.ps1`; must run on the Windows USL OS machine |
| 8 | USL OS consolidation Phase 1B cross-source overlay | Tool ready / run pending | — | `tools/usl-phase1b-cross-source-overlay.ps1`; SAGE, read-only, destructive gate LOCKED; run on Windows |
| 9 | DIBC-RFS-26-02 (DMRE) CRM save — local only | **COMPLETE** | — | Saved 2026-07-04 on Windows Claude Code. Backup at `control_backup_20260704_113008`. Row added to `crm_pipeline_activity_log.csv` (rank 002, TOP) and `apollo_sequence_task_board.csv`. NOT_SUBMITTED. Protected actions: NONE. |
| 10 | CI: context-bus validation workflow | Done | — | `.github/workflows/context-bus-validate.yml`; rebuilds + validates snapshot on every PR/push to main |
| 11 | Claude Code permission allowlist | Done (initial pass) | — | `.claude/settings.json`; only 1 transcript available to mine so far — re-run the `fewer-permission-prompts` skill after more sessions accumulate |
| 12 | CRM save protocol standardization | Done | — | Expanded save procedure in `usl-ai-os-access-protocol.md` + `/crm-save` slash command in `.claude/commands/crm-save.md` |
| 13 | GitHub branch protection on `main` | Recommended / needs manual setup | — | No branch-protection tool in the connected GitHub MCP server — must be configured in GitHub repo Settings → Branches, not from an AI session |
| 14 | LLM provider abstraction layer | Parked — no concrete integration point yet | — | No code in this repo calls an LLM API directly; building an abstraction now would be speculative. Revisit once a specific tool needs it |
| 15 | Windows Claude Code cleanup (duplicate install, update) | Pending on Windows | — | `/doctor` found both npm-global and native installs; recommend removing one and running `claude update` |
| 16 | Weekly SOP automation via Windows Task Scheduler | Recommended / pending on Windows | — | Schedule `tools\usl-status.ps1` + `tools\usl-local-access-verification.ps1` per `docs/ai-context-bus-sop.md`; Claude Code cron is session-scoped (7-day max), not suitable — use Task Scheduler |
| 17 | Calendar auto-reminders from CRM follow_up_date | Not started — needs explicit decision | — | Google Calendar MCP connector is live; crosses the "no automation without explicit approval" line and needs a deliberate yes before building |

## Notes

- Update Status as tasks move. Close finished tasks during the weekly review.
- New tasks added here should also exist in the CRM where they are structured
  project items.
