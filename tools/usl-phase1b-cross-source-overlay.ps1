<#
.SYNOPSIS
    USL AI Operating System — Phase 1B Cross-Source Inventory Overlay (SAGE).

.DESCRIPTION
    Read-only over all sources. Reads Phase 1 inventory outputs and generates the
    Phase 1B cross-source overlay planning/schema/safety outputs INSIDE the
    cleanup folder only. Does NOT delete, move, or copy source files; performs no
    uploads, links, emails, drafts, bids/quotes/RFQs, or tracker mutations.

    Doctrine: SAGE — Schema every output, Audit every decision, Gate every
    external action, Eval every upgrade. Destructive cleanup stays LOCKED unless
    Andrew supplies APPROVE_DESTRUCTIVE_CLEANUP_PHASE (this script never unlocks
    it).

.PARAMETER UslOsRoot
    Primary USL AI Operating System root (canonical). Must exist.

.PARAMETER CadGeneratorRoot
    Separate CAD generator root. Index-only; never merged or inventoried as a
    source.

.PARAMETER ApprovalToken
    Destructive-cleanup approval token. Anything other than the exact value
    APPROVE_DESTRUCTIVE_CLEANUP_PHASE keeps the gate LOCKED. This script does not
    act on the token; it only records gate state.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\usl-phase1b-cross-source-overlay.ps1
#>

[CmdletBinding()]
param(
    [string]$UslOsRoot = "C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System",
    [string]$CadGeneratorRoot = "C:\Users\motor\OneDrive\Documents\New project\USL_Legacy_Part_CAD_Generator",
    [string]$ApprovalToken = ""
)

$ErrorActionPreference = "Stop"
$now = Get-Date

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

$cleanupRoot = Join-Path $UslOsRoot "10_Agent_Operating_Model\ai_os_consolidation_cleanup"
$phase1bDir  = Join-Path $cleanupRoot "Phase_1B_Cross_Source_Inventory"
$archiveArea = Join-Path $UslOsRoot "10_Agent_Operating_Model\agent_conversation_archive"

if (-not (Test-Path -LiteralPath $UslOsRoot)) {
    Write-Error "USL OS root not found: $UslOsRoot"; exit 1
}
if (-not (Test-Path -LiteralPath $cleanupRoot)) {
    Write-Error "Cleanup track not found: $cleanupRoot. Run Phase 1 first."; exit 1
}
if (-not (Test-Path -LiteralPath $phase1bDir)) {
    New-Item -ItemType Directory -Path $phase1bDir -Force | Out-Null
}

# Phase 1 inputs (read-only).
$phase1 = [ordered]@{
    inventory_summary_json = Join-Path $cleanupRoot "consolidation_inventory_summary.json"
    folder_inventory_csv   = Join-Path $cleanupRoot "Inventory\usl_os_folder_inventory.csv"
    file_inventory_csv     = Join-Path $cleanupRoot "Inventory\usl_os_file_inventory.csv"
    skipped_inventory_csv  = Join-Path $cleanupRoot "Inventory\usl_os_skipped_inventory_items.csv"
    canonical_folder_map   = Join-Path $cleanupRoot "Plans\canonical_folder_map.md"
    dry_run_cleanup_plan   = Join-Path $cleanupRoot "Plans\dry_run_cleanup_plan.md"
    inventory_summary_md   = Join-Path $cleanupRoot "Reports\consolidation_inventory_summary.md"
    duplicate_review_csv   = Join-Path $cleanupRoot "Reports\usl_os_duplicate_review.csv"
    duplicate_review_md    = Join-Path $cleanupRoot "Reports\duplicate_review_summary.md"
}

# Known Phase 1 counts (fallbacks; recomputed from CSVs when readable).
$counts = [ordered]@{
    folder_inventory_rows = 1490
    file_inventory_rows   = 4624
    focus_candidate_files = 4242
    hashed_focus_files    = 4242
    duplicate_hash_groups = 537
    duplicate_file_rows   = 1669
    skipped_inventory     = 44
}

