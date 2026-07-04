param(
    [switch]$Commit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$crmRoot = "C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System\03_Apollo_Outreach\apollo\control"
$activityPath = Join-Path $crmRoot "crm_pipeline_activity_log.csv"
$changeLogPath = Join-Path $crmRoot "apollo_change_log.csv"
$reportsDir = Join-Path $crmRoot "reports"
$backupsDir = Join-Path $crmRoot "backups"

$reportName = if ($Commit) { "crm_pipeline_agenda_refresh_report.md" } else { "crm_pipeline_agenda_refresh_report.PREVIEW.md" }
$reportPath = Join-Path $reportsDir $reportName

$canonical = @("agenda_rank","priority","contact_name","company_or_agency","opportunity_or_solicitation","nsn_or_part_number","activity_type","activity_summary","current_status","next_action","follow_up_date","owner","source","tags","protected_actions_performed")

function Assert-LocalPath {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Label
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Label not found: $Path"
    }
}

function New-NaturalKey {
    param([Parameter(Mandatory=$true)][object]$Row)
    $parts = @(
        $Row.activity_type,
        $Row.opportunity_or_solicitation,
        $Row.nsn_or_part_number,
        $Row.owner
    )
    return (($parts | ForEach-Object { ("" + $_).Trim().ToUpperInvariant() }) -join "|")
}

function Convert-ToCanonicalRow {
    param([Parameter(Mandatory=$true)][object]$Row)
    $out = [ordered]@{}
    foreach ($field in $canonical) {
        $value = ""
        if ($Row.PSObject.Properties.Name -contains $field) {
            $value = $Row.$field
        }
        $out[$field] = $value
    }
    return [pscustomobject]$out
}

function New-AgendaRecord {
    param(
        [string]$AgendaRank,
        [string]$Priority,
        [string]$ContactName,
        [string]$CompanyOrAgency,
        [string]$Opportunity,
        [string]$NsnOrPartNumber,
        [string]$ActivityType,
        [string]$Summary,
        [string]$Status,
        [string]$NextAction,
        [string]$FollowUpDate,
        [string]$Owner,
        [string]$Source,
        [string]$Tags
    )
    return [pscustomobject][ordered]@{
        agenda_rank = $AgendaRank
        priority = $Priority
        contact_name = $ContactName
        company_or_agency = $CompanyOrAgency
        opportunity_or_solicitation = $Opportunity
        nsn_or_part_number = $NsnOrPartNumber
        activity_type = $ActivityType
        activity_summary = $Summary
        current_status = $Status
        next_action = $NextAction
        follow_up_date = $FollowUpDate
        owner = $Owner
        source = $Source
        tags = $Tags
        protected_actions_performed = "NONE"
    }
}

Assert-LocalPath -Path $crmRoot -Label "CRM control path"
Assert-LocalPath -Path $activityPath -Label "CRM activity log"
Assert-LocalPath -Path $changeLogPath -Label "Apollo change log"
New-Item -ItemType Directory -Force -Path $reportsDir | Out-Null

$phase15Folder = "C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System\10_Agent_Operating_Model\ai_os_consolidation_cleanup\Phase_15_NO_GO_Preservation_And_Response_Archive_Handoff_Only"
$phase15Handoff = Join-Path $phase15Folder "phase_15_response_archive_handoff.md"
$phase15Queue = Join-Path $phase15Folder "phase_15_future_review_queue.csv"
$phase15Lock = Join-Path $phase15Folder "phase_15_cleanup_authorization_lock_summary.md"

