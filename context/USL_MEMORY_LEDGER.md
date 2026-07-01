# USL Memory Ledger

Structured, durable operating memory for USL. This is a system-of-record file
(below the CRM/database, above chat memory). Update it when decisions, gates, or
restrictions change. `scripts/build_context_snapshot.py` pulls sections of this
file into `USL_CONTEXT_SNAPSHOT.md`.

Keep it factual. No secrets, no controlled data.

## Company context

USL builds aerospace, defense, maritime, and weapons-system hardware workflows for
government contracting, defense logistics, supplier development, SAR/ESA workflows,
NSN-driven opportunity review, and future AI/CAD infrastructure. Mobile is used
throughout the day; desktop is used for deeper review and file work.

## Active systems

- USL Command Tools repo (this repo) — browser tools, dashboards, scripts, docs,
  and the AI Context Bus.
- Local CRM (SQLite/app) — structured project tracking; system of record for
  structured state.
- Google Drive — canonical artifact / large-file store (cleared artifacts only).
- AI platforms — Claude (web/mobile/desktop/Code/Cowork), ChatGPT (web/mobile/
  Projects), Codex — used as working sessions, not memory.
- Cerebras live integration — parked (see Parking lot).

## CRM/GCC gates

- CRM Phase 0 — PASS
- CRM Phase 1 — PASS
- CRM Phase 2A — PASS
- CRM Phase 2B — PASS
- CRM Phase 2C — authorized / pending (app/config loader alignment) unless later
  confirmed complete
- CRM Phase 2D — manual smoke test, pending
- GCC SharePoint / OneDrive external sharing remediation — pending

## AI-platform operating rules

- Native chat memory does not cross vendors. Claude memory is not ChatGPT memory;
  ChatGPT memory is not Claude/Codex memory.
- Mobile app chats are not the system of record.
- GitHub/repo text files are the canonical operating memory.
- Google Drive is the canonical large-file/artifact store, not memory.
- ChatGPT Projects, Claude Projects/Code, and Codex all consume the same repo
  context files (`context/`, `AGENTS.md`, `CLAUDE.md`, instruction files).
- Every session reads the snapshot + active tasks + latest handoff and writes a
  handoff back.

## Security restrictions

- Supplier access — blocked.
- Wix publishing — blocked.
- Controlled file release (CUI, ITAR, drawings, TDP, cFolders) — blocked.
- USL release posture — internal-only / blocked.
- No secrets, API keys, tokens, passwords, MFA/recovery codes, or client secrets
  in repo files, context files, chats, or Drive uploads.
- No controlled/restricted data uploaded to any AI tool.

## Human approval gates

- Release readiness — requires Andrew's approval; never inferred by an AI tool.
- External sharing / publishing — requires approval.
- Supplier invitations / outreach activation — requires approval.
- CRM database mutations and local CRM app code changes — out of scope for the AI
  Context Bus; require explicit human action.

## Parking lot

- Cerebras live integration — parked until prioritized.
- LLM provider abstraction design — planned (see active tasks).
- Additional tools (Opportunity Tracker, SAR/ESA Tracker) sync into the bus —
  after the bus is validated.