$filesRead = New-Object System.Collections.Generic.List[string]
function Confirm-Read([string]$path) {
    if (Test-Path -LiteralPath $path) { $filesRead.Add($path); return $true }
    return $false
}
function Get-CsvRowCount([string]$path) {
    # Count rows without retaining contents (header excluded). Returns $null on failure.
    try {
        if (-not (Test-Path -LiteralPath $path)) { return $null }
        $n = 0
        Import-Csv -LiteralPath $path | ForEach-Object { $n++ }
        return $n
    } catch { return $null }
}

foreach ($k in $phase1.Keys) { [void](Confirm-Read $phase1[$k]) }

# Prefer actual row counts where the CSV is readable.
$fc = Get-CsvRowCount $phase1.folder_inventory_csv;  if ($null -ne $fc) { $counts.folder_inventory_rows = $fc }
$rc = Get-CsvRowCount $phase1.file_inventory_csv;    if ($null -ne $rc) { $counts.file_inventory_rows = $rc }
$dc = Get-CsvRowCount $phase1.duplicate_review_csv;  if ($null -ne $dc) { $counts.duplicate_file_rows = $dc }
$sc = Get-CsvRowCount $phase1.skipped_inventory_csv; if ($null -ne $sc) { $counts.skipped_inventory = $sc }

# ---------------------------------------------------------------------------
# Redaction helper (secret-like patterns -> REDACTED_PATTERN in summaries)
# ---------------------------------------------------------------------------

$secretRegex = '(?i)(api[_-]?key|secret|token|password|client[_-]?secret|private[_-]?key|mfa|recovery[_-]?code|access[_-]?token|refresh[_-]?token|\.pem|\.pfx|\.p12|\.key)'
function Protect-Path([string]$text) {
    if ($null -eq $text) { return "" }
    if ($text -match $secretRegex) { return "REDACTED_PATTERN" }
    return $text
}

# ---------------------------------------------------------------------------
# Google Drive local-mount detection (no external access)
# ---------------------------------------------------------------------------

$driveCandidates = @(
    (Join-Path $env:USERPROFILE "Google Drive"),
    (Join-Path $env:USERPROFILE "My Drive"),
    "G:\My Drive",
    "G:\Shared drives"
)
$driveLocal = $false
$driveLocalPath = ""
foreach ($d in $driveCandidates) {
    if (Test-Path -LiteralPath $d) { $driveLocal = $true; $driveLocalPath = $d; break }
}
$driveStatus = if ($driveLocal) { "LOCAL_SYNC_PRESENT" } else { "PENDING_SOURCE_ACCESS" }

$cadPresent = Test-Path -LiteralPath $CadGeneratorRoot

# ---------------------------------------------------------------------------
# Source map (one row per SOURCE — sources are not re-inventoried here)
# ---------------------------------------------------------------------------