$prepared = @(
    New-AgendaRecord `
        -AgendaRank "001" `
        -Priority "TOP" `
        -ContactName "Andrew" `
        -CompanyOrAgency "USL Internal" `
        -Opportunity "AI OS Consolidation / Cleanup Track - Phase 15" `
        -NsnOrPartNumber "N/A" `
        -ActivityType "INTERNAL_REVIEW_TASK" `
        -Summary "Review Phase 15 NO_GO preservation and response archive handoff. NO_GO is preserved, destructive cleanup is NOT_READY, gate is LOCKED, protected records remain blocked, and the 21-item future review queue requires Andrew review before any cleanup-related decision." `
        -Status "NO_GO_PRESERVED / HUMAN_REVIEW_REQUIRED / DESTRUCTIVE_CLEANUP_LOCKED" `
        -NextAction "Open $phase15Handoff first, then review phase_15_future_review_queue.csv. Do not authorize cleanup from this task." `
        -FollowUpDate "Next USL operating review" `
        -Owner "Andrew" `
        -Source $phase15Handoff `
        -Tags "AI_OS_CLEANUP|PHASE_15|NO_GO_PRESERVED|HUMAN_REVIEW_REQUIRED|DESTRUCTIVE_CLEANUP_LOCKED|RESPONSE_ARCHIVE|FUTURE_REVIEW_QUEUE|DO_NOT_TOUCH"

    New-AgendaRecord `
        -AgendaRank "002" `
        -Priority "HIGH" `
        -ContactName "Andrew" `
        -CompanyOrAgency "TDMT / DISA access path" `
        -Opportunity "TDMT access follow-up" `
        -NsnOrPartNumber "N/A" `
        -ActivityType "INTERNAL_FOLLOW_UP" `
        -Summary "Follow up on TDMT access status. Keep as access/provisioning follow-up only; do not contact external parties from this helper." `
        -Status "FOLLOW_UP_PENDING / LOCAL_CRM_ONLY" `
        -NextAction "Andrew review TDMT access follow-up status and decide separate human action path if needed." `
        -FollowUpDate "2026-07-07" `
        -Owner "Andrew" `
        -Source "USL AI OS CRM agenda refresh" `
        -Tags "TDMT|ACCESS_FOLLOW_UP|HIGH_PRIORITY|LOCAL_ONLY|NO_EXTERNAL_ACTIONS"

    New-AgendaRecord `
        -AgendaRank "003" `
        -Priority "HIGH" `
        -ContactName "Emma Hippensteel" `
        -CompanyOrAgency "Government / contracting contact" `
        -Opportunity "SPRMM1-26-Q-MF39" `
        -NsnOrPartNumber "3040-01-399-7856" `
        -ActivityType "GOVERNMENT_RESPONSE_REVIEW" `
        -Summary "Track Emma Hippensteel / SPRMM1-26-Q-MF39 follow-up for local review. No email, draft, bid, quote, or external action is authorized." `
        -Status "HUMAN_REVIEW_REQUIRED / LOCAL_CRM_ONLY" `
        -NextAction "Andrew review opportunity status and decide whether any separate approved action is needed." `
        -FollowUpDate "2026-07-29" `
        -Owner "Andrew" `
        -Source "USL AI OS CRM agenda refresh" `
        -Tags "SPRMM1-26-Q-MF39|EMMA_HIPPENSTEEL|GOVERNMENT_RESPONSE|HUMAN_REVIEW_REQUIRED|NO_EXTERNAL_ACTIONS"

    New-AgendaRecord `
        -AgendaRank "004" `
        -Priority "HIGH" `
        -ContactName "Andrew" `
        -CompanyOrAgency "USL Internal" `
        -Opportunity "KEY, MACHINE / NDT cost-stack" `
        -NsnOrPartNumber "5315-01-352-7432" `
        -ActivityType "INTERNAL_REVIEW_TASK" `
        -Summary "Review KEY, MACHINE NDT cost-stack and QA/evidence implications. Do not mark bid-ready, quote-ready, manufacturing-ready, or externally releasable." `
        -Status "HUMAN_REVIEW_REQUIRED / READINESS_NOT_MARKED" `
        -NextAction "Andrew review cost-stack, evidence, and follow-up needs before any readiness or supplier action." `
        -FollowUpDate "2026-07-03" `
        -Owner "Andrew" `
        -Source "USL AI OS CRM agenda refresh" `
        -Tags "KEY_MACHINE|NDT_COST_STACK|HUMAN_REVIEW_REQUIRED|NO_READINESS_MARKING"

    New-AgendaRecord `
        -AgendaRank "005" `
        -Priority "MEDIUM-HIGH" `
        -ContactName "Konrad Cote" `
        -CompanyOrAgency "PLI Manufacturing / Phoenix Defense" `
        -Opportunity "PLI / Phoenix Defense supplier screening" `
        -NsnOrPartNumber "N/A" `
        -ActivityType "SUPPLIER_FOLLOW_UP_REVIEW" `
        -Summary "Review Konrad / PLI / Phoenix Defense machine-envelope guidance path for smaller machined-part screening. No supplier routing or external contact is authorized by this helper." `
        -Status "SUPPLIER_SCREENING_REVIEW / NO_EXTERNAL_ACTIONS" `
        -NextAction "Andrew review machine-envelope guidance need and decide separate approved follow-up path if needed." `
        -FollowUpDate "2026-07-03" `
        -Owner "Andrew" `
        -Source "USL AI OS CRM agenda refresh" `
        -Tags "KONRAD_COTE|PLI|PHOENIX_DEFENSE|MACHINE_ENVELOPE|SUPPLIER_SCREENING|NO_EXTERNAL_ACTIONS"

    New-AgendaRecord `
        -AgendaRank "006" `
        -Priority "MEDIUM-HIGH" `
        -ContactName "Andrew" `
        -CompanyOrAgency "USL Internal" `
        -Opportunity "Pulley Plate alternate supplier review" `
        -NsnOrPartNumber "3040-01-270-6468 / SPE7L3-26-T-8511" `
        -ActivityType "SUPPLIER_REVIEW_TASK" `
        -Summary "Review alternate supplier path for Plate, Side, Pulley after PLI no-bid due machine-envelope limit. Do not route suppliers or mark quote-ready/bid-ready." `
        -Status "ALTERNATE_SUPPLIER_REVIEW_REQUIRED / NOT_ROUTED" `
        -NextAction "Andrew review alternate supplier options; no supplier routing from this task." `
        -FollowUpDate "Next USL operating review" `
        -Owner "Andrew" `
        -Source "USL AI OS CRM agenda refresh" `
        -Tags "PULLEY_PLATE|SPE7L3-26-T-8511|3040-01-270-6468|ALTERNATE_SUPPLIER_REVIEW|NO_SUPPLIER_ROUTING"
)

