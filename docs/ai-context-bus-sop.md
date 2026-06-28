# USL AI Context Bus — Operating SOP

Daily and weekly procedure for keeping the AI Context Bus accurate so every
platform (Claude, ChatGPT, Codex, mobile, desktop) reads the same canonical
context and writes session handoffs back into one place.

Read [`ai-context-bus.md`](ai-context-bus.md) first for the architecture and
source-of-truth hierarchy.

## Daily Start

1. Open `context/USL_CONTEXT_SNAPSHOT.md` — current posture and status.
2. Open `context/USL_ACTIVE_TASKS.md` — what is in flight.
3. Load the latest handoff from `context/handoffs/` (most recent dated file).
4. Confirm **no controlled files or secrets** are being copied into any AI tool:
   no CUI, ITAR, drawings, TDP, supplier-restricted data, tenant secrets, API
   keys, tokens, passwords, or recovery codes.

## During Work

- Each AI session must write a **handoff summary** (see
  `context/handoffs/README.md` for the format).
- **Decisions** go into `context/USL_MEMORY_LEDGER.md`.
- **Files / artifacts** go into `context/USL_FILE_INDEX.md`.
- **Active tasks** go into `context/USL_ACTIVE_TASKS.md`.
- Treat the repo context files as the source of truth. If a chat and the repo
  disagree, the repo wins (below the CRM/database).
- Never mark anything release-ready inside a chat — that is a human approval gate.

## Daily Close

1. Run `python scripts/build_context_snapshot.py` to regenerate
   `context/USL_CONTEXT_SNAPSHOT.md` from the ledger, active tasks, file index,
   and latest handoff.
2. Run `python scripts/validate_context_bus.py` and confirm **PASS**.
3. Write the day's handoff into `context/handoffs/` if not already done.
4. Commit the updated context files.
5. Push the branch / open or update a PR if appropriate.

On Windows, steps 1–2 are wrapped by `tools/export-usl-context.ps1`.

## Weekly Review

1. Reconcile `context/USL_ACTIVE_TASKS.md` against the CRM — close finished tasks,
   add new ones, re-prioritize.
2. Review the **Parking lot** in `context/USL_MEMORY_LEDGER.md` — promote or
   retire parked items.
3. Audit `context/USL_FILE_INDEX.md` — confirm sensitivity and "safe for AI
   upload?" flags are still correct.
4. Confirm `context/USL_CONTEXT_SNAPSHOT.md` reflects reality after running the
   build script.
5. Run `python scripts/validate_context_bus.py` and resolve any FAIL.

## New Session, Any Platform

When starting work on a new platform (ChatGPT, Claude, Codex), point it at:

- Its instruction file (`CLAUDE.md` / `.chatgpt/USL_PROJECT_INSTRUCTIONS.md` /
  `.codex/USL_CODEX_INSTRUCTIONS.md`), plus `AGENTS.md`.
- `context/USL_CONTEXT_SNAPSHOT.md` and `context/USL_ACTIVE_TASKS.md`.
- The latest handoff in `context/handoffs/`.

End every session by writing a handoff and updating the ledger/tasks/file index.

## Guardrails (always)

- No AI chat is the system of record.
- No secrets or controlled data in repo context files, chats, or Drive uploads.
- No external release, supplier invite, or publish action without human approval.
- Do not mutate the CRM database or local CRM app code from this bus.