$sourceRows = @(
    [pscustomobject]@{ source_id="SRC_CANONICAL"; source_path=$UslOsRoot;                                            source_class="CANONICAL_ROOT";                       access_status="PRESENT";                in_phase1_inventory="YES"; notes="Canonical operating root; Phase 1 inventory target." }
    [pscustomobject]@{ source_id="SRC_ONEDRIVE";  source_path=(Split-Path -Parent $UslOsRoot);                       source_class="LOCAL_ONEDRIVE_SOURCE";                access_status="PRESENT";                in_phase1_inventory="PARTIAL"; notes="OneDrive\Documents parent; overlay candidates outside canonical." }
    [pscustomobject]@{ source_id="SRC_DESKTOP";   source_path=(Join-Path $env:USERPROFILE "OneDrive\Desktop");        source_class="LOCAL_DESKTOP_SOURCE";                 access_status=(if (Test-Path -LiteralPath (Join-Path $env:USERPROFILE "OneDrive\Desktop")) {"PRESENT"} else {"REVIEW_REQUIRED"}); in_phase1_inventory="NO"; notes="Desktop overlay source; scan in Phase 1B requirements." }
    [pscustomobject]@{ source_id="SRC_DOCUMENTS"; source_path=(Join-Path $env:USERPROFILE "Documents");               source_class="LOCAL_DOCUMENTS_SOURCE";               access_status=(if (Test-Path -LiteralPath (Join-Path $env:USERPROFILE "Documents")) {"PRESENT"} else {"REVIEW_REQUIRED"}); in_phase1_inventory="NO"; notes="Local Documents (non-OneDrive) overlay source." }
    [pscustomobject]@{ source_id="SRC_GDRIVE";    source_path=(if ($driveLocalPath) {$driveLocalPath} else {"UNKNOWN"}); source_class="GOOGLE_DRIVE_PENDING_OR_LOCAL_SYNC"; access_status=$driveStatus;            in_phase1_inventory="NO"; notes="Index only if locally synced; else PENDING_SOURCE_ACCESS." }
    [pscustomobject]@{ source_id="SRC_CHATGPT";   source_path=(Join-Path $archiveArea "ChatGPT");                     source_class="CHATGPT_SURFACE_ARCHIVE";              access_status="MANAGED_ARCHIVE_NO_REINVENTORY"; in_phase1_inventory="ARCHIVE"; notes="Existing managed archive area; do not re-inventory as a new source." }
    [pscustomobject]@{ source_id="SRC_CLAUDE";    source_path=(Join-Path $archiveArea "Claude");                      source_class="CLAUDE_SURFACE_ARCHIVE";               access_status="MANAGED_ARCHIVE_NO_REINVENTORY"; in_phase1_inventory="ARCHIVE"; notes="Includes Claude and Claude_Code; managed archive area." }
    [pscustomobject]@{ source_id="SRC_CODEX";     source_path=(Join-Path $archiveArea "Codex");                       source_class="CODEX_SURFACE_ARCHIVE";                access_status="MANAGED_ARCHIVE_NO_REINVENTORY"; in_phase1_inventory="ARCHIVE"; notes="Managed archive area." }
    [pscustomobject]@{ source_id="SRC_CAD";       source_path=$CadGeneratorRoot;                                      source_class="CAD_GENERATOR_INDEX_ONLY";             access_status=(if ($cadPresent) {"PRESENT_INDEX_ONLY"} else {"REVIEW_REQUIRED"}); in_phase1_inventory="NO"; notes="SEPARATE. Index-link only; never merge or inventory as a source." }
    [pscustomobject]@{ source_id="SRC_UNKNOWN";   source_path="UNKNOWN";                                              source_class="UNKNOWN_REVIEW_REQUIRED";              access_status="REVIEW_REQUIRED";        in_phase1_inventory="NO"; notes="Placeholder for any source discovered later needing human review." }
)
# Apply redaction to emitted source paths.
foreach ($r in $sourceRows) { $r.source_path = Protect-Path $r.source_path }

$sourceMapCsv = Join-Path $phase1bDir "cross_source_source_map.csv"
$sourceRows | Export-Csv -LiteralPath $sourceMapCsv -NoTypeInformation -Encoding UTF8

# Sources mapped summary for the executive output.
$sourcesMappedCount = $sourceRows.Count

# ---------------------------------------------------------------------------
# Shared audit footer
# ---------------------------------------------------------------------------

$auditFooter = @"

---
**Phase 1B audit statement.** No files were deleted, moved, or copied from any
source. No uploads, public links, emails, Gmail drafts, bids, quotes, RFQs,
RPPOB/SAR/ESA submissions, supplier routing, or customer/supplier communications
were performed. No live trackers were mutated. Nothing was marked Bid/Quote/SAR/
ESA/Submission Ready. Outputs were created only inside the cleanup folder. Secret-
like paths are shown as REDACTED_PATTERN. Skipped files were not opened. The CAD
generator root is preserved as separate (index-link only). Destructive cleanup
gate: LOCKED (requires APPROVE_DESTRUCTIVE_CLEANUP_PHASE).
"@

