<#
.SYNOPSIS
    Rebuild and validate the USL AI Context Bus, then print key paths.

.DESCRIPTION
    Windows helper for the USL AI Context Bus. Runs the snapshot builder and the
    validator, then prints the paths to the snapshot, active tasks, and the latest
    handoff directory. No external APIs, no secrets.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\export-usl-context.ps1
#>

$ErrorActionPreference = "Stop"

# Resolve repo root as the parent of this script's folder.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

# Pick a Python launcher.
$Python = $null
foreach ($candidate in @("python", "python3", "py")) {
    if (Get-Command $candidate -ErrorAction SilentlyContinue) {
        $Python = $candidate
        break
    }
}
if (-not $Python) {
    Write-Error "Python not found on PATH. Install Python 3 and retry."
    exit 1
}

Write-Host "Building context snapshot..." -ForegroundColor Cyan
& $Python (Join-Path $RepoRoot "scripts\build_context_snapshot.py")
if ($LASTEXITCODE -ne 0) { Write-Error "Snapshot build failed."; exit $LASTEXITCODE }

Write-Host "Validating context bus..." -ForegroundColor Cyan
& $Python (Join-Path $RepoRoot "scripts\validate_context_bus.py")
$ValidateExit = $LASTEXITCODE

Write-Host ""
Write-Host "Key paths:" -ForegroundColor Cyan
Write-Host ("  Snapshot:     " + (Join-Path $RepoRoot "context\USL_CONTEXT_SNAPSHOT.md"))
Write-Host ("  Active tasks: " + (Join-Path $RepoRoot "context\USL_ACTIVE_TASKS.md"))

$HandoffDir = Join-Path $RepoRoot "context\handoffs"
$LatestHandoff = Get-ChildItem -Path $HandoffDir -Filter *.md -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne "README.md" } |
    Sort-Object Name |
    Select-Object -Last 1
if ($LatestHandoff) {
    Write-Host ("  Latest handoff: " + $LatestHandoff.FullName)
} else {
    Write-Host ("  Latest handoff: (none yet in " + $HandoffDir + ")")
}

if ($ValidateExit -ne 0) {
    Write-Warning "Context bus validation reported issues (exit $ValidateExit)."
    exit $ValidateExit
}
Write-Host ""
Write-Host "Context bus PASS." -ForegroundColor Green
