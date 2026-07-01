# USL OS Phase 1B — Cross-Source Inventory Overlay

`tools/usl-phase1b-cross-source-overlay.ps1` runs Phase 1B of the USL AI Operating
System consolidation under the **SAGE** doctrine (Schema, Audit, Gate, Eval).

It is **read-only over all sources** and writes its outputs **only inside the
cleanup folder**. It never deletes, moves, or copies source files; performs no
uploads, links, emails, drafts, bids/quotes/RFQs, or submissions; and never
mutates trackers or marks anything Ready. Destructive cleanup stays **LOCKED**
unless Andrew supplies `APPROVE_DESTRUCTIVE_CLEANUP_PHASE` — and this script never
unlocks it.

> **Where it runs:** on the Windows machine that holds the USL OS root
> (`C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System`). It cannot run in a
> cloud container or anywhere without the Phase 1 outputs present.

## What it reads (Phase 1 outputs, read-only)

`consolidation_inventory_summary.json`, the three `Inventory\*.csv` files, the
`Plans\*.md` files, and the `Reports\*` duplicate/summary files. Row counts are
recomputed where the CSV is readable, else the known Phase 1 counts are used.

## What it creates (inside `Phase_1B_Cross_Source_Inventory\`)

1. `cross_source_inventory_scope.md`
2. `cross_source_source_map.csv`
3. `canonical_sync_map.md`
4. `cross_source_duplicate_review_plan.md`
5. `cad_generator_index_link_plan.md`
6. `google_drive_sync_requirements.md`
7. `one_drive_local_scan_requirements.md`
8. `chatgpt_claude_codex_memory_alignment_plan.md`
9. `phase_1b_safety_gate_audit.json`
10. `phase_1b_completion_report.md`
11. `phase_1b_next_task_command.md`

## Classifications

- **Sources:** CANONICAL_ROOT, LOCAL_ONEDRIVE_SOURCE, LOCAL_DESKTOP_SOURCE,
  LOCAL_DOCUMENTS_SOURCE, GOOGLE_DRIVE_PENDING_OR_LOCAL_SYNC,
  CHATGPT/CLAUDE/CODEX_SURFACE_ARCHIVE, CAD_GENERATOR_INDEX_ONLY,
  UNKNOWN_REVIEW_REQUIRED.
- **Duplicate posture:** KEEP_CANONICAL, CANONICAL_INDEX_ONLY,
  CLEANUP_CANDIDATE_EXACT_DUPLICATE, KEEP_ARCHIVE_COPY,
  DO_NOT_DELETE_CONTROLLED_OR_UNKNOWN, REVIEW_REQUIRED_PATH_CONTEXT,
  PENDING_CROSS_SOURCE_HASH. This phase assigns only review/pending postures —
  duplicate status is never deletion approval.

## Safety behavior

- Google Drive is accessed only if locally synced; otherwise documented as
  `PENDING_SOURCE_ACCESS` with a requirements checklist (no external access).
- The existing conversation archive is treated as a managed area and is **not**
  re-inventoried as a new source.
- The CAD generator root is preserved as separate (index-link plan only).
- Secret-like paths/filenames are redacted as `REDACTED_PATTERN`; skipped files
  are not opened.

## How to run

```powershell
git pull
powershell -ExecutionPolicy Bypass -File tools\usl-phase1b-cross-source-overlay.ps1
```

Final console label on success:
`USL_OS_PHASE_1B_CROSS_SOURCE_INVENTORY_OVERLAY_COMPLETE__DESTRUCTIVE_CLEANUP_GATE_LOCKED`
