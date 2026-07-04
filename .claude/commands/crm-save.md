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

## Calendar follow-up (only after the local save above is complete)

If the saved record has a `follow_up_date` and a Google Calendar connector is
available in this session:

1. Check for an existing event first (search the primary calendar for the
   `task_key` / opportunity ID) to avoid creating a duplicate on a re-run.
2. If none exists, create one all-day event on the primary calendar
   (`adgoldman9@gmail.com`) titled `Follow up: <opportunity_or_solicitation>`,
   dated on `follow_up_date`, with the `task_key`, `activity_type`, and a link
   back to the CRM row in the description. Do not add other attendees and do
   not send notifications to anyone else.
3. Report the event created (or skipped, if one already existed) as part of
   the save summary.

If no Calendar connector is available in this session, skip this step
entirely and say so in the report — do not fail the CRM save over it.
