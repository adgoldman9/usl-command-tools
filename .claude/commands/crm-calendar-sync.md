---
description: Create Calendar follow-up events for existing CRM rows that have a follow_up_date but no event yet
---

This only runs on a surface with real CRM access (Windows) and a Google
Calendar connector available in this session — see the Execution Surface
Routing Rule in `docs/usl-ai-os-access-protocol.md`. If either is missing,
stop and say so; do not fabricate results.

1. Read `crm_pipeline_activity_log.csv` and `apollo_sequence_task_board.csv`
   from the CRM control path. Collect every row with a non-empty
   `follow_up_date`.
2. For each one, search the primary calendar (`adgoldman9@gmail.com`) for an
   existing event tagged with that row's `task_key` / opportunity ID.
3. **Dry run first.** Before creating anything, list every event you're about
   to create (title, date, task_key) and every one you're skipping because it
   already exists. Show this list and wait for confirmation before writing
   any event — this command may touch many rows at once, unlike the
   single-record step built into `/crm-save`.
4. On confirmation, create the missing events: all-day, titled
   `Follow up: <opportunity_or_solicitation>`, dated on `follow_up_date`, with
   `task_key` and `activity_type` in the description. No other attendees, no
   notifications sent to anyone else.
5. Report what was created vs. skipped. No CRM files are modified by this
   command — it only reads them and writes to Calendar.
