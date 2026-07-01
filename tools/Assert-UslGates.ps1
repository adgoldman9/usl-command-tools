#requires -Version 7.0
<#
.SYNOPSIS
    USL safety-gate assertion helper. Read-only. Verifies USL AI OS paths exist and
    that Phase 15 NO_GO / cleanup-lock states and protected-actions posture are intact.

.DESCRIPTION
    Dot-source or invoke before emitting any completion label. Performs no external
    actions and edits no files. Exits non-zero if a required gate check fails.

.PARAMETER UslRoot
    USL AI OS root.

.PARAMETER RequireNoGoPreserved
    Fail unless NO_GO_PRESERVED is found in the Phase 15 lock/summary files.

.PARAMETER RequireGateLocked
    Fail unless the destructive cleanup gate reads LOCKED / NOT_READY.

.PARAMETER RequireProtectedActionsNone
    Fail if any recent report/log records protected_actions_performed other than NONE.

.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\Assert-UslGates.ps1 -RequireNoGoPreserved -RequireGateLocked -RequireProtectedActionsNone
#>
[CmdletBinding()]
param(
    [string]$UslRoot = "C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System",
    [switch]$RequireNoGoPreserved,
    [switch]$RequireGateLocked,
    [switch]$RequireProtectedActionsNone
)
$ErrorActionPreference = "Stop"

$crmPath  = Join-Path $UslRoot "03_Apollo_Outreach\apollo\control"
$cleanup  = Join-Path $UslRoot "10_Agent_Operating_Model\ai_os_consolidation_cleanup"
$phase15  = Join-Path $cleanup "Phase_15_NO_GO_Preservation_And_Response_Archive_Handoff_Only"

$fail = $false
function Check([string]$name, [bool]$ok, [bool]$required) {
    $status = if ($ok) { "PASS" } elseif ($required) { "FAIL" } else { "WARN" }
    if (-not $ok -and $required) { $script:fail = $true }
    Write-Host ("[{0}] {1}" -f $status, $name)
}

Check "USL AI OS root exists"     (Test-Path -LiteralPath $UslRoot)  $true
Check "CRM control path exists"   (Test-Path -LiteralPath $crmPath)  $true
Check "Phase 15 folder exists"    (Test-Path -LiteralPath $phase15)  $true

# Gather Phase 15 text for token checks.
$phase15Text = ""
if (Test-Path -LiteralPath $phase15) {
    Get-ChildItem -LiteralPath $phase15 -File -Include *.md,*.csv -Recurse -ErrorAction SilentlyContinue |
        ForEach-Object { $phase15Text += (Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue) + "`n" }
}

$hasNoGo   = $phase15Text -match "NO_GO_PRESERVED"
$hasLocked = ($phase15Text -match "LOCKED") -and ($phase15Text -match "NOT_READY")
Check "Phase 15 NO_GO_PRESERVED present"                 $hasNoGo   $RequireNoGoPreserved.IsPresent
Check "Destructive cleanup LOCKED / NOT_READY present"   $hasLocked $RequireGateLocked.IsPresent

# Protected-actions posture across recent reports/logs.
$protectedOk = $true
if ($RequireProtectedActionsNone) {
    $scan = @()
    foreach ($dir in @((Join-Path $crmPath "reports"), $cleanup)) {
        if (Test-Path -LiteralPath $dir) {
            $scan += Get-ChildItem -LiteralPath $dir -File -Include *.md,*.log,*.csv -Recurse -ErrorAction SilentlyContinue
        }
    }
    foreach ($f in $scan) {
        $m = Select-String -LiteralPath $f.FullName -Pattern "protected_actions_performed\s*[:=]\s*(\S+)" -ErrorAction SilentlyContinue
        foreach ($hit in $m) {
            $val = $hit.Matches[0].Groups[1].Value.Trim().TrimEnd('.',',',';')
            if ($val.ToUpper() -ne "NONE") { $protectedOk = $false }
        }
    }
}
Check "protected_actions_performed == NONE where present" $protectedOk $RequireProtectedActionsNone.IsPresent

Write-Host ""
if ($fail) {
    Write-Host "USL GATE ASSERTION: FAIL" -ForegroundColor Red
    exit 1
}
Write-Host "USL GATE ASSERTION: PASS (gate LOCKED; protected actions NONE)" -ForegroundColor Green
exit 0
