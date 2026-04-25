# USL Command Tools Function Test Checklist

Use this checklist after each meaningful tool update or before sharing the GitHub Pages site from a phone or desktop browser.

Test site:

```text
https://adgoldman9.github.io/usl-command-tools/
```

Tester:

Date:

Browser / device:

## Launch Page Links

- [ ] Pass / [ ] Fail - Launch page opens without a 404.
- [ ] Pass / [ ] Fail - USL Command Dashboard link opens.
- [ ] Pass / [ ] Fail - Opportunity Tracker link opens.
- [ ] Pass / [ ] Fail - SAR / ESA / RPPOB link opens.
- [ ] Pass / [ ] Fail - Mobile Capture Inbox link opens.
- [ ] Pass / [ ] Fail - NSN Review Dashboard placeholder link opens.
- [ ] Pass / [ ] Fail - Supplier Outreach Tools placeholder link opens.
- [ ] Pass / [ ] Fail - GitHub Pages Setup doc link opens.
- [ ] Pass / [ ] Fail - Manual CSV Sync doc link opens.

Notes:

## USL Command Dashboard

- [ ] Pass / [ ] Fail - Dashboard loads starter records.
- [ ] Pass / [ ] Fail - Add a new task.
- [ ] Pass / [ ] Fail - Edit the new task.
- [ ] Pass / [ ] Fail - Delete the new task.
- [ ] Pass / [ ] Fail - Filter by lane.
- [ ] Pass / [ ] Fail - Filter by status.
- [ ] Pass / [ ] Fail - Search filters visible records.
- [ ] Pass / [ ] Fail - Export CSV downloads a file.
- [ ] Pass / [ ] Fail - Import CSV is not available and this limitation is acceptable for now.

Notes:

## Opportunity Tracker

- [ ] Pass / [ ] Fail - Opportunity Tracker loads starter records.
- [ ] Pass / [ ] Fail - Add a new opportunity.
- [ ] Pass / [ ] Fail - Edit the new opportunity.
- [ ] Pass / [ ] Fail - Delete the new opportunity.
- [ ] Pass / [ ] Fail - Search by NSN, NIIN, notice ID, part name, or agency.
- [ ] Pass / [ ] Fail - Filter by decision.
- [ ] Pass / [ ] Fail - Filter by priority.
- [ ] Pass / [ ] Fail - Filter by source.
- [ ] Pass / [ ] Fail - Export CSV downloads a file.
- [ ] Pass / [ ] Fail - Import CSV from the exported header format.
- [ ] Pass / [ ] Fail - Imported row appears in the tracker.

Notes:

## SAR / ESA / RPPOB Tracker

- [ ] Pass / [ ] Fail - SAR / ESA Tracker loads starter records.
- [ ] Pass / [ ] Fail - Add a new part record.
- [ ] Pass / [ ] Fail - Edit the new part record.
- [ ] Pass / [ ] Fail - Delete the new part record.
- [ ] Pass / [ ] Fail - Filter by ESA status.
- [ ] Pass / [ ] Fail - Filter by SAR status.
- [ ] Pass / [ ] Fail - Filter by CSI status.
- [ ] Pass / [ ] Fail - Search by NSN, NIIN, part, supplier, or next action.
- [ ] Pass / [ ] Fail - Print Summary opens the browser print flow.
- [ ] Pass / [ ] Fail - Export CSV downloads a file.
- [ ] Pass / [ ] Fail - Import CSV is not available and this limitation is acceptable for now.

Notes:

## Mobile Capture Inbox

- [ ] Pass / [ ] Fail - Mobile Capture Inbox loads starter records.
- [ ] Pass / [ ] Fail - Quick Add captures a new item.
- [ ] Pass / [ ] Fail - Quick Add infers lane, priority, next action, and status.
- [ ] Pass / [ ] Fail - Edit the captured item.
- [ ] Pass / [ ] Fail - Mark item as routed.
- [ ] Pass / [ ] Fail - Delete a test capture item.
- [ ] Pass / [ ] Fail - Filter by capture type.
- [ ] Pass / [ ] Fail - Filter by status.
- [ ] Pass / [ ] Fail - Filter by lane.
- [ ] Pass / [ ] Fail - Search filters visible capture cards.
- [ ] Pass / [ ] Fail - Export CSV downloads a file.
- [ ] Pass / [ ] Fail - Import CSV from the exported header format.
- [ ] Pass / [ ] Fail - Imported item appears in the inbox.

