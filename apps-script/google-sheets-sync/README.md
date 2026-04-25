# Google Sheets Sync Apps Script

This Apps Script template creates a lightweight Google Sheets bridge for the USL static GitHub Pages tools.

## Current Scope

The first supported module is:

- Mobile Capture Inbox

## Setup

1. Create a Google Sheet for USL command tool sync.
2. Open **Extensions -> Apps Script**.
3. Paste `Code.gs` into the Apps Script editor.
4. Run `setupUSLSyncSheet` once and approve permissions.
5. Deploy as a web app.
6. Set access according to your operating preference.
7. Copy the web app URL.
8. Paste the URL into the Mobile Capture Inbox **Google Sheets Sync Beta** panel.

## Security Note

Do not put private credentials or API keys in this repo. If the web app is deployed with broad access, anyone with the URL may be able to interact with the sheet. Treat the URL as operationally sensitive.

## Browser Pattern

The static web app uses:

- JSONP for reading shared rows.
- Hidden form POST for writing rows.

This avoids CORS issues commonly encountered when static GitHub Pages tools call Apps Script directly.
