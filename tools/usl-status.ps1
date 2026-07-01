#requires -Version 7.0
<#
.SYNOPSIS
    USL one-shot operating status. Read-only. Prints repo, path, CRM, and gate state.

.DESCRIPTION
    Prints the whole operating picture in one command. Writes nothing and mutates no
    CRM. Safe to run any time on the Windows machine.

.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File .\tools\usl-status.ps1
#>
[CmdletBinding()]
param(
    [string]$Repo    = "C:\Users\motor\OneDrive\Desktop\USL_Command_Center\07_Codex_Builds\usl-command-tools",
    [string]$UslRoot = "C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System"
)
$ErrorActionPreference = "Continue"
$crmPath = Join-Path $UslRoot "03_Apollo_Outreach\apollo\control"
$phase15 = Join-Path $UslRoot "10_Agent_Operating_Model\ai_os_consolidation_cleanup\Phase_15_NO_GO_Preservation_And_Response_Archive_Handoff_Only"
function YN([bool]$b){ if ($b) { "YES" } else { "NO" } }

Write-Host "==== USL STATUS ====" -ForegroundColor Cyan

Write-Host "`n[Repo]"
if (Test-Path -LiteralPath $Repo) {
    Push-Location $Repo
    Write-Host ("  branch: " + (git branch --show-current))
    Write-Host ("  HEAD:   " + (git rev-parse --short HEAD))
    $st = git status --short --ignored
    Write-Host ("  status: " + (if ($st) { ($st -join " | ") } else { "clean" }))
    Write-Host ("  helper usl-crm-pipeline-agenda-refresh.ps1: " + (YN (Test-Path -LiteralPath (Join-Path $Repo "tools\usl-crm-pipeline-agenda-refresh.ps1"))))
    Pop-Location
} else { Write-Host "  Repo NOT FOUND" }

Write-Host "`n[Paths]"
Write-Host ("  USL AI OS root: " + (YN (Test-Path -LiteralPath $UslRoot)))
Write-Host ("  CRM control:    " + (YN (Test-Path -LiteralPath $crmPath)))
Write-Host ("  Phase 15:       " + (YN (Test-Path -LiteralPath $phase15)))

Write-Host "`n[CRM agenda — top rows]"
$board = Join-Path $crmPath "apollo_sequence_task_board.csv"
if (Test-Path -LiteralPath $board) {
    try {
        $rows = @(Import-Csv -LiteralPath $board)
        Write-Host ("  apollo_sequence_task_board.csv: $($rows.Count) rows")
        $show = $rows | Select-Object -First 6
        foreach ($r in $show) {
            $title = if ($r.PSObject.Properties['title']) { $r.title } elseif ($r.PSObject.Properties['activity_type']) { $r.activity_type } else { "(row)" }
            $stat  = if ($r.PSObject.Properties['current_status']) { $r.current_status } else { "" }
            Write-Host ("   - {0} :: {1}" -f $title, $stat)
        }
    } catch { Write-Host "  board read ERROR: $($_.Exception.Message)" }
} else { Write-Host "  apollo_sequence_task_board.csv NOT FOUND" }

Write-Host "`n[CRM refresh report]"
$rr = Join-Path $crmPath "reports\crm_pipeline_agenda_refresh_report.md"
if (Test-Path -LiteralPath $rr) { Write-Host ("  $rr (modified $((Get-Item -LiteralPath $rr).LastWriteTime))") } else { Write-Host "  (not present)" }

Write-Host "`n[Phase 15 / cleanup gate]"
if (Test-Path -LiteralPath $phase15) {
    $txt = ""
    Get-ChildItem -LiteralPath $phase15 -File -Include *.md,*.csv -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $txt += (Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue) + "`n" }
    Write-Host ("  NO_GO_PRESERVED: " + (YN ($txt -match "NO_GO_PRESERVED")))
    Write-Host ("  NOT_READY:       " + (YN ($txt -match "NOT_READY")))
    Write-Host ("  LOCKED:          " + (YN ($txt -match "LOCKED")))
} else { Write-Host "  Phase 15 folder not accessible" }

Write-Host "`n[Safety]"
Write-Host "  Protected actions performed: NONE. Destructive cleanup gate remains LOCKED." -ForegroundColor Green