function Write-Doc([string]$name, [string]$body) {
    $path = Join-Path $phase1bDir $name
    ($body.TrimEnd() + "`r`n" + $auditFooter) | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}

$ts = $now.ToString('o')

# 1. cross_source_inventory_scope.md
$doc1 = @"
# Phase 1B — Cross-Source Inventory Scope

- Timestamp: $ts
- Canonical root: $(Protect-Path $UslOsRoot)
- CAD generator root (index only, separate): $(Protect-Path $CadGeneratorRoot)
- Cleanup track: $(Protect-Path $cleanupRoot)
- Phase 1B output folder: $(Protect-Path $phase1bDir)

## Doctrine
SAGE — Schema every output, Audit every decision, Gate every external action,
Eval every upgrade.

## In scope (this pass)
Inventory overlay, source mapping, canonical sync mapping, duplicate-label
planning, CAD index-link planning, and safety-gate documentation. Read-only over
sources; outputs created only inside the cleanup folder.

## Out of scope (this pass)
Any deletion, movement, or copying of source files; uploads; external actions;
tracker mutation; destructive cleanup. Google Drive content access unless locally
synced.

## Phase 1 inputs read
$(($phase1.GetEnumerator() | ForEach-Object { "- $($_.Key): " + ($(if (Test-Path -LiteralPath $_.Value) {"FOUND"} else {"MISSING"})) + " — " + (Protect-Path $_.Value) }) -join "`r`n")

## Phase 1 counts (recomputed where readable, else known values)
$(($counts.GetEnumerator() | ForEach-Object { "- $($_.Key): $($_.Value)" }) -join "`r`n")
"@
$p1 = Write-Doc "cross_source_inventory_scope.md" $doc1

# 3. canonical_sync_map.md
$doc3 = @"
# Phase 1B — Canonical Sync Map

Mapping of each source class to its canonical disposition under the USL AI
Operating System root. This is a plan, not an action. No files are moved.

| Source class | Canonical disposition | Action posture |
| --- | --- | --- |
| CANONICAL_ROOT | Is the canonical operating structure | Keep as system of record |
| LOCAL_ONEDRIVE_SOURCE | Overlay into canonical subfolders (planned) | Map only; human-reviewed copy later |
| LOCAL_DESKTOP_SOURCE | Overlay into canonical (planned) | Requirements checklist (this phase) |
| LOCAL_DOCUMENTS_SOURCE | Overlay into canonical (planned) | Requirements checklist (this phase) |
| GOOGLE_DRIVE_PENDING_OR_LOCAL_SYNC | Index if locally synced; else pending | $driveStatus |
| CHATGPT_SURFACE_ARCHIVE | Managed archive area | Reference only; no re-inventory |
| CLAUDE_SURFACE_ARCHIVE | Managed archive area | Reference only; no re-inventory |
| CODEX_SURFACE_ARCHIVE | Managed archive area | Reference only; no re-inventory |
| CAD_GENERATOR_INDEX_ONLY | Separate; never merged | Index-link plan only |
| UNKNOWN_REVIEW_REQUIRED | None until reviewed | Human review |

See cross_source_source_map.csv for the per-source rows and access status.
"@
$p3 = Write-Doc "canonical_sync_map.md" $doc3

# 4. cross_source_duplicate_review_plan.md
$doc4 = @"
# Phase 1B — Cross-Source Duplicate Review Plan

Phase 1 detected $($counts.duplicate_hash_groups) duplicate hash groups across
$($counts.duplicate_file_rows) duplicate file rows. This plan defines how those —
and any cross-source duplicates found later — are LABELLED. It assigns no
deletions.

