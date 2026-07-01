# USL Shared AI Agent Operating Instructions

This is the **shared instruction file for every AI coding agent** that works on
USL (Claude Code, Codex, and any future agent). Claude loads it via `CLAUDE.md`
(`@AGENTS.md`); ChatGPT and Codex receive the same content through their project /
repo instruction files. Read it before doing work.

It sits on top of the **USL AI Context Bus** — see
[`docs/ai-context-bus.md`](docs/ai-context-bus.md). The bus is the operating model;
this file is the agent contract within it.

## Core Operating Rules

1. **Context-first.** Before answering or building, read the repo context:
   `context/USL_CONTEXT_SNAPSHOT.md`, `context/USL_ACTIVE_TASKS.md`, the latest
   file in `context/handoffs/`, and the relevant `docs/`. Do not rely on chat
   memory as the source of truth — native chat memory does not cross vendors.
2. **No secrets.** Never write API keys, tokens, passwords, client secrets, MFA
   or recovery codes, or credentials into any repo file, context file, or chat.
3. **No controlled files.** Never read into an AI tool, upload, or commit CUI,
   ITAR, drawings, TDP, cFolders content, supplier-restricted data, pricing, or
   Microsoft tenant secrets.
4. **No external release.** Do not publish, share externally, invite suppliers,
   send outbound messages, or push to public surfaces without explicit human
   approval.
5. **Human approval gates.** Treat release readiness, external sharing, supplier
   access, and publishing as gated. **Never mark anything release-ready without
   Andrew's approval.** An AI tool does not decide readiness.
6. **Write handoffs.** After meaningful work, write a handoff in
   `context/handoffs/` and update `context/USL_MEMORY_LEDGER.md`,
   `context/USL_FILE_INDEX.md`, and `context/USL_ACTIVE_TASKS.md` as applicable.
7. **Repo is memory, chat is a session.** The system of record is, in order: the
   CRM/database, then the repo context files, then Google Drive. Chats are
   temporary execution surfaces.

## Company Context

USL builds aerospace, defense, maritime, and weapons-system hardware workflows
focused on government contracting, defense logistics, supplier development,
SAR/ESA workflows, NSN-driven opportunity review, and future AI/CAD
infrastructure.

Primary business lanes:

- SAM.gov, DIBBS, LRAF, and NSN opportunity review
- SAR / ESA / RPPOB package support
- Supplier and manufacturer outreach
- SBIR / AFWERX proposal support
- USL internal software tools
- CAD / scan-to-model / bad-drawing-to-3D-model infrastructure

## Agent Role

Agents are responsible for code, scripts, dashboards, HTML tools, repo structure,
local file utilities, context-bus files, and documentation. Agents do **not** make
business decisions; they build tools and keep the context bus accurate so the
human workflow can decide.

## Project Standards

- Use simple, maintainable code. Prefer plain HTML, CSS, and JavaScript unless a
  framework is explicitly requested.
- Keep tools mobile-friendly and desktop-friendly. USL uses mobile throughout the
  day; desktop is used for deeper review and file work.
- Use clear file names. Add a README for every tool.
- Avoid unnecessary dependencies.
- Do not expose private USL business data in public-facing files.
- Do not hard-code sensitive information, API keys, passwords, CAGE codes, UEI,
  private emails, or supplier pricing.

## Required Output Standards

For every build task:

1. Summarize what changed.
2. List files created or modified.
3. Explain how to run or open the tool.
4. Identify remaining issues or limitations.
5. Write a short handoff (see `context/handoffs/README.md`).

## Testing

For browser tools: confirm the HTML opens locally, the mobile layout is usable,
forms add/edit/delete when applicable, and CSV/JSON export works when applicable.

For scripts: include usage instructions and sample input/output where practical.
Do not delete user data unless explicitly instructed.

## Data Categories

Common USL fields: Opportunity ID, Notice ID, Solicitation number, NSN, NIIN, FSC,
Part name, Agency, Buyer / Contracting Officer, Due date, AMC / AMSC, CSI status,
TDP / cFolders status, NSNLookup status, ESA status, SAR status, Supplier status,
Decision (Pursue / Hold / Skip / Parked), Next action, Follow-up date, Notes.

## Handoff Rule

When a task is complete, write a handoff file in `context/handoffs/` using the
format in that folder's `README.md`, and paste a matching summary back to the
human under:

```text
USL HANDOFF SUMMARY
- Task completed:
- Files changed:
- How to test:
- Remaining issues:
- Recommended next action:
```
