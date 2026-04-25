# USL Command Dashboard

Daily command dashboard for active USL lanes, mobile capture routing, Codex build status, follow-ups, and next actions.

## Files

- `index.html` - browser entry point.
- `styles.css` - responsive dashboard styling.
- `app.js` - task storage, filters, add/edit/delete, and CSV export.

## How To Open

Open `index.html` directly in Chrome or another modern browser.

No server, install step, or external dependency is required.

## Features

- Add new task records.
- Edit existing task records.
- Delete records after confirmation.
- Filter by lane.
- Filter by status.
- Search title, owner, status, next action, notes, lane, status, and priority.
- Export the currently filtered view to CSV.
- Save and load records using browser localStorage.
- Mobile-friendly single-column layout.
- Desktop lane-board layout.

## Lanes

- Daily Command / Agenda
- Opportunity Intake
- Supplier & Apollo Outreach
- SAR / ESA / RPPOB
- SBIR / AFWERX
- USL Software / CAD Platform
- Website / Marketing / Pitch
- Codex Builds

## Data Storage

Records are stored locally in the browser under:

`usl-command-dashboard.tasks.v1`

Data stays on the local machine unless manually exported or copied elsewhere.

## Testing Checklist

- Open `index.html`.
- Add a new record.
- Edit the record.
- Delete a record.
- Filter by lane and status.
- Export CSV and confirm the file downloads.
- Resize to mobile width and confirm the layout remains usable.
