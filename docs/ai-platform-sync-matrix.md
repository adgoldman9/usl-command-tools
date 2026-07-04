# USL AI Platform Sync Matrix

How each platform behaves in the USL AI Context Bus: what it syncs natively,
whether it reads/writes repo context, what it is good for, what it is not safe
for, and the USL rule for it.

Read [`ai-context-bus.md`](ai-context-bus.md) first. The short version: **native
memory never crosses vendors; the repo context files are the shared memory.**

| Platform | Native sync behavior | Reads repo context? | Writes repo context? | Good for | Not safe for | USL rule |
| --- | --- | --- | --- | --- | --- | --- |
| **ChatGPT web/mobile** | Chats + memory sync across the user's OpenAI account devices; stays inside ChatGPT | No (manual paste/upload) | No (manual paste of output back) | Reasoning, drafting, planning | System of record; controlled data; release decisions | Working session only; paste snapshot in, paste handoff out |
| **ChatGPT Projects** | Keeps chats/files/instructions together, syncs across devices inside ChatGPT | No (upload context files) | No (manual) | Persistent planning workspace | Cross-vendor memory; controlled data | Load `USL_CONTEXT_SNAPSHOT.md`, `USL_ACTIVE_TASKS.md`, `.chatgpt/USL_PROJECT_INSTRUCTIONS.md` |
| **Claude web/mobile** | Chats + memory + Project files sync across the user's Anthropic account devices | No (upload/connect) | No (manual) | On-the-go review, capture, light edits | System of record; controlled data | Same Anthropic account; treat as working session |
| **Claude Desktop** | Same account sync as Claude web/mobile; can read local files via connectors | Yes, when pointed at the repo / `context/` | Via Claude Code commits | Deeper review, file work, connectors | Cross-vendor memory; controlled data | Open repo root; read `AGENTS.md` + `CLAUDE.md` + `context/` |
| **Claude Code (Windows, local)** | Runs on `motor`'s Windows machine; local filesystem + PowerShell 7 access | Yes (reads repo directly) | Yes (commits; push after approval) | **Default daily driver** — Windows/PowerShell work, CRM, Phase folders, local builds/apps | Skipping the session-start status check | See `windows-claude-code-daily-driver.md`; run `tools\usl-status.ps1` first every session |
| **Claude Code / Cowork (cloud/container)** | Cloud-run, account-bound sessions; ephemeral containers, no Windows filesystem access | Yes (reads repo directly) | Yes (commits + PRs) | Repo-only fallback: docs, scripts, diffs, PR review | Touching the live USL AI OS, CRM, or Phase folders; treating the session as durable memory | Repo-readable work only; stop and hand off if asked for Windows-touching work |
| **Codex desktop/app** | Operates on the repo; state lives in git | Yes (reads repo) | Yes (patches + commits) | Repo patches, tests | External APIs without authorization; controlled folders | Read `AGENTS.md` + `.codex/USL_CODEX_INSTRUCTIONS.md`; write handoff |
| **GitHub** | Canonical text/history; syncs via git | Is the repo context | Is the repo context | System of record (text, instructions, tasks, SOPs, handoffs) | Storing secrets, CUI, ITAR, supplier-restricted data | Canonical text/history layer; no secrets or controlled data |
| **Google Drive** | Canonical artifact store; syncs via Drive clients/connectors | Indirectly (artifacts referenced by `USL_FILE_INDEX.md`) | No (artifact storage, not memory) | Large docs, PDFs, exports, proposal files | Being treated as memory; controlled/restricted data | Artifact storage only; never the memory layer |
| **Local CRM** | Local SQLite/app; not synced by AI tools | No | No | Structured project state (top of source-of-truth) | Mutation by AI tools | System of record for structured state; do not mutate from the bus |
| **Local CAD repo** | Local execution system; not memory | No | No | Execution / CAD work | AI upload of drawings/TDP; treating as memory | Execution system, not a memory system; controlled data stays out of AI tools |

## Reading the Matrix

- **Reads repo context? = No** means the platform needs the context **handed to
  it** (upload/paste) — it cannot pull from the repo on its own.
- **Writes repo context? = No / manual** means you must copy its output back into
  the repo (a handoff file, ledger entry, or commit). The bus only works if you
  close that loop.
- Platforms that read and write the repo directly (Claude Code/Cowork, Codex)
  keep the bus current automatically through commits; chat-only surfaces
  (ChatGPT, Claude mobile) require manual paste in and handoff out.

## The One Rule Behind Every Row

No platform's native memory crosses to another platform. Continuity comes from the
repo context files in `context/` plus the artifact store in Google Drive — not
from any vendor's chat history.
