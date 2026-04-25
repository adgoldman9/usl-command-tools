# Google Sheets Sync Bridge

This is the first shared-backend upgrade path for the USL command tools.

Current production behavior remains:

```text
GitHub Pages + localStorage + CSV export/import
```

The sync bridge adds:

```text
GitHub Pages + localStorage + optional Google Sheets / Apps Script sync
```

## Current Supported Tool

- Mobile Capture Inbox

## Why Mobile Capture First

Mobile Capture Inbox is the field command console. It is the best first sync target because phone-captured work should appear on desktop without manually rebuilding the context.

## Setup Summary

1. Create a Google Sheet.
2. Add the Apps Script file from:

```text
apps-script/google-sheets-sync/Code.gs
```

3. Run `setupUSLSyncSheet`.
4. Deploy the Apps Script as a web app.
5. Copy the web app URL.
6. Paste it into the Mobile Capture Inbox sync panel.
7. Use **Push Local to Sheet** and **Pull Sheet to Local**.

## Important Security Notes

- Do not commit real USL records to GitHub.
- Do not commit Apps Script deployment URLs if you consider them sensitive.
- Do not place private supplier data, pricing, customer records, or credentials in public repo files.
- If the web app is deployed to anyone with the link, treat the URL as sensitive.

## Sync Behavior

- Local browser records remain the working offline copy.
- Push sends all current Mobile Capture Inbox records to Google Sheets.
- Pull merges Google Sheets records into local browser storage by `id`.
- If the same `id` exists locally and in the sheet, the pulled sheet version replaces the local version.

## Known Limitations

- Delete sync is not implemented yet.
- Conflict resolution is simple last-pull-wins by `id`.
- Only Mobile Capture Inbox is wired in this first bridge.
- Opportunity Tracker, SAR / ESA Tracker, and Dashboard can be added after the bridge is validated.

## Recommended Next Phase

After this bridge is validated:

1. Add sync support to Opportunity Tracker.
2. Add sync support to SAR / ESA Tracker.
3. Add a Daily Status Exporter that can read from shared sheets.
4. Revisit authentication if the tools begin carrying sensitive operational data.
