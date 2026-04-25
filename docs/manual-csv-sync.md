# Manual CSV Sync Workflow

The USL command tools are static GitHub Pages apps. Each browser stores records in its own localStorage, so phone and desktop data do not automatically sync yet.

## Recommended Phase 1 Sync

Use CSV as the safe manual bridge:

1. Export CSV from the phone tool.
2. Save the file to Google Drive, email it to yourself, or move it locally.
3. Open the matching desktop tool.
4. Import the CSV if that module supports import, or keep the CSV as the handoff record.
5. Mark items routed after they are copied into the correct tracker.

## Tools With CSV Export

- USL Command Dashboard
- Opportunity Tracker
- SAR / ESA / RPPOB Tracker
- Mobile Capture Inbox

## Tools With CSV Import

- Opportunity Tracker
- Mobile Capture Inbox

## Do Not Commit Private Data

GitHub Pages should host tool interfaces only. Keep real supplier records, pricing, proposal drafts, customer details, and private operational data in browser storage, exported CSV files, Google Drive, or a future authenticated backend.

## Future Sync Options

- Google Sheets manual CSV import/export
- Google Apps Script bridge
- Supabase or Firebase authenticated backend
- GitHub JSON data files for low-volume versioned records
