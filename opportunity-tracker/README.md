# Opportunity Tracker

Browser-based tracker for SAM.gov, DIBBS, LRAF, email, manual, NSN, and defense hardware opportunities.

## What It Does

- Adds, edits, and deletes opportunity records.
- Tracks NSN, NIIN, FSC, notice ID, solicitation number, agency, buyer, AMC/AMSC, CSI status, technical-data source, TDP status, supplier status, decision, priority, next action, follow-up date, and notes.
- Searches by NSN, NIIN, notice ID, part name, agency, buyer, next action, or notes.
- Filters by decision, priority, and source.
- Exports records to CSV.
- Imports CSV files that use the exported header format.
- Saves records in browser localStorage.
- Shows desktop table view and mobile card view.

## How To Open

Open `index.html` directly in a browser, or use the GitHub Pages route:

```text
https://adgoldman9.github.io/usl-command-tools/opportunity-tracker/
```

## Data Note

This is a static browser tool. Records are stored only in the current browser localStorage unless exported to CSV. Do not put private USL data into public sample files or the GitHub repository.

## Suggested Workflow

1. Add a new opportunity from SAM.gov, DIBBS, LRAF, email, or manual research.
2. Search and screen the NSN / NIIN.
3. Set a pursue, hold, skip, or parked decision.
4. Capture missing TDP, CSI, supplier, and next-action details.
5. Export CSV for backup or handoff.
