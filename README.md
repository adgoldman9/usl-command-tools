# USL Command Tools

This repo is the local code workspace for USL browser tools, dashboards, scripts, and build documentation.

The repo is designed for simple local-first tools that can be opened in a browser, reviewed by Codex, and later moved to GitHub when ready.

## Modules

- `sar-system/` - SAR, ESA, RPPOB, CSI, and quoteability workflow tools.
- `opportunity-tracker/` - SAM.gov, DIBBS, LRAF, NSN, and hardware opportunity tracking.
- `nsn-review-dashboard/` - NSN and NIIN review dashboards and decision-support utilities.
- `supplier-outreach-tools/` - Supplier list cleanup, outreach tracking, and CSV utilities.
- `usl-command-dashboard/` - Daily USL command dashboard, mobile capture, and status reporting.
- `mobile-capture-inbox/` - Mobile-first capture inbox with CSV and optional Google Sheets sync.
- `apps-script/` - Google Apps Script backend templates for optional shared sync.
- `context/` - USL AI Context Bus: canonical operating memory, tasks, file index, and session handoffs read by every AI platform.
- `scripts/`, `tools/` - Context Bus tooling (snapshot builder, validator, Windows export helper).
- `docs/` - Deployment notes, operating docs, AI Context Bus + Claude app sync references, and GitHub Pages instructions.

## AI Context Bus

USL keeps **one repo-backed, human-readable operating memory** that every AI tool
(Claude, ChatGPT, Codex, mobile, desktop) reads from and writes back to, instead of
relying on each vendor's native chat memory (which does not cross vendors). Start
here:

- `docs/ai-context-bus.md` - architecture and source-of-truth hierarchy.
- `docs/ai-context-bus-sop.md` - daily / weekly operating SOP.
- `docs/ai-platform-sync-matrix.md` - per-platform sync matrix.
- `AGENTS.md` / `CLAUDE.md` - shared and Claude-specific agent instructions.
- `docs/claude-app-sync.md` - Claude mobile↔desktop sync (appendix, not the master solution).
- `docs/windows-claude-code-daily-driver.md` - default-surface setup: Windows Claude Code for Windows/PowerShell/CRM/build work; cloud sessions are the repo-only fallback.

## Local Use

Open each browser tool by opening its `index.html` file directly, unless that tool's README says to use a local server.

## Standards

- Use plain HTML, CSS, and JavaScript unless a framework is explicitly requested.
- Avoid unnecessary dependencies.
- Keep sensitive business data out of public files and repo history.
- Add clear README instructions for each tool.
- Use `AGENTS.md` as the operating guide for Codex work.

## Recommended Next Build Order

1. Build `usl-command-dashboard/`.
2. Build `opportunity-tracker/`.
3. Build `sar-system/`.
4. Add mobile capture and daily status export.
5. Add GitHub Pages deployment docs.
