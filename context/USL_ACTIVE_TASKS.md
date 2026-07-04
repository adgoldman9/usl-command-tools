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
| 9 | DIBC-RFS-26-02 (DMRE) CRM save — local only | Spec ready / run pending on Windows | — | CEO_QA_GO for Stage 1 answer pack prep only; NOT_SUBMITTED; see `context/handoffs/2026-07-02-dibc-rfs-26-02-crm-save-pending-windows.md` for full spec; requires `C:\Users\motor\...\apollo\control`, backup-first |

## Notes

- Update Status as tasks move. Close finished tasks during the weekly review.
- New tasks added here should also exist in the CRM where they are structured
  project items.
