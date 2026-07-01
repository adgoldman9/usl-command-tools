#requires -Version 7.0
<#
.SYNOPSIS
    USL Local Command + Access Verification. Read-only except writing one report.

.DESCRIPTION
    Verifies repo state, PowerShell/git commands, USL AI OS path access, CRM
    readability, and that the six CRM-AGENDA-* keys each match exactly 1. Writes a
    timestamped report under docs\local_access_verification. Emits the completion
    label only on a full PASS. Does not edit CRM CSVs and never runs the CRM helper
    with -Commit.

.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\usl-local-access-verification.ps1
#>
[CmdletBinding()]
param(
    [string]$Repo        = "C:\Users\motor\OneDrive\Desktop\USL_Command_Center\07_Codex_Builds\usl-command-tools",
    [string]$UslRoot     = "C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System",
    [string]$ExpectedHead = "fa246115f09122d131448b82b67485bf674777a4",
    [string]$ExpectedBranch = "claude/saved-memory-sync-access-kukbtk"
)
$ErrorActionPreference = "Continue"
$ts = (Get-Date).ToString("yyyyMMdd_HHmmss")
$crmPath = Join-Path $UslRoot "03_Apollo_Outreach\apollo\control"
$phase15 = Join-Path $UslRoot "10_Agent_Operating_Model\ai_os_consolidation_cleanup\Phase_15_NO_GO_Preservation_And_Response_Archive_Handoff_Only"
$fail = $false
$L = New-Object System.Collections.Generic.List[string]
function Add-L($s){ $L.Add($s); Write-Host $s }
function Mark([bool]$ok){ if (-not $ok) { $script:fail = $true }; if ($ok) { "PASS" } else { "FAIL" } }

Add-L "# USL Local Access Verification"
Add-L "- Timestamp: $ts"
Add-L "- Machine/User: $env:COMPUTERNAME / $env:USERNAME"
Add-L ""

Add-L "## Repo"
$branch = ""; $head = ""
if (Test-Path -LiteralPath $Repo) {
    Push-Location $Repo
    $branch = (git branch --show-current)
    $head = (git rev-parse HEAD)
    Add-L ("- branch: $branch [{0}]" -f (Mark ($branch -eq $ExpectedBranch)))
    Add-L ("- HEAD: $head [{0}]" -f (Mark ($head -eq $ExpectedHead)))
    Add-L "- status:"; (git status --short --ignored) | ForEach-Object { Add-L "    $_" }
    Add-L ("- helper usl-crm-pipeline-agenda-refresh.ps1: [{0}]" -f (Mark (Test-Path -LiteralPath (Join-Path $Repo "tools\usl-crm-pipeline-agenda-refresh.ps1"))))
    Pop-Location
} else { Add-L "- Repo NOT FOUND [FAIL]"; $fail = $true }
Add-L ""

Add-L "## Commands"
Add-L ("- PSVersion: " + $PSVersionTable.PSVersion.ToString())
Add-L ("- pwsh: [{0}]" -f (Mark ([bool](Get-Command pwsh -ErrorAction SilentlyContinue))))
Add-L ("- git:  [{0}]" -f (Mark ([bool](Get-Command git  -ErrorAction SilentlyContinue))))
Add-L ""

Add-L "## Paths"
Add-L ("- USL AI OS root: [{0}]" -f (Mark (Test-Path -LiteralPath $UslRoot)))
Add-L ("- CRM control:    [{0}]" -f (Mark (Test-Path -LiteralPath $crmPath)))
Add-L ("- Phase 15:       [{0}]" -f (Mark (Test-Path -LiteralPath $phase15)))
Add-L ""

Add-L "## CRM read (headers + row counts)"
$crmFiles = @("apollo_sequence_task_board.csv","crm_pipeline_activity_log.csv","apollo_change_log.csv","apollo_contact_master.csv","apollo_company_research_notes.csv")
foreach ($cf in $crmFiles) {
    $p = Join-Path $crmPath $cf
    if (Test-Path -LiteralPath $p) {
        try { $rows = @(Import-Csv -LiteralPath $p); $hdr = if ($rows.Count -gt 0) { ($rows[0].PSObject.Properties.Name -join ", ") } else { "(empty)" }; Add-L "- $cf : $($rows.Count) rows | $hdr" }
        catch { Add-L "- $cf : ERROR ($($_.Exception.Message))" }
    } else { Add-L "- $cf : NOT FOUND" }
}
Add-L ""

Add-L "## CRM refresh report presence"
$refreshReport = Join-Path $crmPath "reports\crm_pipeline_agenda_refresh_report.md"
Add-L ("- crm_pipeline_agenda_refresh_report.md: [{0}]" -f (Mark (Test-Path -LiteralPath $refreshReport)))
Add-L ""

Add-L "## Agenda task key counts (expected exactly 1 each)"
$keys = @("CRM-AGENDA-PHASE15-NOGO-REVIEW","CRM-AGENDA-TDMT-ACCESS-FOLLOWUP-20260707","CRM-AGENDA-SPRMM1-26-Q-MF39-DRAWINGS-AVAILABLE","CRM-AGENDA-KEY-MACHINE-NDT-COST-STACK","CRM-AGENDA-KONRAD-PLI-MACHINE-ENVELOPE","CRM-AGENDA-PULLEY-PLATE-ALT-SUPPLIER-REVIEW")
$agendaFiles = @("apollo_sequence_task_board.csv","crm_pipeline_activity_log.csv")
foreach ($key in $keys) {
    $count = 0
    foreach ($cf in $agendaFiles) {
        $p = Join-Path $crmPath $cf
        if (Test-Path -LiteralPath $p) { $m = Select-String -LiteralPath $p -SimpleMatch -Pattern $key -ErrorAction SilentlyContinue; if ($m) { $count += @($m).Count } }
    }
    $ok = ($count -eq 1); if (-not $ok) { $fail = $true }
    Add-L ("- {0}: {1} [{2}]" -f $key, $count, (if($ok){"PASS"}else{"FAIL"}))
}
Add-L ""

Add-L "## Result"
$overall = if ($fail) { "FAIL/PARTIAL" } else { "PASS" }
Add-L "- Overall: $overall"
Add-L "- Protected actions performed: NONE"
Add-L ""
Add-L "> Protected actions performed: NONE. No external actions, no CRM mutation, no cleanup, no push, no PR update, and destructive cleanup gate remains LOCKED."

$outDir = Join-Path $Repo "docs\local_access_verification"
if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$outFile = Join-Path $outDir "local_access_verification_$ts.md"
$L -join "`r`n" | Set-Content -LiteralPath $outFile -Encoding UTF8
Write-Host ""
Write-Host "Report: $outFile" -ForegroundColor Green
if (-not $fail) {
    Write-Host "USL_LOCAL_COMMAND_AND_ACCESS_VERIFICATION_COMPLETE__READ_ONLY_EXCEPT_REPORT__GATE_LOCKED" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "VERIFICATION INCOMPLETE — resolve FAIL items (agenda keys must each be 1)." -ForegroundColor Red
    exit 1
}
