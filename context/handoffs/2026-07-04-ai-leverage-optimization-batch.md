# Handoff — 2026-07-04 (local)

- **Date/time:** 2026-07-04
- **Platform used:** Claude Code (cloud/container session)
- **Repo / path:** `adgoldman9/usl-command-tools`, branch `claude/usl-ai-os-handoff-atila7`
- **Task:** User asked for recommendations to optimize access/functionality/AI
  leverage across projects, then said "do all of them." Executed everything
  doable from a repo-only cloud session; flagged the rest as Windows-only,
  manual-GitHub-settings-only, or genuinely needing a human decision first.
- **Files changed:**
  - `.github/workflows/context-bus-validate.yml` — new CI workflow: rebuilds
    `USL_CONTEXT_SNAPSHOT.md` and diffs it against HEAD (ignoring the
    timestamp line) and runs `validate_context_bus.py` on every PR and push
    to `main`. Verified locally both the pass and fail path before trusting
    it.
  - `.claude/settings.json` — new project permission allowlist. Only one
    session transcript existed to mine (`mcp__github__pull_request_read`,
    count 4); everything else observed either mutates state or is already
    auto-allowed by Claude Code. Re-run the `fewer-permission-prompts` skill
    later once more sessions have accumulated.
  - `docs/usl-ai-os-access-protocol.md` — CRM protocol section expanded from
    a fields list into an explicit numbered save procedure (backup → append
    activity row → update agenda/task board → update change log → update
    repo tracking → report), matching what the Windows session actually did
    successfully for DIBC-RFS-26-02.
  - `.claude/commands/crm-save.md` — new `/crm-save` slash command that
    reads the protocol and routes to the Windows save procedure or a
    pending-handoff, depending on surface.
  - `context/USL_ACTIVE_TASKS.md` — task #9 marked complete (Windows CRM
    save landed); added #10–17 covering everything from this batch.
  - `context/USL_FILE_INDEX.md` — indexed the three new files.
  - `context/USL_CONTEXT_SNAPSHOT.md` regenerated.
- **Decisions made / deliberately not made:**
  - Did **not** attempt GitHub branch protection — no tool for it in the
    connected GitHub MCP server; it's a repo Settings change, not a file, so
    it needs to be done by hand in GitHub's UI (steps given to the user).
  - Did **not** build an LLM provider abstraction layer — no code in this
    repo calls an LLM API directly yet, so there is no concrete integration
    point to abstract. Building one now would be speculative; parked until
    a real use case exists.
  - Did **not** build Calendar auto-reminders from CRM `follow_up_date` —
    this crosses the "no automation without explicit approval" line by
    design (it's a new automated write to a calendar based on business
    data). Needs an explicit yes, not a blanket "do all of them."
  - Windows-only items (duplicate Claude Code install cleanup, `claude
    update`, Task Scheduler automation for the weekly SOP) were left as
    instructions for the user to run on the Windows machine — this cloud
    session cannot execute them.
- **Validation:** `python scripts/build_context_snapshot.py` +
  `python scripts/validate_context_bus.py` — PASS. CI workflow's diff logic
  manually tested for both the pass case (no real drift) and fail case
  (injected a fake task-board row, confirmed the diff caught it).
- **Risks:** None — all changes are docs/config/CI, no CRM mutation, no
  source-file moves, no push without approval.
- **Next action:** Andrew reviews and pushes this batch (holding per
  approval-gate convention). Separately: (1) set up GitHub branch
  protection manually if desired, (2) decide yes/no on Calendar automation,
  (3) run the Windows cleanup steps, (4) revisit LLM provider abstraction
  once a concrete tool needs an LLM API call.
- **Copy/paste prompt for next platform:**

      Read context/USL_ACTIVE_TASKS.md rows 10-17 for the full list of what
      was done vs. still pending from the 2026-07-04 AI-leverage
      optimization batch. Windows-only items and the two decisions flagged
      there (branch protection, Calendar automation) are still open.
