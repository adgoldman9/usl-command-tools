# SAR / ESA / RPPOB Tracker

Browser-based workflow tracker for NSN parts moving through ESA concurrence, SAR package preparation, RPPOB status, CSI screening, technical-data review, and quoteability decisions.

## What It Does

- Adds, edits, and deletes SAR / ESA part records.
- Tracks NSN, NIIN, FSC, part type, part name, AMC/AMSC, CSI status, RPPOB status, ESA status, ESA submission date, SAR category, SAR status, technical-data source, cFolders status, NSNLookup status, drawing status, engineering review, manufacturing review, supplier candidate, quoteability status, next action, follow-up cadence, and notes.
- Filters by ESA status, SAR status, and CSI status.
- Searches by record ID, NSN, NIIN, part, supplier, quoteability, next action, and notes.
- Exports all records to CSV.
- Generates a printable record summary.
- Saves records in browser localStorage.
- Shows desktop table view and mobile card view.

## How To Open

Open `index.html` directly in a browser, or use the GitHub Pages route:

```text
https://adgoldman9.github.io/usl-command-tools/sar-system/
```

## Data Note

This is a static browser tool. Records are stored only in the current browser localStorage unless exported to CSV. Do not put private USL data into public sample files or the GitHub repository.