$existingRows = @()
if ((Get-Item -LiteralPath $activityPath).Length -gt 0) {
    $existingRows = @(Import-Csv -LiteralPath $activityPath)
}

$existingHeader = @()
$firstLine = Get-Content -LiteralPath $activityPath -TotalCount 1
if ($firstLine) {
    $existingHeader = @($firstLine -split ',' | ForEach-Object { $_.Trim('"') })
}

$existingByKey = @{}
foreach ($row in $existingRows) {
    $key = New-NaturalKey -Row $row
    if (-not $existingByKey.ContainsKey($key)) {
        $existingByKey[$key] = $row
    }
}

$added = 0
$updated = 0
$unchanged = 0
$seenKeys = @{}
$upsertedRows = New-Object System.Collections.Generic.List[object]

foreach ($record in $prepared) {
    $key = New-NaturalKey -Row $record
    $seenKeys[$key] = $true
    if ($existingByKey.ContainsKey($key)) {
        $updated++
    } else {
        $added++
    }
    $upsertedRows.Add((Convert-ToCanonicalRow -Row $record))
}

foreach ($row in $existingRows) {
    $key = New-NaturalKey -Row $row
    if (-not $seenKeys.ContainsKey($key)) {
        $unchanged++
        $upsertedRows.Add((Convert-ToCanonicalRow -Row $row))
    }
}

$agendaRankPresent = $canonical -contains "agenda_rank"
$priorityPresent = $canonical -contains "priority"
$existingHasAgendaRank = $existingHeader -contains "agenda_rank"
$existingHasPriority = $existingHeader -contains "priority"
$naturalKeyFields = @("activity_type","opportunity_or_solicitation","nsn_or_part_number","owner")
$naturalKeyPossible = $true
foreach ($field in $naturalKeyFields) {
    if (-not ($canonical -contains $field)) {
        $naturalKeyPossible = $false
    }
}

$backupPaths = @()
$crmCsvModified = $false

if ($Commit) {
    New-Item -ItemType Directory -Force -Path $backupsDir | Out-Null
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $activityBackup = Join-Path $backupsDir "crm_pipeline_activity_log__backup_$timestamp.csv"
    $changeBackup = Join-Path $backupsDir "apollo_change_log__backup_$timestamp.csv"
    Copy-Item -LiteralPath $activityPath -Destination $activityBackup
    Copy-Item -LiteralPath $changeLogPath -Destination $changeBackup
    $backupPaths += $activityBackup
    $backupPaths += $changeBackup

    $upsertedRows | Export-Csv -LiteralPath $activityPath -NoTypeInformation -Encoding UTF8

    $changeRows = @(Import-Csv -LiteralPath $changeLogPath)
    $changeRows += [pscustomobject]@{
        timestamp = (Get-Date).ToString("s")
        event_type = "CRM_PIPELINE_AGENDA_REFRESH"
        batch_id = "CRM_PIPELINE_AGENDA_REFRESH"
        actor = "Codex local"
        action_source = "tools/usl-crm-pipeline-agenda-refresh.ps1 -Commit"
        status = "SAVED_LOCAL_ONLY"
        notes = "Upserted six CRM agenda records with agenda_rank and priority. Added: $added. Updated: $updated. Protected actions performed: NONE."
    }
    $changeRows | Export-Csv -LiteralPath $changeLogPath -NoTypeInformation -Encoding UTF8
    $crmCsvModified = $true
}

