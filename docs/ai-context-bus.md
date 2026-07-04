# USL AI Context Bus

The master operating solution for syncing **usable context** across Claude
Desktop, Claude mobile, Claude Code / Cowork, ChatGPT, Codex, local repos, Google
Drive, and USL project memory.

This replaces the idea of "make all the AI apps share one native memory." They do
not, and they will not. Instead, USL keeps **one repo-backed, Drive-backed,
human-readable file system** that every tool reads from and writes back to.

## The Problem

- Native chat memories **do not fully sync across vendors.**
- **Claude memory is not ChatGPT memory.**
- **ChatGPT memory is not Claude / Codex memory.**
- **Mobile app chats are not the system of record.**
- Each vendor's memory is controlled *inside that vendor* and never becomes
  another vendor's memory.

ChatGPT Projects keep chats, files, and instructions together and let you switch
devices inside ChatGPT. ChatGPT memory can reference past chats, files, and
connected apps when enabled — but only inside ChatGPT. Claude Code supports
persistent instructions via `CLAUDE.md`, auto memory, web/mobile handoff, and MCP
connectors — but only inside Claude's operating layer. None of these is a
universal cross-vendor memory.

If chat history is treated as the source of truth, context fragments across
vendors and devices and is repeatedly rebuilt by hand.

## Target Architecture

```text
USL Command Center / AI Context Bus
│
├── GitHub repo        = canonical text / history layer
├── Google Drive       = canonical file / artifact layer
├── ChatGPT Project    = reasoning + planning workspace
├── Claude Desktop/Mobile/Code = implementation + PR workspace
├── Codex              = repo patch / testing workspace
└── local CRM/CAD repos = execution systems, not memory systems
```

The key move: **stop relying on chat history as the source of truth.** Chats
become working sessions. The repo / Drive context files become the memory.

## Source-of-Truth Hierarchy

In order. When two sources disagree, the higher one wins.

1. **CRM / database** — structured project state (phases, gates, records).
2. **Git repo context files** — memory, instructions, SOPs, task state, and
   session handoffs (`context/`, `AGENTS.md`, `CLAUDE.md`, `docs/`).
3. **Google Drive** — larger artifacts: PDFs, exports, proposal files, drawings
   that are cleared for storage.
4. **ChatGPT / Claude / Codex chats** — working sessions only. Never the system
   of record.

## What Syncs Natively (and stays inside one vendor)

| Inside one vendor | Syncs across that vendor's devices | Crosses vendors |
| --- | --- | --- |
| Claude chats / memory / Project files | Yes (same Anthropic account) | No |
| ChatGPT chats / memory / Project files | Yes (same OpenAI account) | No |
| Codex repo session state | Via the repo / git | Only through the repo |
| Claude Code / Cowork sessions | Yes (account-bound, cloud-run) | Only through the repo |

See [`claude-app-sync.md`](claude-app-sync.md) for the Claude-internal detail and
[`ai-platform-sync-matrix.md`](ai-platform-sync-matrix.md) for the full matrix.

## What Does Not Sync Natively

- Memory or instructions from one vendor into another vendor.
- Local files on a phone or computer into any vendor (Claude/ChatGPT can read
  connected cloud drives, not your raw local disk).
- "Release readiness" or approval state — that lives in the CRM and the repo, not
  in any chat.

## Why Repo-Backed Context Is Required

Because the only layer all of these tools can read and write **in common** is a
git repository (text/history) plus a connected cloud drive (artifacts). A
human-readable file in the repo is the lowest common denominator every platform
already supports. That is the bus.

## What Each Platform Should Read

Every platform, at the start of meaningful work, reads:

- `context/USL_CONTEXT_SNAPSHOT.md` — current posture and status.
- `context/USL_ACTIVE_TASKS.md` — what is in flight.
- The latest file in `context/handoffs/` — the last session's handoff.
- Its own instruction file:
  - Claude → `CLAUDE.md` (which imports `AGENTS.md`)
  - ChatGPT → `.chatgpt/USL_PROJECT_INSTRUCTIONS.md`
  - Codex → `.codex/USL_CODEX_INSTRUCTIONS.md`
  - All coding agents → `AGENTS.md`

## What Each Platform Should Write Back

After meaningful work, every platform writes:

- A handoff file in `context/handoffs/` (format in that folder's `README.md`).
- Decisions into `context/USL_MEMORY_LEDGER.md`.
- New/changed artifacts into `context/USL_FILE_INDEX.md`.
- Task changes into `context/USL_ACTIVE_TASKS.md`.

Then run `scripts/build_context_snapshot.py` and `scripts/validate_context_bus.py`,
commit, and push.

## Operating Rule

**No AI chat is the system of record.**

System of record:

1. GitHub repo — text, instructions, logs, SOPs, task state.
2. Google Drive — larger documents, PDFs, exports, proposal files.
3. CRM SQLite / app — structured project tracking.
4. ChatGPT / Claude / Codex chats — temporary execution surfaces only.

## Security Posture

- No secrets, API keys, tokens, passwords, or recovery codes in context files.
- No CUI, ITAR, drawings, TDP, or supplier-restricted data in any AI tool or repo
  file. Google Drive stores only artifacts cleared for storage.
- Release readiness is never inferred by an AI tool — it is gated by human
  approval (see `AGENTS.md`).

## Related Docs

- [`ai-context-bus-sop.md`](ai-context-bus-sop.md) — daily / weekly operating SOP.
- [`ai-platform-sync-matrix.md`](ai-platform-sync-matrix.md) — per-platform matrix.
- [`claude-app-sync.md`](claude-app-sync.md) — Claude-internal sync appendix.