## Posture taxonomy
- KEEP_CANONICAL
- CANONICAL_INDEX_ONLY
- CLEANUP_CANDIDATE_EXACT_DUPLICATE
- KEEP_ARCHIVE_COPY
- DO_NOT_DELETE_CONTROLLED_OR_UNKNOWN
- REVIEW_REQUIRED_PATH_CONTEXT
- PENDING_CROSS_SOURCE_HASH

## Default posture for this phase
Until cross-source hashing is complete and Andrew approves the destructive gate,
every duplicate group defaults to **REVIEW_REQUIRED_PATH_CONTEXT** (or
**PENDING_CROSS_SOURCE_HASH** where another source is not yet hashed). Items whose
path/context is controlled or unknown default to
**DO_NOT_DELETE_CONTROLLED_OR_UNKNOWN**.

## Hard rule
Duplicate status is NOT deletion approval. No row is set to
CLEANUP_CANDIDATE_EXACT_DUPLICATE as an actionable delete in this phase.
Destructive cleanup remains LOCKED pending APPROVE_DESTRUCTIVE_CLEANUP_PHASE.

## Inputs
- Reports\usl_os_duplicate_review.csv (read-only)
- Reports\duplicate_review_summary.md (read-only)
"@
$p4 = Write-Doc "cross_source_duplicate_review_plan.md" $doc4

# 5. cad_generator_index_link_plan.md
$doc5 = @"
# Phase 1B — CAD Generator Index-Link Plan

The CAD generator is a SEPARATE system and is never merged into the USL AI
Operating System. This phase produces an index-link plan only.

- CAD generator root: $(Protect-Path $CadGeneratorRoot)
- Local presence: $(if ($cadPresent) {"PRESENT"} else {"REVIEW_REQUIRED / not found at expected path"})
- Disposition: CAD_GENERATOR_INDEX_ONLY

## Plan
1. Record a single index pointer (path + purpose) in the canonical operating
   structure; do not copy or inventory CAD contents into the USL OS.
2. Do not recurse into the CAD generator as a discovery source.
3. Treat any drawings/TDP/controlled technical data as DO_NOT_DELETE_CONTROLLED_OR_UNKNOWN
   and never upload or expose contents.
"@
$p5 = Write-Doc "cad_generator_index_link_plan.md" $doc5

# 6. google_drive_sync_requirements.md
$doc6 = @"
# Phase 1B — Google Drive Sync Requirements

Detected Google Drive local status: **$driveStatus**$(if ($driveLocal) {" at $(Protect-Path $driveLocalPath)"})

This phase does not access Google Drive over the network. If Drive is not locally
synced, it is documented as PENDING_SOURCE_ACCESS and only a requirements
checklist is produced.

## Requirements checklist (before Drive overlay)
- [ ] Google Drive for Desktop installed and signed in on this machine.
- [ ] Target Drive folders mirrored locally (My Drive / relevant Shared drives).
- [ ] Confirm no controlled technical data is included in the overlay scope.
- [ ] Confirm a local path is available so Phase 1B can index without external access.
- [ ] Re-run this overlay once $driveStatus becomes LOCAL_SYNC_PRESENT.
"@
$p6 = Write-Doc "google_drive_sync_requirements.md" $doc6

# 7. one_drive_local_scan_requirements.md
$doc7 = @"
# Phase 1B — OneDrive / Local Scan Requirements

Overlay sources (Desktop, Documents, OneDrive\Documents outside canonical) are
indexed read-only in a later step. This checklist defines safe preconditions.

## Requirements
- [ ] Confirm OneDrive files are available locally (not online-only placeholders).
- [ ] Exclude cache/config/credential folders (AppData, .git, .ssh, .gnupg, etc.).
- [ ] Exclude the archive area from re-inventory (managed archive).
- [ ] Redact any secret-like path/filename as REDACTED_PATTERN.
- [ ] Do not open skipped files.

