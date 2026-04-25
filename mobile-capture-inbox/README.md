# Mobile Capture Inbox

Mobile-first inbox for capturing USL work from the field before it becomes scattered across chats, screenshots, email, and memory.

## What It Does

- Quickly captures CHATGPT TASK, CODEX TASK, FILE TASK, WAITING, OPPORTUNITY, SUPPLIER LEAD, NSN REVIEW, and FOLLOW-UP items.
- Assigns priority, lane, status, source, next action, and notes.
- Infers a sensible lane and next action for quick captures.
- Marks items as routed.
- Filters by type, status, and lane.
- Searches across title, description, source, lane, next action, and notes.
- Exports CSV for backup or desktop handoff.
- Imports CSV for manual phone-to-desktop sync.
- Supports optional Google Sheets / Apps Script sync beta.
- Saves records in browser localStorage.

## How To Open

```text
https://adgoldman9.github.io/usl-command-tools/mobile-capture-inbox/
```

## Manual Sync Workflow

Because this static GitHub Pages tool uses browser localStorage, phone and desktop records do not automatically sync.

Use this manual workflow first:

1. Capture items on phone.
2. Export CSV from phone browser.
3. Move CSV through email, Google Drive, or local file transfer.
4. Open the desktop browser version.
5. Import CSV.
6. Mark imported items as routed after they are moved into the right tracker or agenda.

## Google Sheets Sync Beta

For shared phone-to-desktop sync, deploy the Apps Script template at:

```text
apps-script/google-sheets-sync/Code.gs
```

Then paste the deployed Web App URL into the sync panel in this tool.

The sync beta can:

- Push all local capture items to Google Sheets.
- Pull sheet rows back into local browser storage.
- Keep localStorage as the offline working copy.

## Data Note

Do not commit private USL records to GitHub. This tool stores working records in the browser only unless you export CSV.
