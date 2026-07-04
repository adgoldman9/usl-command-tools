---
description: Save a CRM pipeline activity (local-only) per the USL CRM protocol
---

Read the CRM protocol in `docs/usl-ai-os-access-protocol.md` (section "CRM
protocol") in full, then apply it to this request: $ARGUMENTS

First, confirm the current surface:

- **Windows Claude Code (local access confirmed)**: follow the save procedure
  in that section exactly — backup first, append the pipeline activity row,
  update the agenda/task board and change log, update repo tracking, then
  report with the task's completion label.
- **Cloud/container session (no `C:\Users\motor` access)**: do not attempt the
  save. Instead, write a handoff in `context/handoffs/` capturing the full task
  spec verbatim, add a row to `context/USL_ACTIVE_TASKS.md` marked "pending
  Windows execution," and report that no CRM action was taken.

Never submit anything, contact anyone, or mark anything release-ready as part
of a CRM save — this command only ever produces a local pipeline-activity
record.
