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
| 7 | Agent conversation archive consolidation | **COMPLETE** | — | Ran 2026-07-04 on Windows. 1,139 candidates, 202 copied, 213 duplicates skipped, 222 skipped for secret/pattern review (see `agent_conversation_archive\Migration_Reports\conversation_archive_skipped_items.md`), 0 copy failures. Originals untouched. |
| 8 | USL OS consolidation Phase 1B cross-source overlay | Tool ready / run pending | — | `tools/usl-phase1b-cross-source-overlay.ps1`; SAGE, read-only, destructive gate LOCKED; run on Windows |
| 9 | DIBC-RFS-26-02 (DMRE) CRM save — local only | **COMPLETE** | — | Saved 2026-07-04 on Windows Claude Code. Backup at `control_backup_20260704_113008`. Row added to `crm_pipeline_activity_log.csv` (rank 002, TOP) and `apollo_sequence_task_board.csv`. NOT_SUBMITTED. Protected actions: NONE. |
| 10 | CI: context-bus validation workflow | Done | — | `.github/workflows/context-bus-validate.yml`; rebuilds + validates snapshot on every PR/push to main |
| 11 | Claude Code permission allowlist | Done (initial pass) | — | `.claude/settings.json`; only 1 transcript available to mine so far — re-run the `fewer-permission-prompts` skill after more sessions accumulate |
| 12 | CRM save protocol standardization | Done | — | Expanded save procedure in `usl-ai-os-access-protocol.md` + `/crm-save` slash command in `.claude/commands/crm-save.md` |
| 13 | GitHub branch protection on `main` | **COMPLETE** | — | Set up via GitHub Rulesets (2026-07-04): targets `main`, requires PR before merging, requires the `validate` (GitHub Actions) status check. Confirmed via API: `main` now reports `protected: true` |
| 14 | LLM provider abstraction layer | Parked — no concrete integration point yet | — | No code in this repo calls an LLM API directly; building an abstraction now would be speculative. Revisit once a specific tool needs it |
| 15 | Windows Claude Code cleanup (duplicate install, update) | **COMPLETE** | — | Done 2026-07-04. npm-global reinstalled fresh at latest (2.1.201); `/doctor` no longer flags multiple installations. Old unused native install (`.local\share\claude`, v2.1.87) left on disk — harmless, optional to delete. Note: auto-updates now shows "disabled (config)" — was enabled before, minor, not urgent |
| 16 | Weekly SOP automation via Windows Task Scheduler | **COMPLETE** | — | Created 2026-07-04: "USL Weekly Status Check" scheduled task runs `tools\usl-status.ps1` every Monday 09:00 via `schtasks`. Confirmed created successfully |
| 17 | Calendar auto-reminders from CRM follow_up_date | **COMPLETE** | — | First live `/crm-calendar-sync` run 2026-07-04 on Windows: 5 candidates found, dry-run reviewed, 2 past-due + 2 duplicate rows correctly skipped on confirmation, 3 events created (DIBC-RFS-26-02, TDMT access follow-up, SPRMM1-26-Q-MF39). No CRM files modified. Independently verified from cloud session via Calendar API — all 3 events present with correct dates/task_key |
| 18 | Fix Codex review findings on PR #3 (usl-local-access-verification.ps1) | **COMPLETE** | — | Two real bugs from automated Codex review: (1) invalid inline `if(){}else{}` expression at line 89 → replaced with PowerShell 7 ternary; (2) `-ExpectedHead`/`-ExpectedBranch` defaulted to a stale historical commit/branch, always failing branch/HEAD checks on a healthy repo → defaults changed to empty, reported as INFO-only unless explicitly pinned |
| 19 | "copy-paste-handoff" skill (skill-creator) | **BLOCKED** | — | Requested from a Claude Code cloud/GitHub-repo session; `skill-creator` is a claude.ai/Cowork-side skill not invocable from this repo-scoped session (`Unknown skill: skill-creator`). Needs to be run from an actual Cowork/claude.ai chat session. Spec captured in `context/handoffs/2026-07-13-claude-code-copy-paste-handoff-skill-blocked.md` |

## Notes

- Update Status as tasks move. Close finished tasks during the weekly review.
- New tasks added here should also exist in the CRM where they are structured
  project items.
