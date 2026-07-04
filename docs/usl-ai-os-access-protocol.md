# USL AI OS Access and Communication Protocol

## Source of truth

USL AI OS root:

`C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System`

Command tools repo:

`C:\Users\motor\OneDrive\Desktop\USL_Command_Center\07_Codex_Builds\usl-command-tools`

Default CRM / Apollo control path:

`C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System\03_Apollo_Outreach\apollo\control`

Windows-local branch is the source of truth. Do not reset, discard, or overwrite local commits.

Preserve local commits:

- `4d5a571` — Phase 1B reconciliation / run proof
- `3a0cbe3` — PowerShell 7 migration verification report

Do not stage `phase1b_run.log`.

PR #2 remains draft unless Andrew explicitly approves otherwise.

## Execution Surface Routing Rule

**Windows Claude Code is the default daily-driver surface** for USL projects,
workflows, data work, and app building — see
[`windows-claude-code-daily-driver.md`](windows-claude-code-daily-driver.md)
for one-time setup and the per-session checklist. Cloud/container sessions are
the fallback for repo-only work when the Windows machine isn't available, not
a substitute.

Choose the right surface before starting a task:

- **Cloud / container Claude or Codex** may only perform **repo-readable work**:
  docs, scripts, diffs, PR review, and artifact verification after files are pushed
  or pasted. It must not touch the live USL AI OS.
- **Windows Claude Code or Windows Codex** must be used for any task touching:
  - `C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System`
  - CRM CSVs
  - Phase folders
  - OneDrive-local files
  - local PowerShell execution
  - local report writes
- If the session **cannot access `C:\Users\motor`**, it must **stop**, state the
  limitation, and produce a handoff prompt. It must **not fabricate** Windows file
  reads, backups, writes, or verification results.
- Windows commits should be **pushed promptly after approval**; cloud sessions
  should sync using `git fetch` and **fast-forward only** (no divergent local
  commits, no reset, no rebase, no discard).
- Protected actions remain blocked unless Andrew explicitly approves.

## Mission

Operate across the USL AI OS using local files as source of truth. Read, summarize, index, and create handoff/update artifacts so ChatGPT, Claude Code, Codex, and Andrew stay aligned across USL workstreams.

## Primary operating areas

Inspect these when relevant:

1. `10_Agent_Operating_Model`
2. `03_Apollo_Outreach\apollo\control`
3. `10_Agent_Operating_Model\ai_os_consolidation_cleanup`
4. `Reports`
5. command-center / daily brief files if present
6. CRM task board / Apollo control CSVs
7. repo `docs` and `tools` folders

## Communication protocol

When completing work, write a local handoff report with:

1. Files read
2. Files created or updated
3. Source-of-truth paths used
4. Status labels changed or preserved
5. CRM updates made, if any
6. Next recommended action
7. Final git status, if repo touched
8. Protected actions performed

Use completion labels for major tasks.

Preserve `NO_GO`, `LOCKED`, and `NOT_READY` states unless Andrew explicitly changes them.

Unknown must remain `UNKNOWN`.

Do not rely on memory alone when a local source file exists.

## CRM protocol

When task text contains `@crm` or `add to crm` — or an uploaded "CRM save prompt"
file (the Codex-style `SAVE_<OPPORTUNITY>_TO_CRM_LOCAL_ONLY` pattern) — save it as
a CRM pipeline activity. This only runs on a surface with real access to:

`C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System\03_Apollo_Outreach\apollo\control`

A cloud/container session cannot execute this — see the Execution Surface Routing
Rule above. It should instead write a handoff capturing the spec below verbatim
(see `context/handoffs/2026-07-02-dibc-rfs-26-02-crm-save-pending-windows.md` for
the reference example) and log it in `USL_ACTIVE_TASKS.md` as pending Windows
execution.

### Save procedure (Windows-local)

1. **Back up first.** Copy the whole CRM control folder to a timestamped sibling,
   e.g. `control_backup_YYYYMMDD_HHMMSS`, before touching anything. Never edit a
   CRM CSV without a fresh backup.
2. **Append the pipeline activity row** to `crm_pipeline_activity_log.csv` (create
   it if it doesn't exist) with the fields below.
3. **Update the agenda/task board** — `apollo_sequence_task_board.csv` — inserting
   the new item at the priority position given in the task (e.g. right after the
   top-ranked existing item for a `TOP`-priority save).
4. **Append an entry to the change log** — `apollo_change_log.csv` — recording the
   event (e.g. `CRM_OPPORTUNITY_RECORD_SAVED`) and status (e.g.
   `SAVED_LOCAL_ONLY`).
5. **Update repo tracking** — mark the corresponding row in
   `context/USL_ACTIVE_TASKS.md` complete if one exists, and write a completion
   handoff in `context/handoffs/`.
6. **Report** using the task's completion label (if given) and the standard
   handoff summary format (see `AGENTS.md` Handoff Rule).

Use existing CRM files if present:

- `apollo_contact_master.csv`
- `apollo_company_research_notes.csv`
- `apollo_sequence_task_board.csv`
- `apollo_change_log.csv`
- `crm_pipeline_activity_log.csv`

Before editing CRM files:

- Create timestamped backups.
- Update local CRM only.
- Do not mutate live Apollo or external systems.

CRM activity fields to capture:

- contact_name
- company_or_agency
- opportunity_or_solicitation
- nsn_or_part_number
- activity_type
- activity_summary
- current_status
- next_action
- follow_up_date
- owner
- source
- tags
- protected_actions_performed = NONE

## PowerShell protocol

Prefer PowerShell 7:

`pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\<script>.ps1`

Windows PowerShell 5.1 is retained and available. Use `powershell` only when explicitly testing or running under 5.1 compatibility.

## Blocked actions unless Andrew explicitly approves

Do not:

- send emails
- create Gmail drafts
- contact suppliers or government contacts
- submit quotes or bids
- mark anything Bid Ready, Quote Ready, Supplier Routed, SAR Ready, CAD Ready, Manufacturing Ready, or Externally Releasable
- delete files
- move source files
- rename source files
- archive source files
- copy source data into canonical locations
- modify Google Drive
- upload, share, or create public links
- mutate trackers or external systems
- push
- update PRs
- convert draft PRs
- unlock destructive cleanup gate
- run destructive cleanup

## Current cleanup / consolidation state

Phase 15 is complete.

Current state:

- CEO status: `NO_GO_PRESERVED`
- Actual destructive cleanup: `NOT_READY`
- Destructive cleanup gate: `LOCKED`
- Protected records remain blocked: `YES`
- Human review required before any future cleanup-related decision

Phase 15 review folder:

`C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System\10_Agent_Operating_Model\ai_os_consolidation_cleanup\Phase_15_NO_GO_Preservation_And_Response_Archive_Handoff_Only`

Open first:

`phase_15_response_archive_handoff.md`

Also review:

- `phase_15_future_review_queue.csv`
- `phase_15_no_go_preservation_register.csv`
- `phase_15_cleanup_authorization_lock_summary.md`
- `phase_15_response_archive_index.csv`
- `phase_15_completion_report.md`

## Standing safety line

Protected actions performed: NONE. No external actions, no cleanup, no source mutation, no push, no PR update, and destructive cleanup gate remains LOCKED.
