# Phase 1B Compatibility Patch — Recovery Needed

**Status:** The Windows Phase 1B run reportedly succeeded (script emitted
`USL_OS_PHASE_1B_CROSS_SOURCE_INVENTORY_OVERLAY_COMPLETE__DESTRUCTIVE_CLEANUP_GATE_LOCKED`),
but the **PowerShell compatibility patch that made it run is not recoverable from
the current git state.** It was applied to the local Windows working tree and was
never committed or pushed.

This note does not invent the patch. It records the gap and how to reconstruct it.

## Git state reconciliation (verified in this session)

- Branch: `claude/saved-memory-sync-access-kukbtk`
- HEAD: `36b19fd` (handoff path-correction; **local only, not pushed**)
- origin/…: `688995e`
- `git diff -- tools/usl-phase1b-cross-source-overlay.ps1`: **empty**
- `git diff --stat`: **empty** (clean working tree)
- `36b19fd` touches only `context/USL_CONTEXT_SNAPSHOT.md` and
  `context/handoffs/2026-06-28-usl-os-phase1b-run-STOP-handoff.md` — **not** the
  script.

Conclusion: neither the committed history, the index, nor the working tree in this
repo contains the compatibility patch. The script present here is the original
un-patched version from `88c2710`.

## Why it failed (the syntax locations to reconstruct)

The script uses `if` as an inline expression **inside `[pscustomobject]@{ … }`
hashtable literals**, which Windows PowerShell 5.1 rejects in that position. The
affected lines in `tools/usl-phase1b-cross-source-overlay.ps1`:

- **144** — `SRC_DESKTOP` `access_status=(if (Test-Path …) {"PRESENT"} else {"REVIEW_REQUIRED"})`
- **145** — `SRC_DOCUMENTS` `access_status=(if (Test-Path …) {"PRESENT"} else {"REVIEW_REQUIRED"})`
- **146** — `SRC_GDRIVE` `source_path=(if ($driveLocalPath) {$driveLocalPath} else {"UNKNOWN"})`
- **150** — `SRC_CAD` `access_status=(if ($cadPresent) {"PRESENT_INDEX_ONLY"} else {"REVIEW_REQUIRED"})`

(The `$(if …)` usages inside the double-quoted here-strings are lower risk — they
sit in subexpressions — but should be confirmed during reconstruction.)

## Recommended reconstruction (behavior-preserving)

Precompute each value into a variable **before** the `$sourceRows` array, then
reference the variable in the hashtable. This is the minimal, compat-safe change
and does not alter any output value:

```powershell
$desktopPath     = Join-Path $env:USERPROFILE "OneDrive\Desktop"
$desktopStatus   = if (Test-Path -LiteralPath $desktopPath)   { "PRESENT" } else { "REVIEW_REQUIRED" }
$documentsPath   = Join-Path $env:USERPROFILE "Documents"
$documentsStatus = if (Test-Path -LiteralPath $documentsPath) { "PRESENT" } else { "REVIEW_REQUIRED" }
$gdrivePathValue = if ($driveLocalPath) { $driveLocalPath } else { "UNKNOWN" }
$cadStatus       = if ($cadPresent) { "PRESENT_INDEX_ONLY" } else { "REVIEW_REQUIRED" }
```

Then in `$sourceRows`:

- line 144 → `access_status=$desktopStatus; source_path=$desktopPath`
- line 145 → `access_status=$documentsStatus; source_path=$documentsPath`
- line 146 → `source_path=$gdrivePathValue`
- line 150 → `access_status=$cadStatus`

As assignment statements (outside the hashtable literal), `if` works in PowerShell
5.1, so this resolves the syntax error while keeping logic identical.

## Safety review of the current script (un-patched version inspected)

The reconstruction above is **PowerShell syntax/compatibility only**. The current
script's safety posture is intact and must be preserved by any patch:

- No delete behavior. No move behavior. No source-file copy behavior.
- No upload / share / public-link behavior. No emails or drafts.
- No tracker mutation. No external action. No cleanup execution.
- Writes only inside the Phase 1B cleanup folder.
- Destructive cleanup remains **LOCKED**; `APPROVE_DESTRUCTIVE_CLEANUP_PHASE` is
  still required and is never acted on by the script.
- Secret-like paths redacted as `REDACTED_PATTERN`; archive not re-inventoried;
  CAD generator index-only.

## Recommended next steps (gated)

1. Reconstruct the patch on Windows as above (or paste the Windows working-tree
   diff so it can be reviewed and committed verbatim).
2. Re-run Phase 1B **once** to confirm the patched script reproduces the
   `…OVERLAY_COMPLETE__DESTRUCTIVE_CLEANUP_GATE_LOCKED` label.
3. With Andrew's explicit approval, commit the patch and push so PR #2 reflects
   the working script.

**Do not commit or push this note or any patch without Andrew's explicit
approval.** No external actions, deletions, moves, or cleanup were performed.