Notes:

## Mobile Browser Test

- [ ] Pass / [ ] Fail - Launch page is readable on phone width.
- [ ] Pass / [ ] Fail - Tool cards stack cleanly on phone width.
- [ ] Pass / [ ] Fail - Mobile Capture Inbox quick form is usable without horizontal scrolling.
- [ ] Pass / [ ] Fail - Opportunity Tracker mobile cards are readable.
- [ ] Pass / [ ] Fail - SAR / ESA mobile cards are readable.
- [ ] Pass / [ ] Fail - Buttons are large enough to tap.
- [ ] Pass / [ ] Fail - Forms can be opened, filled, saved, and closed on mobile.
- [ ] Pass / [ ] Fail - No overlapping text or clipped controls.

Notes:

## Desktop Browser Test

- [ ] Pass / [ ] Fail - Launch page grid is readable on desktop.
- [ ] Pass / [ ] Fail - Dashboard board layout is readable.
- [ ] Pass / [ ] Fail - Opportunity Tracker desktop table is readable.
- [ ] Pass / [ ] Fail - SAR / ESA desktop table is readable.
- [ ] Pass / [ ] Fail - Mobile Capture Inbox cards are readable.
- [ ] Pass / [ ] Fail - Dialog forms fit on screen or scroll correctly.
- [ ] Pass / [ ] Fail - Export buttons trigger downloads.
- [ ] Pass / [ ] Fail - No broken links or missing scripts.

Notes:

## LocalStorage Persistence Test

- [ ] Pass / [ ] Fail - Add a test record in Dashboard, refresh, and confirm it remains.
- [ ] Pass / [ ] Fail - Add a test record in Opportunity Tracker, refresh, and confirm it remains.
- [ ] Pass / [ ] Fail - Add a test record in SAR / ESA Tracker, refresh, and confirm it remains.
- [ ] Pass / [ ] Fail - Add a test record in Mobile Capture Inbox, refresh, and confirm it remains.
- [ ] Pass / [ ] Fail - Delete test records after verification.
- [ ] Pass / [ ] Fail - Browser/device-local storage limitation is understood.

Notes:

## CSV Phone-To-Desktop Sync Test

- [ ] Pass / [ ] Fail - On phone, add a Mobile Capture Inbox test item.
- [ ] Pass / [ ] Fail - On phone, export Mobile Capture CSV.
- [ ] Pass / [ ] Fail - Move CSV to desktop through email, Google Drive, or local transfer.
- [ ] Pass / [ ] Fail - On desktop, open Mobile Capture Inbox.
- [ ] Pass / [ ] Fail - Import the phone CSV on desktop.
- [ ] Pass / [ ] Fail - Confirm imported item appears on desktop.
- [ ] Pass / [ ] Fail - Mark imported item as routed.
- [ ] Pass / [ ] Fail - Repeat with Opportunity Tracker CSV if needed.

Notes:

## Google Sheets Sync Beta Test

- [ ] Pass / [ ] Fail - Create or open the USL sync Google Sheet.
- [ ] Pass / [ ] Fail - Add `apps-script/google-sheets-sync/Code.gs` to the bound Apps Script project.
- [ ] Pass / [ ] Fail - Run `setupUSLSyncSheet` and approve permissions.
- [ ] Pass / [ ] Fail - Deploy Apps Script as a web app.
- [ ] Pass / [ ] Fail - Paste the Web App URL into Mobile Capture Inbox.
- [ ] Pass / [ ] Fail - Save URL and confirm the local sync status updates.
- [ ] Pass / [ ] Fail - Push local Mobile Capture records to Google Sheets.
- [ ] Pass / [ ] Fail - Confirm records appear in the `Mobile_Capture` sheet.
- [ ] Pass / [ ] Fail - Pull sheet records into a different browser or device.
- [ ] Pass / [ ] Fail - Confirm pulled records merge into localStorage by `id`.
- [ ] Pass / [ ] Fail - Confirm CSV export/import still works after sync.
- [ ] Pass / [ ] Fail - Confirm no Apps Script Web App URL or private record data is committed to GitHub.

Notes:

## Final Disposition

- [ ] Pass / [ ] Fail - All critical workflows passed.
- [ ] Pass / [ ] Fail - Known limitations documented.
- [ ] Pass / [ ] Fail - Test records cleaned up or intentionally retained.
- [ ] Pass / [ ] Fail - Ready for next Codex build task.

Summary:

Issues found:

Recommended next action:
