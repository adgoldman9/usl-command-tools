# USL Codex Prompt Library

Use these prompts from Codex after opening:

`C:\Users\motor\OneDrive\Desktop\USL_Command_Center\07_Codex_Builds\usl-command-tools`

## Prompt 1 - Initialize The USL Repo

```text
Initialize this repository as the USL command tools repo.

Create or update the following structure:

/AGENTS.md
/README.md
/sar-system/
/opportunity-tracker/
/nsn-review-dashboard/
/supplier-outreach-tools/
/usl-command-dashboard/
/docs/

Create placeholder README.md files inside each major folder explaining the purpose of that module.

Use the AGENTS.md instructions already provided. If AGENTS.md is missing, create one using the USL Codex Operating Instructions.

Do not add unnecessary dependencies.

After completion, provide a CODEX HANDOFF SUMMARY with:
- Files created
- Folder structure
- How to verify locally
- Recommended next build task
```

## Prompt 2 - Build The USL Command Dashboard

```text
Build a browser-based USL Command Dashboard in /usl-command-dashboard.

Goal:
Create a mobile-friendly and desktop-friendly HTML/CSS/JS dashboard that organizes USL work into active lanes.

Required lanes:
1. Daily Command / Agenda
2. Opportunity Intake
3. Supplier & Apollo Outreach
4. SAR / ESA / RPPOB
5. SBIR / AFWERX
6. USL Software / CAD Platform
7. Website / Marketing / Pitch
8. Codex Builds

Each lane should include:
- Current status
- Priority level
- Next action
- Owner / responsible party
- Due date
- Notes
- Status tag: Active, Waiting, Parked, Completed

Required features:
- Add new task
- Edit task
- Delete task
- Filter by lane
- Filter by status
- Export to CSV
- Save/load using browser localStorage
- Mobile-friendly layout

Files to create:
- /usl-command-dashboard/index.html
- /usl-command-dashboard/styles.css
- /usl-command-dashboard/app.js
- /usl-command-dashboard/README.md

Acceptance criteria:
- Opens locally in a browser
- Can add/edit/delete records
- Can export CSV
- Saves data in localStorage
- Works on mobile width and desktop width

Do not use external libraries unless necessary.

Provide a CODEX HANDOFF SUMMARY at the end.
```

## Prompt 3 - Build The Opportunity Tracker

```text
Build the USL Opportunity Tracker in /opportunity-tracker.

Goal:
Create a browser-based tracker for SAM.gov, DIBBS, LRAF, NSN, and defense hardware opportunities.

Required fields:
- Opportunity ID
- Source: SAM.gov, DIBBS, LRAF, Email, Manual
- Notice ID
- Solicitation number
- NSN
- NIIN
- FSC
- Part name
- Agency
- Buyer / Contracting Officer
- Due date
- AMC
- AMSC
- CSI status
- Technical data source: cFolders, NSNLookup, Standard Spec, Reverse Engineering, Unknown
- TDP status
- Supplier status
- Decision: Pursue, Hold, Skip, Parked
- Priority: High, Medium, Low
- Next action
- Follow-up date
- Notes

Required features:
- Add/edit/delete opportunity
- Search by NSN, NIIN, Notice ID, part name, or agency
- Filter by decision
- Filter by priority
- Filter by source
- Export CSV
- Import CSV if practical
- Save/load using localStorage
- Mobile-friendly card view
- Desktop table view

Files:
- /opportunity-tracker/index.html
- /opportunity-tracker/styles.css
- /opportunity-tracker/app.js
- /opportunity-tracker/README.md

Acceptance criteria:
- User can enter NSN-driven opportunity records
- User can mark pursue/hold/skip/parked
- User can export records to CSV
- Tool works locally without a server
- Layout works on mobile and desktop

Provide a CODEX HANDOFF SUMMARY.
```

## Prompt 4 - Build The SAR / ESA Tracker

```text
Build the USL SAR / ESA / RPPOB tracker in /sar-system.

Goal:
Create a browser-based workflow tracker for NSN parts moving through ESA concurrence and SAR package preparation.

Required fields:
- Record ID
- NSN
- NIIN
- FSC
- Part type
- Part name
- AMC
- AMSC
- CSI status
- RPPOB status
- ESA status: Not Submitted, Submitted, Waiting, Approved, Rejected, More Info Needed
- ESA submission date
- SAR category
- SAR status: Not Started, Drafting, Waiting Data, Ready for Review, Submitted, Approved, Rejected
- Technical data source
- cFolders status
- NSNLookup status
- Drawing status
- Manufacturing director review
- Engineering director review
- Supplier candidate
- Quoteability status
- Next action
- Follow-up cadence
- Notes

Required features:
- Add/edit/delete part record
- Filter by ESA status
- Filter by SAR status
- Filter by CSI status
- Export CSV
- Generate printable record summary
- Save/load using localStorage
- Mobile-friendly layout

Files:
- /sar-system/index.html
- /sar-system/styles.css
- /sar-system/app.js
- /sar-system/README.md

Acceptance criteria:
- User can manage ESA/SAR records
- User can produce a printable summary
- User can export CSV
- Tool works locally
- Works on mobile and desktop

Provide a CODEX HANDOFF SUMMARY.
```

## Handoff Format

```text
CODEX HANDOFF SUMMARY
- Task completed:
- Files changed:
- How to test:
- Remaining issues:
- Recommended next action:
```