$mode = if ($Commit) { "COMMIT" } else { "DRY_RUN_PREVIEW" }
$completionLabel = if ($Commit) {
    "USL_CRM_PIPELINE_AGENDA_REFRESH_COMPLETE__NO_EXTERNAL_ACTIONS__DESTRUCTIVE_CLEANUP_GATE_LOCKED"
} else {
    "USL_CRM_PIPELINE_AGENDA_REFRESH_HELPER_DRY_RUN_COMPLETE__NO_CRM_WRITES__GATE_LOCKED"
}

$topAgenda = $prepared | Sort-Object agenda_rank | ForEach-Object {
    "- $($_.agenda_rank) / $($_.priority) - $($_.activity_summary)"
}

$backupReportLines = if ($backupPaths.Count -gt 0) {
    $backupPaths | ForEach-Object { "- $_" }
} else {
    @("- None in dry-run mode.")
}

$reportLines = @(
    "# CRM Pipeline Agenda Refresh Report",
    "",
    "Generated: $(Get-Date -Format "s")",
    "",
    "## Mode",
    "",
    $mode,
    "",
    "## Files Read",
    "",
    "- $activityPath",
    "- $changeLogPath",
    "",
    "## Report Path",
    "",
    $reportPath,
    "",
    "## Prepared Agenda Records",
    ""
)
$reportLines += $topAgenda
$reportLines += @(
    "",
    "## Upsert Summary",
    "",
    "- Prepared records: $($prepared.Count)",
    "- Added count: $added",
    "- Updated count: $updated",
    "- Existing rows preserved: $unchanged",
    "- CRM CSV modified: $crmCsvModified",
    "- Backups created: $($backupPaths.Count)",
    "",
    "## Required Field Checks",
    "",
    "- agenda_rank in canonical fields: $agendaRankPresent",
    "- priority in canonical fields: $priorityPresent",
    "- Existing CRM log already had agenda_rank: $existingHasAgendaRank",
    "- Existing CRM log already had priority: $existingHasPriority",
    "",
    "## Natural-Key Upsert",
    "",
    "Natural-key upsert possible: $naturalKeyPossible",
    "",
    "Natural-key fields:",
    "",
    "- activity_type",
    "- opportunity_or_solicitation",
    "- nsn_or_part_number",
    "- owner",
    "",
    "## CRM Write Behavior",
    "",
    "- Dry-run default preserved: $(-not $Commit)",
    "- Commit passed: $Commit",
    "- CRM CSV writes performed: $crmCsvModified",
    "",
    "## Backup Paths",
    ""
)
$reportLines += $backupReportLines
$reportLines += @(
    "",
    "## Safety",
    "",
    "Protected actions performed: NONE.",
    "",
    "No emails, Gmail drafts, supplier contact, government contact, TDMT/DISA/DLA contact, drawing pull, bid/quote submission, readiness marking, Google Drive modification, live Apollo mutation, external CRM mutation, source cleanup, push, PR update, or destructive-gate unlock was performed.",
    "",
    "Completion label:",
    "",
    $completionLabel
)

$reportLines | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Output "MODE=$mode"
Write-Output "SCRIPT_PATH=$PSCommandPath"
Write-Output "REPORT_PATH=$reportPath"
Write-Output "PREPARED_RECORDS=$($prepared.Count)"
Write-Output "ADDED_COUNT=$added"
Write-Output "UPDATED_COUNT=$updated"
Write-Output "PRESERVED_EXISTING_COUNT=$unchanged"
Write-Output "AGENDA_RANK_PRESENT=$agendaRankPresent"
Write-Output "PRIORITY_PRESENT=$priorityPresent"
Write-Output "NATURAL_KEY_UPSERT_POSSIBLE=$naturalKeyPossible"
Write-Output "CRM_CSV_MODIFIED=$crmCsvModified"
Write-Output "PROTECTED_ACTIONS_PERFORMED=NONE"
Write-Output $completionLabel
