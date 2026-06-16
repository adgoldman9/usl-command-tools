# USL Command Tools Test Coverage Analysis

This document analyzes the current state of automated testing in the repo and
proposes prioritized areas to improve coverage. It complements
`function-test-checklist.md`, which covers manual end-to-end checks.

## Current State

- **No automated tests exist.** There is no `package.json`, no test runner, no
  `*.test.js` / `*.spec.js` files, and no CI workflow.
- The only existing testing artifact is `docs/function-test-checklist.md`, a
  manual click-through checklist that must be run by a human in a browser.
- Roughly **2,400 lines** of JavaScript carry real logic with no coverage:
  - `mobile-capture-inbox/app.js` (~722 lines)
  - `opportunity-tracker/app.js` (~576 lines)
  - `sar-system/app.js` (~505 lines)
  - `usl-command-dashboard/app.js` (~403 lines)
  - `apps-script/google-sheets-sync/Code.gs` (~183 lines)

## Key Obstacle: Code Is Not Structured for Testing

Each `app.js` executes top-level code on load that immediately touches
`document`, `crypto.randomUUID()`, and `localStorage` (for example
`mobile-capture-inbox/app.js:91-92` runs `loadItems()` then `initialize()` at
import time). The pure helper functions are **not exported**, so they cannot be
imported into a test without also booting the whole DOM-dependent module.

Before meaningful unit tests can be added, the pure logic should be made
importable. Two low-risk options:

1. Wrap each module so it only auto-initializes in a browser
   (e.g. `if (typeof document !== "undefined") initialize();`) and attach pure
   helpers to `module.exports` / `globalThis` when running under a test runner.
2. Extract shared pure helpers into a small `shared/` module (see "Duplication"
   below) that both the browser tools and tests import.

A lightweight setup (Vitest or Node's built-in `node:test` + jsdom) requires no
framework adoption beyond a single dev dependency and fits the repo's
"avoid unnecessary dependencies" standard.

## Highest-Value Areas to Test (Prioritized)

### 1. CSV parsing and escaping (highest risk, pure, reusable)

`parseCsv`, `csvEscape`, and `toCsv` are duplicated across modules and handle
the data that crosses device boundaries (phone -> desktop -> Google Sheets).
Bugs here silently corrupt user data. Test cases to add:

- Quoted fields containing commas, embedded newlines, and escaped `""` quotes.
- CRLF vs LF line endings (`parseCsv` handles `\r\n`, `\r`, `\n`).
- Trailing newline / empty trailing row handling.
- Round-trip property: `parseCsv(toCsv(records))` reproduces the original field
  values for `opportunity-tracker` and `mobile-capture-inbox` (the two modules
  with both export and import).
- Note the **export/import asymmetry**: `usl-command-dashboard` and
  `sar-system` export CSV but have no import path. A round-trip test documents
  and guards this gap.

### 2. CSV import field mapping and option validation

`rowToItem` / `rowToRecord` plus `ensureOption` and `normalizeHeader` decide how
imported rows map to fields and how invalid values fall back to defaults. Tests:

- Header normalization matches regardless of case/spacing/punctuation
  (`normalizeHeader("Due date") === normalizeHeader("DUE_DATE")`).
- Unknown enum values fall back correctly (e.g. a bad `decision` becomes
  `"Hold"`, bad `priority` becomes `"Medium"`).
- Missing columns produce empty strings rather than `undefined`.
- Reordered columns still map by header name, not position.

### 3. Deduplication and merge logic (mobile-capture-inbox)

`dedupeItems`, `duplicateKey`, `chooseBetterDuplicate`, `duplicateScore`,
`isDemoItem`, and `mergeItemsById` are the most intricate logic in the repo and
directly affect whether sync loses or duplicates user records. Tests:

- Two records with the same `duplicateKey` collapse to one; the
  more-complete / non-demo record wins.
- `mergeItemsById` overwrites local with incoming when `id` matches and unions
  otherwise.
- `isDemoItem` correctly flags the seed/sample records and not real ones.
- `normalizeDateKey` collapses equivalent date representations.

### 4. Sorting and "due soon" / date logic (time-dependent)

`sortItems` / `sortRecords` / `sortByPriorityAndDueDate`, `isDueSoon`,
`formatDate`, and `nextDate` depend on the system clock and timezone. These need
deterministic tests with a fixed/faked clock:

- `isDueSoon` boundaries: today (0 days), +7 days, +8 days, past dates, empty.
- Sort ordering by priority, then decision/status, then due date, including
  records with missing fields (the `?? 9` and `"9999-12-31"` fallbacks).
- `formatDate` returns "No date" for empty and echoes invalid input unchanged.

### 5. Capture-type inference (mobile-capture-inbox)

`inferLane`, `inferPriority`, and `inferNextAction` drive Quick Add automation
(checklist line: "Quick Add infers lane, priority, next action, and status").
Simple table-driven tests should assert every capture type maps to the expected
lane/priority/next-action and that unknown types hit the documented defaults.

### 6. HTML escaping (security)

`escapeHtml` is the primary XSS defense — record fields are injected via
`innerHTML` in `renderTable` and the pill/select builders. Tests should confirm
`<`, `>`, `&`, `"`, and `'` are all encoded, and that escaping is actually
applied on every `innerHTML` sink. This guards against a malicious CSV import
injecting markup.

### 7. Apps Script backend (`Code.gs`)

Currently untestable as written (depends on `SpreadsheetApp`, `ContentService`,
etc.), but two pieces are security/data critical:

- `sanitizeCallback` — prevents JSONP callback injection. It is a pure regex
  function and should be unit tested directly (valid identifiers pass; values
  with parentheses, semicolons, spaces, or script payloads are rejected).
- `upsertRecords_` merge-by-id and `readRecords_` date formatting — extract the
  row<->record mapping into pure helpers so they can be tested without the
  Spreadsheet service via lightweight stubs.

## Cross-Cutting Recommendation: De-Duplicate Shared Helpers

`parseCsv`, `csvEscape`, `toCsv`, `ensureOption`, `normalizeHeader`, `slug`,
`escapeHtml`, and `formatDate` are copy-pasted across modules **with subtle
differences** — e.g. `usl-command-dashboard`'s `csvEscape` always quotes every
field, while the others quote only when needed. These divergences are exactly
the kind of bug tests catch. Extracting one shared, tested module removes the
drift and gives every tool the same verified behavior for free.

## Suggested Rollout

1. Add a minimal dev setup (`package.json` + Vitest or `node:test` + jsdom) and
   a CI workflow that runs on push.
2. Make pure helpers importable (export from modules or extract to `shared/`).
3. Land tests in priority order above, starting with CSV (#1, #2) and dedupe
   (#3) since those protect user data during sync.
4. Keep `function-test-checklist.md` for manual UI/mobile-layout verification
   that unit tests cannot cover (touch targets, responsive layout, print flow).

## What Unit Tests Will Not Cover

Mobile/desktop responsive layout, tap-target sizing, the browser print flow,
`<dialog>` modal behavior, real Google Sheets sync round-trips, and GitHub Pages
link integrity remain manual-checklist items.
</content>
</invoke>