## Source presence snapshot
$(($sourceRows | Where-Object { $_.source_class -in @("LOCAL_ONEDRIVE_SOURCE","LOCAL_DESKTOP_SOURCE","LOCAL_DOCUMENTS_SOURCE") } | ForEach-Object { "- $($_.source_id): $($_.access_status) — $($_.source_path)" }) -join "`r`n")
"@
$p7 = Write-Doc "one_drive_local_scan_requirements.md" $doc7

# 8. chatgpt_claude_codex_memory_alignment_plan.md
$doc8 = @"
# Phase 1B — ChatGPT / Claude / Codex Memory Alignment Plan

Native vendor memory does not cross vendors. Alignment is achieved by mapping each
surface's saved exports/handoffs to the canonical operating structure, not by
sharing native memory.

| Surface | Source class | Canonical mapping | Notes |
| --- | --- | --- | --- |
| ChatGPT | CHATGPT_SURFACE_ARCHIVE | Managed archive area | Reference only; no re-inventory |
| Claude / Claude Code | CLAUDE_SURFACE_ARCHIVE | Managed archive area | Includes Cowork/repo handoffs |
| Codex | CODEX_SURFACE_ARCHIVE | Managed archive area | Repo patch/test sessions |

## Alignment rules
- Treat saved exports/handoffs as the cross-vendor memory; chats are sessions.
- Model/provider fields that are not verified are recorded as UNKNOWN.
- No surface is treated as the system of record; the canonical repo/structure is.
- No deletion or movement; managed archive is referenced, not re-inventoried.
"@
$p8 = Write-Doc "chatgpt_claude_codex_memory_alignment_plan.md" $doc8

# 2. cross_source_source_map.csv already written; record path
$p2 = $sourceMapCsv

# 9. phase_1b_safety_gate_audit.json
$tokenOk = ($ApprovalToken -eq "APPROVE_DESTRUCTIVE_CLEANUP_PHASE")
$audit = [ordered]@{
    phase = "1B_Cross_Source_Inventory_Overlay"
    timestamp = $ts
    doctrine = "SAGE"
    canonical_root = $UslOsRoot
    cad_generator_root_index_only = $CadGeneratorRoot
    sage_gates = [ordered]@{
        schema_every_output = "AFFIRMED"
        audit_every_decision = "AFFIRMED"
        gate_every_external_action = "AFFIRMED"
        eval_every_upgrade = "AFFIRMED"
    }
    hard_safety_rules = [ordered]@{
        no_delete = $true
        no_move = $true
        no_copy_sources = $true
        no_upload = $true
        no_public_links = $true
        no_emails = $true
        no_gmail_drafts = $true
        no_bids_quotes_rfqs = $true
        no_rppob_sar_esa_submissions = $true
        no_supplier_customer_comms = $true
        no_tracker_mutation = $true
        no_readiness_marking = $true
        no_credential_exposure = $true
        unknown_fields_marked_unknown = $true
        duplicate_status_is_not_deletion_approval = $true
        skipped_files_not_opened = $true
        archive_not_reinventoried_as_source = $true
        cad_generator_kept_separate = $true
    }
    google_drive_status = $driveStatus
    destructive_cleanup_gate = "LOCKED"
    approval_token_required = "APPROVE_DESTRUCTIVE_CLEANUP_PHASE"
    approval_token_present = $tokenOk
    outputs_written_inside_cleanup_folder_only = $true
}
$auditPath = Join-Path $phase1bDir "phase_1b_safety_gate_audit.json"
$audit | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $auditPath -Encoding UTF8

# 10. phase_1b_completion_report.md
$createdList = @($p1,$p2,$p3,$p4,$p5,$p6,$p7,$p8,$auditPath)
$doc10 = @"
# Phase 1B — Completion Report

