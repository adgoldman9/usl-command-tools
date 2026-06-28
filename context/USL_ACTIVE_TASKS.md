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

## Notes

- Update Status as tasks move. Close finished tasks during the weekly review.
- New tasks added here should also exist in the CRM where they are structured
  project items.
