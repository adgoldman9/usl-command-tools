# Handoff — 2026-07-02 (local)

- **Date/time:** 2026-07-02
- **Platform used:** Claude Code (cloud/container session)
- **Repo / path:** `adgoldman9/usl-command-tools`, branch `claude/usl-ai-os-handoff-atila7`
- **Task:** User uploaded a Codex-style save prompt
  (`USL_DIBC_RFS_26_02_Codex_CRM_Save_Prompt.md`) asking to save a local CRM
  agenda/pipeline activity for **DIBC-RFS-26-02 — Defense Manufacturing
  Readiness Exercise (DMRE)**. The target path is
  `C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System\03_Apollo_Outreach\apollo\control`
  (Windows-local CRM). This session verified it is a cloud/container Linux
  environment with **no access to `C:\Users\motor`** — confirmed no such
  path, no `/mnt/c`, plain Linux container. Per the Execution Surface Routing
  Rule, stopped rather than fabricate a CRM write. **No CRM save was
  performed.**
- **Files changed (this session, repo-only):**
  - `context/USL_ACTIVE_TASKS.md` — added task #9 (spec ready / run pending
    on Windows).
  - This handoff file, preserving the full task spec below so it isn't lost.
- **Task spec to execute on Windows Claude Code (verbatim from the uploaded
  prompt):**
  - Activity type: `OPPORTUNITY_REVIEW / STAGE_1_RESPONSE_PREP`
  - Priority: `TOP / HIGH`
  - Opportunity: DIBC-RFS-26-02 — Defense Manufacturing Readiness Exercise
    (DMRE)
  - Source: Defense Industrial Base Consortium (DIBC) / ATI public
    solicitation page
  - Due: 2026-07-20 23:59 ET
  - Status: `CEO_QA_GO / STAGE_1_ANSWER_PACK_BUILT / INTERNAL_REVIEW_REQUIRED / NOT_SUBMITTED`
  - Summary: USL reviewed the DIBC DMRE RFS and received CEO QA GO to save
    the opportunity to CRM and build the Stage 1 answer pack. Stage 1 must
    remain high-level, non-proprietary, non-CUI, non-export-controlled, and
    non-customer-sensitive. No submission is approved.
  - Recommended USL fit: Primary — supplier-network coordinator and
    manufacturing-readiness support for bounded production roles. Topic 1
    primary; Topic 2 only as secondary support role if included.
  - Next action: Andrew reviews the Stage 1 answer pack, confirms AMP
    access, downloads/reviews Attachment 2 (Warranties and Representations),
    confirms company identifiers/certifications, and separately
    approves/rejects submission.
  - Hard rules: back up local CRM files before editing; do not submit
    anything; do not create emails/drafts; do not upload documents; do not
    include CUI/export-controlled/classified/proprietary/customer-sensitive
    content or detailed pricing; do not mark submitted; do not make
    production commitments; do not mutate external systems.
  - Files to inspect/update if present: `apollo_sequence_task_board.csv`,
    `apollo_change_log.csv`, any local CRM agenda/pipeline activity file in
    the default CRM path.
  - Completion label:
    `USL_DIBC_RFS_26_02_CRM_RECORD_SAVED_LOCAL_ONLY__NOT_SUBMITTED__NO_PROTECTED_ACTIONS`
  - Required report after saving: CRM agenda/task file updated; backup path
    created; row/task added; priority placement; final task status;
    "Protected actions performed: NONE."
- **Decisions made:** None — awaiting Windows-side execution.
- **Validation:** N/A (no CRM action taken).
- **Risks:** None from this session. Flagging that the original prompt
  content (opportunity summary, due date, fit assessment) is Internal
  sensitivity, not controlled data, so it's safe to carry in this repo
  handoff per `USL_FILE_INDEX.md` classification norms.
- **Next action:** Run this task on Windows Claude Code (or Codex) at the
  daily-driver setup described in
  `docs/windows-claude-code-daily-driver.md`: back up the CRM CSVs, add the
  agenda/pipeline activity row per the spec above, do not submit anything,
  and report using the completion label above.
- **Copy/paste prompt for next platform:**

      Read this handoff in full, then execute the DIBC-RFS-26-02 CRM save
      exactly as specified: back up
      C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System\03_Apollo_Outreach\apollo\control
      first, add the pipeline activity/agenda row with the fields above,
      make no submission or external contact, and report with completion
      label USL_DIBC_RFS_26_02_CRM_RECORD_SAVED_LOCAL_ONLY__NOT_SUBMITTED__NO_PROTECTED_ACTIONS.
