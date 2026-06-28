# Agent Conversation Archive Consolidation

`tools/consolidate-agent-conversations.ps1` consolidates locally available
ChatGPT, Codex, Claude, and Claude Code conversation exports, handoffs, and
archive files into the USL AI Operating System as a controlled local archive.

This is a **local, copy-first, non-destructive** file organization tool. It does
not move, delete, or modify originals; it performs no external actions, uploads,
links, or API calls; and it skips anything that looks like a secret or credential.

> **Where it runs:** on the Windows machine that holds the files (the USL AI
> Operating System lives under `C:\Users\motor\OneDrive\Documents\`). It cannot run
> in a cloud container or on a machine without access to those local paths.

## What it does (phases)

0. **Preflight** — confirms the USL OS root exists, creates the archive root and
   subfolders, and excludes the archive root from discovery (self-copy guard).
1. **Discovery** — searches Downloads, Documents, OneDrive\Documents,
   OneDrive\Desktop, and Desktop for files whose path/name contains conversation
   keywords (ChatGPT, OpenAI, Codex, Claude, Anthropic, Cowork, conversation,
   handoff, …) with allowed extensions (`.md .txt .json .jsonl .csv .html .pdf
   .docx .xlsx .zip`). Excludes caches, config, and credential folders.
2. **Manifests** — writes `conversation_archive_manifest.csv` and `.json`.
3. **Categorization** — ChatGPT / Codex / Claude / Claude_Code / Raw_Exports /
   Unknown_AI_Conversation.
4. **Collision handling** — same name, different content → safe suffix
   `name__from_<parent>.<ext>`; never overwrites a different-content file.
5. **Duplicate handling** — identical SHA256 → one primary copy; others recorded
   as `DUPLICATE_SKIPPED`.
6. **Copy + verify** — copies into category folders and verifies source SHA256 ==
   destination SHA256.
7. **Safety checks** — confirms no originals deleted/moved, archive root excluded,
   credential/cache folders excluded.
8. **Reports** — migration report, duplicates report, skipped-items report.

## Archive layout

```text
USL_AI_Operating_System\10_Agent_Operating_Model\agent_conversation_archive\
  ChatGPT\  Codex\  Claude\  Claude_Code\  Raw_Exports\  Unknown_AI_Conversation\
  Manifests\          conversation_archive_manifest.csv / .json
  Migration_Reports\  conversation_archive_migration_report.md
                      conversation_archive_duplicates_report.md
                      conversation_archive_skipped_items.md
```

## How to run

Always dry-run first to review discovery without copying:

```powershell
powershell -ExecutionPolicy Bypass -File tools\consolidate-agent-conversations.ps1 -DryRun
```

Review `Manifests\conversation_archive_manifest.csv` and the migration report,
then perform the copy:

```powershell
powershell -ExecutionPolicy Bypass -File tools\consolidate-agent-conversations.ps1
```

Optional overrides:

```powershell
# Different USL OS root or extra source folders
... -UslOsRoot "D:\USL_AI_Operating_System" -SourceRoots "C:\Users\me\Downloads","E:\exports"
```

## Safety guarantees

- Copy-first: originals are never moved, deleted, or modified.
- Files matching secret/credential names, extensions, or content patterns
  (`API_KEY`, `TOKEN`, `PRIVATE KEY`, `CLIENT_SECRET`, MFA/recovery codes, etc.)
  are **skipped** and listed in the skipped-items report — never copied.
- The archive root is excluded from discovery so the archive cannot copy itself.
- Cache, config, and credential folders (`AppData`, `.git`, `.ssh`, `.gnupg`,
  `node_modules`, `.venv`, …) are excluded.

## After it runs

Review the manifest and migration report **before** any destructive move, delete,
or cleanup task. Record an entry in the USL AI Operating System's own context/log
if you keep one there, mirroring this repo's handoff convention.
