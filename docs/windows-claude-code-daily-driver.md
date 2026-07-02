# Windows Claude Code — Default Daily-Driver Setup

Windows Claude Code is the **default surface** for any USL work that touches
Windows, PowerShell, the USL AI OS, CRM CSVs, Phase folders, OneDrive-local
files, or local builds/apps. This doc is the one-time setup plus the
per-session checklist for making that the normal way of working.

Cloud/container Claude Code sessions (Claude Code on the web, Cowork) remain
**repo-readable only** — see the Execution Surface Routing Rule in
[`usl-ai-os-access-protocol.md`](usl-ai-os-access-protocol.md). They cannot
substitute for this setup; they hand off to it.

## One-time setup (on the Windows machine)

1. **Node.js** — Claude Code requires a current Node LTS. Confirm with
   `node --version`; install from nodejs.org if missing.
2. **Claude Code CLI**
   ```
   npm install -g @anthropic-ai/claude-code
   claude --version
   ```
3. **PowerShell 7** — preferred shell for all `tools\*.ps1` scripts.
   ```
   pwsh --version
   ```
   If missing: `winget install --id Microsoft.PowerShell`. Windows PowerShell
   5.1 stays installed as a fallback; use it only when explicitly testing 5.1
   compatibility (see `docs/powershell7_migration/powershell7_upgrade_report.md`).
4. **Repo location** — open a terminal at:
   ```
   C:\Users\motor\OneDrive\Desktop\USL_Command_Center\07_Codex_Builds\usl-command-tools
   ```
   Run `claude` from inside that directory so it auto-loads `CLAUDE.md`
   (which imports `AGENTS.md`) and has the repo as its working root.
5. **USL AI OS root reachable** — confirm OneDrive has synced:
   ```
   C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System
   ```

## Every session start (checklist)

1. State the surface explicitly: "Windows Claude Code, local."
2. Run the one-shot status snapshot before doing anything else:
   ```
   pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\usl-status.ps1
   ```
   Confirms repo branch/HEAD, working-tree status, USL AI OS root, CRM
   control path, Phase 15 gate state.
3. Read `context\USL_CONTEXT_SNAPSHOT.md`, `context\USL_ACTIVE_TASKS.md`, and
   the latest file in `context\handoffs\`.
4. For a full access/CRM/agenda-key verification pass (writes a timestamped
   report, no CRM edits):
   ```
   pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\usl-local-access-verification.ps1
   ```
5. Before emitting any completion/gate label, assert the safety gates:
   ```
   pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\Assert-UslGates.ps1 -RequireNoGoPreserved -RequireGateLocked -RequireProtectedActionsNone
   ```

## Daily workflow

- Do the work: CRM edits (timestamped backup first — see `AGENTS.md` CRM
  protocol), Phase-folder review, repo tools/scripts, building/running apps
  locally.
- Commit locally with clear messages. **Do not push** or update PR #2 without
  Andrew's explicit approval — pushing and PR updates are blocked actions per
  `usl-ai-os-access-protocol.md` until approved, then should happen promptly
  after approval.
- Write a session handoff in `context\handoffs\` (repo work) or a local
  report under the relevant USL OS `reports\` folder (CRM/Phase work), update
  `USL_MEMORY_LEDGER.md` / `USL_FILE_INDEX.md` / `USL_ACTIVE_TASKS.md` as
  applicable, then:
  ```
  python scripts\build_context_snapshot.py
  python scripts\validate_context_bus.py
  ```
- Every completion response includes: files read, files created/updated,
  status labels changed/preserved, CRM updates (if any), next action, git
  status, and "Protected actions performed: NONE" (unless Andrew explicitly
  authorized something more).

## Script quick reference (`tools\`, PowerShell 7)

| Script | Purpose |
| --- | --- |
| `usl-status.ps1` | One-shot read-only operating status — run first, every session |
| `usl-local-access-verification.ps1` | Full access/CRM/agenda-key verification + report |
| `Assert-UslGates.ps1` | Gate assertion before any completion label |
| `usl-crm-pipeline-agenda-refresh.ps1` | CRM agenda upsert (dry-run default; `-Commit` to write) |
| `usl-phase1b-cross-source-overlay.ps1` | Phase 1B cross-source inventory overlay (SAGE doctrine, read-only) |
| `usl-supplier-part-match-discovery.ps1` | Supplier/part-drawing discovery scaffold |
| `consolidate-agent-conversations.ps1` | ChatGPT/Codex/Claude conversation archive consolidator |
| `export-usl-context.ps1` | Rebuild + validate the repo AI Context Bus |

## When to still use a cloud/container session

Cloud sessions stay useful for repo-only work when you're away from the
Windows machine: reading docs, drafting scripts/docs for later Windows
review, PR review, or verifying already-pushed output. A cloud session that
is asked to touch Windows, PowerShell, the CRM, or Phase folders must stop,
state the limitation, and produce a handoff rather than fabricate results —
see the Execution Surface Routing Rule.