- Timestamp: $ts
- Canonical root: $(Protect-Path $UslOsRoot)
- Phase 1B folder: $(Protect-Path $phase1bDir)

## Files read (Phase 1 inputs)
$(($filesRead | ForEach-Object { "- " + (Protect-Path $_) }) -join "`r`n")

## Files created (this phase)
$(($createdList | ForEach-Object { "- " + (Protect-Path $_) }) -join "`r`n")
- $(Protect-Path (Join-Path $phase1bDir "phase_1b_completion_report.md"))

## Sources mapped
$sourcesMappedCount source rows (see cross_source_source_map.csv).

## Phase 1 counts carried forward
$(($counts.GetEnumerator() | ForEach-Object { "- $($_.Key): $($_.Value)" }) -join "`r`n")

## Unresolved access gaps
- Google Drive: $driveStatus
- Desktop/Documents overlay sources: indexed in a later gated step (requirements documented).
- CAD generator: index-only ($(if ($cadPresent) {"present"} else {"path review required"})).

## Duplicate / deletion gate status
- Destructive cleanup gate: LOCKED (APPROVE_DESTRUCTIVE_CLEANUP_PHASE not acted on).
- Duplicate posture: REVIEW_REQUIRED_PATH_CONTEXT / PENDING_CROSS_SOURCE_HASH defaults.

## Recommended next safe task
Review cross_source_source_map.csv and the duplicate review plan, resolve Google
Drive local-sync, then run the read-only overlay indexing of Desktop/Documents
sources. Do NOT request destructive cleanup until cross-source hashing is complete
and Andrew approves the gate.
"@
$p10 = Write-Doc "phase_1b_completion_report.md" $doc10

# 11. phase_1b_next_task_command.md (safe to create)
$doc11 = @"
# Phase 1B — Next Task Command

Suggested next safe task (read-only, gated). Paste into the next local session.

```text
Continue USL AI Operating System consolidation: Phase 1C — Overlay Indexing
(read-only). Using Phase_1B_Cross_Source_Inventory\cross_source_source_map.csv,
index (do not copy/move/delete) the LOCAL_DESKTOP_SOURCE and LOCAL_DOCUMENTS_SOURCE
overlay sources into the cleanup folder as index CSVs only. Resolve Google Drive
local sync first if status is PENDING_SOURCE_ACCESS. Keep CAD generator index-only.
Keep destructive cleanup LOCKED (APPROVE_DESTRUCTIVE_CLEANUP_PHASE required).
Schema every output, audit every decision, redact secret-like paths.
```
"@
$p11 = Write-Doc "phase_1b_next_task_command.md" $doc11

# ---------------------------------------------------------------------------
# Executive summary
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "==== USL OS Phase 1B Cross-Source Inventory Overlay ====" -ForegroundColor Cyan
Write-Host "Files read:            $($filesRead.Count) Phase 1 input(s)"
Write-Host "Files created:         $($createdList.Count + 2) (incl. report + next-task command)"
Write-Host "Sources mapped:        $sourcesMappedCount"
Write-Host "Google Drive status:   $driveStatus"
Write-Host "CAD generator:         $(if ($cadPresent) {'PRESENT (index-only)'} else {'REVIEW_REQUIRED'})"
Write-Host "Duplicate/deletion gate: LOCKED (APPROVE_DESTRUCTIVE_CLEANUP_PHASE required)"
Write-Host ""
Write-Host "No deletions, moves, copies of sources, uploads, external actions, or tracker mutations were performed." -ForegroundColor Green
Write-Host "Recommended next safe task: review source map + duplicate plan, resolve Drive sync, then Phase 1C overlay indexing."
Write-Host ""
Write-Host "USL_OS_PHASE_1B_CROSS_SOURCE_INVENTORY_OVERLAY_COMPLETE__DESTRUCTIVE_CLEANUP_GATE_LOCKED" -ForegroundColor Yellow
