# Phase 1B Compatibility Patch — Review

Review of the reconstructed PowerShell compatibility patch to
`tools/usl-phase1b-cross-source-overlay.ps1`. **Uncommitted** — prepared for
Andrew's gated commit/push approval. No commit, no push, no PR-ready action.

## What failed

The script used `if` as an inline expression **inside `[pscustomobject]@{ … }`
hashtable literals** at lines 144, 145, 146, and 150, e.g.
`access_status=(if (Test-Path …) {"PRESENT"} else {"REVIEW_REQUIRED"})`. Windows
PowerShell 5.1 does not accept an `if`-expression in that position, so the script
failed to parse before doing any work.

## What was changed

Precomputed the four conditional values into named variables **before** the
`$sourceRows` array, then referenced the variables in the hashtable:

```powershell
$desktopStatus   = if (Test-Path -LiteralPath (Join-Path $env:USERPROFILE "OneDrive\Desktop")) { "PRESENT" } else { "REVIEW_REQUIRED" }
$documentsStatus = if (Test-Path -LiteralPath (Join-Path $env:USERPROFILE "Documents")) { "PRESENT" } else { "REVIEW_REQUIRED" }
$gdrivePathValue = if ($driveLocalPath) { $driveLocalPath } else { "UNKNOWN" }
$cadStatus       = if ($cadPresent) { "PRESENT_INDEX_ONLY" } else { "REVIEW_REQUIRED" }
```

- line 144 → `access_status=$desktopStatus`
- line 145 → `access_status=$documentsStatus`
- line 146 → `source_path=$gdrivePathValue`
- line 150 → `access_status=$cadStatus`

No other lines changed.

## Why the change is syntax-only

`$x = if (...) { a } else { b }` as an assignment statement is valid in PowerShell
5.1 (the script already uses it at line 133 for `$driveStatus`). The only problem
was using the same `if` *inside a hashtable literal value*. Moving the evaluation
out to a preceding statement yields **identical output values** — same conditions,
same branches, same strings — with no behavioral change.

## Diff summary

`tools/usl-phase1b-cross-source-overlay.ps1`: 1 file changed, 13 insertions(+),
4 deletions(-). Adds a 4-line precompute block (plus a 4-line comment); replaces
the 4 inline-`if` expressions with the variables.

## Safety-gate scan result

- Forbidden cmdlet scan (`Remove-Item|Move-Item|Copy-Item|Invoke-WebRequest|Invoke-RestMethod|Start-BitsTransfer|Send-MailMessage|gh pr ready`): **none found**.
- No delete, move, source-file copy, upload/share/link, tracker mutation, external
  action, cleanup execution, or readiness marking introduced.
- `APPROVE_DESTRUCTIVE_CLEANUP_PHASE` requirement: **intact** (token check
  unchanged; `destructive_cleanup_gate = "LOCKED"`).
- No remaining inline-`if` inside a hashtable literal.
- Delimiters and here-strings balanced.

## Re-run result

**NOT EXECUTED in this environment.** The patch was reconstructed in a Linux
container with no PowerShell and no access to `C:\Users\motor`. Steps 6–7 (run the
script, list the Phase 1B output folder) must be performed on Andrew's Windows USL
OS machine.

- COMPLETE label emitted? **Not by this review** — only the Windows run prints
  `USL_OS_PHASE_1B_CROSS_SOURCE_INVENTORY_OVERLAY_COMPLETE__DESTRUCTIVE_CLEANUP_GATE_LOCKED`.
- Protected actions remained false? **Yes** — the patch introduces no protected
  actions; the audit JSON still reports all hard-safety flags and a LOCKED gate.

## Recommended next steps (gated)

1. On Windows, run:
   `powershell -ExecutionPolicy Bypass -File tools\usl-phase1b-cross-source-overlay.ps1`
   and confirm it emits the COMPLETE label and writes the Phase 1B output folder.
2. With Andrew's explicit approval, commit this patch (and this review note) and
   push so PR #2 reflects the working script. Keep PR #2 draft.
