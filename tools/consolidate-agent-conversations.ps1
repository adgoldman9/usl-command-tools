<#
.SYNOPSIS
    Consolidate local ChatGPT / Codex / Claude / Claude Code conversation exports,
    handoffs, and archives into the USL AI Operating System archive root.

.DESCRIPTION
    Copy-first, non-destructive local file organization. Discovers candidate
    conversation/export/handoff files under common local locations, categorizes
    them, computes SHA256, handles name collisions and duplicates, copies into a
    controlled archive, verifies hashes, and writes manifests and reports.

    Originals are never moved, deleted, or modified. No external actions, no APIs,
    no uploads, no links. Files matching secret/credential patterns are skipped and
    recorded, not copied.

    Run with -DryRun first to review discovery before copying.

.PARAMETER UslOsRoot
    Primary USL AI Operating System root. Must already exist.

.PARAMETER ArchiveRoot
    Target archive root. Defaults to
    <UslOsRoot>\10_Agent_Operating_Model\agent_conversation_archive.

.PARAMETER SourceRoots
    Folders to search. Defaults to Downloads, Documents, OneDrive\Documents,
    OneDrive\Desktop, and Desktop for the current user profile.

.PARAMETER DryRun
    Discover, hash, categorize, and write manifests/reports WITHOUT copying.

.PARAMETER MaxSecretScanBytes
    Max size of a text file to scan for secret patterns (larger text files are
    copied without a content scan but are still name/extension screened).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\consolidate-agent-conversations.ps1 -DryRun

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\consolidate-agent-conversations.ps1
#>

[CmdletBinding()]
param(
    [string]$UslOsRoot = "C:\Users\motor\OneDrive\Documents\USL_AI_Operating_System",
    [string]$ArchiveRoot,
    [string[]]$SourceRoots,
    [switch]$DryRun,
    [int]$MaxSecretScanBytes = 5242880
)

$ErrorActionPreference = "Stop"
$startTime = Get-Date

# ---------------------------------------------------------------------------
# Phase 0 — Preflight
# ---------------------------------------------------------------------------

if (-not $ArchiveRoot) {
    $ArchiveRoot = Join-Path $UslOsRoot "10_Agent_Operating_Model\agent_conversation_archive"
}
if (-not $SourceRoots) {
    $userProfile = $env:USERPROFILE
    $SourceRoots = @(
        (Join-Path $userProfile "Downloads"),
        (Join-Path $userProfile "Documents"),
        (Join-Path $userProfile "OneDrive\Documents"),
        (Join-Path $userProfile "OneDrive\Desktop"),
        (Join-Path $userProfile "Desktop")
    )
    # Honor the default profile referenced in the task spec if it differs.
    $motorRoots = @(
        "C:\Users\motor\Downloads",
        "C:\Users\motor\Documents",
        "C:\Users\motor\OneDrive\Documents",
        "C:\Users\motor\OneDrive\Desktop",
        "C:\Users\motor\Desktop"
    )
    foreach ($r in $motorRoots) { if ($SourceRoots -notcontains $r) { $SourceRoots += $r } }
}

if (-not (Test-Path -LiteralPath $UslOsRoot)) {
    Write-Error "USL OS root not found: $UslOsRoot. Confirm the path and retry."
    exit 1
}

$categories = @("ChatGPT", "Codex", "Claude", "Claude_Code", "Raw_Exports")
$supportFolders = @("Manifests", "Migration_Reports")
foreach ($sub in ($categories + $supportFolders + @("Unknown_AI_Conversation"))) {
    $p = Join-Path $ArchiveRoot $sub
    if (-not (Test-Path -LiteralPath $p)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
    }
}
# In DryRun we still need the support folders to write reports into.
foreach ($sub in $supportFolders) {
    $p = Join-Path $ArchiveRoot $sub
    if (-not (Test-Path -LiteralPath $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}

$archiveFullLower = (Resolve-Path -LiteralPath $ArchiveRoot).Path.ToLower().TrimEnd('\') + '\'

$manifestCsv  = Join-Path $ArchiveRoot "Manifests\conversation_archive_manifest.csv"
$manifestJson = Join-Path $ArchiveRoot "Manifests\conversation_archive_manifest.json"
$reportMd     = Join-Path $ArchiveRoot "Migration_Reports\conversation_archive_migration_report.md"
$dupMd        = Join-Path $ArchiveRoot "Migration_Reports\conversation_archive_duplicates_report.md"
$skipMd       = Join-Path $ArchiveRoot "Migration_Reports\conversation_archive_skipped_items.md"

# ---------------------------------------------------------------------------
# Discovery configuration
# ---------------------------------------------------------------------------

$keywords = @(
    "chatgpt", "openai", "codex", "claude", "claude code", "claude-code",
    "anthropic", "cowork", "conversation", "conversations", "chat export",
    "exported chat", "handoff", "chat_handoff", "gpt"
)

$allowedExt = @(".md", ".txt", ".json", ".jsonl", ".csv", ".html", ".pdf", ".docx", ".xlsx", ".zip")

# Path segments that disqualify a file outright.
$excludedSegments = @(
    "\appdata\", "\.git\", "\.claude\", "\.config\", "\.ssh\", "\.gnupg\",
    "\.vscode\", "\node_modules\", "\.venv\", "\venv\", "\__pycache__\",
    "\dist\", "\build\", "\.cache\", "\cache\", "\.npm\", "\.nuget\"
)

# Files that are clearly secrets/auth material -> never copy.
$secretFileNames = @("credentials.json", "token.json")
$secretFileExt   = @(".env", ".pem", ".key", ".p12", ".pfx")

# Content patterns that flag a possible secret.
$secretPatterns = @(
    "API_KEY", "SECRET", "TOKEN", "PASSWORD", "PRIVATE KEY", "CLIENT_SECRET",
    "MFA", "RECOVERY CODE", "ACCESS_TOKEN", "REFRESH_TOKEN",
    "BEGIN RSA PRIVATE KEY", "BEGIN OPENSSH PRIVATE KEY"
)
$textExt = @(".md", ".txt", ".json", ".jsonl", ".csv", ".html")

function Test-ExcludedSegment([string]$fullPathLower) {
    foreach ($seg in $excludedSegments) { if ($fullPathLower.Contains($seg)) { return $true } }
    return $false
}

function Test-SecretFile($file) {
    if ($secretFileNames -contains $file.Name.ToLower()) { return $true }
    if ($secretFileExt -contains $file.Extension.ToLower()) { return $true }
    if ($file.Name.ToLower() -eq ".env") { return $true }
    return $false
}

function Test-KeywordMatch([string]$fullPathLower) {
    foreach ($kw in $keywords) { if ($fullPathLower.Contains($kw)) { return $true } }
    return $false
}

function Get-CategoryFor([string]$pathLower) {
    if ($pathLower -match "claude[ _-]?code" -or $pathLower.Contains("cowork") -or $pathLower.Contains("claude-code")) { return "Claude_Code" }
    if ($pathLower.Contains("codex")) { return "Codex" }
    if ($pathLower.Contains("chatgpt") -or $pathLower.Contains("openai") -or $pathLower.Contains("gpt")) { return "ChatGPT" }
    if ($pathLower.Contains("claude") -or $pathLower.Contains("anthropic") -or $pathLower.Contains("claude.ai")) { return "Claude" }
    return $null
}

function Get-RawExportCategory($file) {
    $ext = $file.Extension.ToLower()
    if ($ext -in @(".zip", ".json", ".jsonl", ".html")) { return "Raw_Exports" }
    return $null
}

function ConvertTo-SafeToken([string]$text) {
    return ($text -replace "[^A-Za-z0-9]", "_")
}

# ---------------------------------------------------------------------------
# Phase 1 — Discovery
# ---------------------------------------------------------------------------

$candidates = New-Object System.Collections.Generic.List[object]
$skipped    = New-Object System.Collections.Generic.List[object]
$seenPaths  = New-Object System.Collections.Generic.HashSet[string]

foreach ($root in $SourceRoots) {
    if (-not (Test-Path -LiteralPath $root)) { continue }
    Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $file = $_
        $full = $file.FullName
        $fullLower = $full.ToLower()

        if ($fullLower.StartsWith($archiveFullLower)) { return }           # exclude archive root (self-copy guard)
        if (Test-ExcludedSegment $fullLower) { return }                    # exclude cache/config/etc.
        if (-not $seenPaths.Add($fullLower)) { return }                    # de-dupe overlapping roots

        if (Test-SecretFile $file) {
            $skipped.Add([pscustomobject]@{ path = $full; reason = "SKIPPED_SECRET_FILE"; review = $true })
            return
        }
        if ($allowedExt -notcontains $file.Extension.ToLower()) { return } # extension filter
        if (-not (Test-KeywordMatch $fullLower)) { return }                # keyword relevance

        # Secret content scan for small text files.
        if ($textExt -contains $file.Extension.ToLower() -and $file.Length -le $MaxSecretScanBytes) {
            try {
                $content = Get-Content -LiteralPath $full -Raw -ErrorAction Stop
                foreach ($pat in $secretPatterns) {
                    if ($content -match [regex]::Escape($pat)) {
                        $skipped.Add([pscustomobject]@{ path = $full; reason = "SKIPPED_POSSIBLE_SECRET_PATTERN ($pat)"; review = $true })
                        return
                    }
                }
            } catch {
                # Unreadable text file -> record and skip rather than risk it.
                $skipped.Add([pscustomobject]@{ path = $full; reason = "SKIPPED_UNREADABLE"; review = $true })
                return
            }
        }

        $candidates.Add($file)
    }
}

# ---------------------------------------------------------------------------
# Phase 2–6 — Hash, categorize, dedupe, collision-handle, copy, verify
# ---------------------------------------------------------------------------

$manifest    = New-Object System.Collections.Generic.List[object]
$duplicates  = New-Object System.Collections.Generic.List[object]
$hashToPrimary = @{}     # sha256 -> destination_path of primary copy
$counts = @{}
foreach ($c in ($categories + @("Unknown_AI_Conversation"))) { $counts[$c] = 0 }
$copyFailures = 0
$copiedCount  = 0
$dupCount     = 0

foreach ($file in $candidates) {
    $full = $file.FullName
    $pathLower = $full.ToLower()

    # SHA256
    try { $hash = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash }
    catch { $hash = "" }

    # Category
    $category = Get-CategoryFor $pathLower
    if (-not $category) { $category = Get-RawExportCategory $file }
    if (-not $category) { $category = "Unknown_AI_Conversation" }

    $row = [ordered]@{
        source_path      = $full
        destination_path = ""
        archive_category = $category
        file_name        = $file.Name
        file_extension   = $file.Extension.ToLower()
        file_size_bytes  = $file.Length
        modified_time    = $file.LastWriteTime.ToString("o")
        sha256           = $hash
        copy_status      = ""
        collision_status = "NONE"
        rename_applied   = $false
        notes            = ""
    }

    # Duplicate (identical content already archived this run)
    if ($hash -and $hashToPrimary.ContainsKey($hash)) {
        $row.copy_status = "DUPLICATE_SKIPPED"
        $row.destination_path = $hashToPrimary[$hash]
        $row.notes = "duplicate of primary copy"
        $dupCount++
        $duplicates.Add([pscustomobject]@{
            primary_destination = $hashToPrimary[$hash]
            duplicate_source    = $full
            sha256              = $hash
            disposition         = "DUPLICATE_SKIPPED (original preserved)"
        })
        $manifest.Add([pscustomobject]$row)
        continue
    }

    $destDir  = Join-Path $ArchiveRoot $category
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $ext      = $file.Extension
    $destName = $file.Name
    $destPath = Join-Path $destDir $destName

    if ($DryRun) {
        $row.copy_status = "DRY_RUN"
        $row.destination_path = $destPath
        if ($hash) { $hashToPrimary[$hash] = $destPath }
        $counts[$category]++
        $manifest.Add([pscustomobject]$row)
        continue
    }

    # Collision handling: same name, different content -> suffix; same content -> already present.
    $alreadyPresent = $false
    if (Test-Path -LiteralPath $destPath) {
        $existingHash = (Get-FileHash -LiteralPath $destPath -Algorithm SHA256).Hash
        if ($existingHash -eq $hash) {
            $alreadyPresent = $true
            $row.collision_status = "SAME_HASH_PRESENT"
        } else {
            $parentToken = ConvertTo-SafeToken (Split-Path -Leaf (Split-Path -Parent $full))
            $destName = "{0}__from_{1}{2}" -f $baseName, $parentToken, $ext
            $destPath = Join-Path $destDir $destName
            $row.rename_applied = $true
            $row.collision_status = "RENAMED_ON_COLLISION"
            $n = 2
            while (Test-Path -LiteralPath $destPath) {
                $h2 = (Get-FileHash -LiteralPath $destPath -Algorithm SHA256).Hash
                if ($h2 -eq $hash) { $alreadyPresent = $true; break }
                $destName = "{0}__from_{1}_{2}{3}" -f $baseName, $parentToken, $n, $ext
                $destPath = Join-Path $destDir $destName
                $n++
            }
        }
    }

    $row.destination_path = $destPath

    if ($alreadyPresent) {
        $row.copy_status = "ALREADY_PRESENT"
        $row.notes = "identical file already in archive"
        if ($hash) { $hashToPrimary[$hash] = $destPath }
        $counts[$category]++
        $manifest.Add([pscustomobject]$row)
        continue
    }

    # Copy + verify
    try {
        Copy-Item -LiteralPath $full -Destination $destPath -ErrorAction Stop
        $destHash = (Get-FileHash -LiteralPath $destPath -Algorithm SHA256).Hash
        if ($destHash -eq $hash) {
            $row.copy_status = "COPIED"
            $copiedCount++
            $counts[$category]++
            if ($hash) { $hashToPrimary[$hash] = $destPath }
        } else {
            $row.copy_status = "FAILED_HASH_MISMATCH"
            $row.notes = "source/destination SHA256 differ; original left intact"
            $copyFailures++
        }
    } catch {
        $row.copy_status = "FAILED_COPY"
        $row.notes = $_.Exception.Message
        $copyFailures++
    }

    $manifest.Add([pscustomobject]$row)
}

# ---------------------------------------------------------------------------
# Phase 2 (write) — Manifests
# ---------------------------------------------------------------------------

$manifest | Export-Csv -LiteralPath $manifestCsv -NoTypeInformation -Encoding UTF8
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestJson -Encoding UTF8

# ---------------------------------------------------------------------------
# Phase 8 — Reports
# ---------------------------------------------------------------------------

$mode = if ($DryRun) { "DRY RUN (no files copied)" } else { "COPY RUN" }
$totalCandidates = $candidates.Count

$report = @()
$report += "# Conversation Archive Migration Report"
$report += ""
$report += "- Task timestamp: $($startTime.ToString('o'))"
$report += "- Mode: $mode"
$report += "- Machine / user: $($env:COMPUTERNAME) / $($env:USERNAME)"
$report += "- USL OS root: $UslOsRoot"
$report += "- Archive root: $ArchiveRoot"
$report += "- Working directory: $((Get-Location).Path)"
$report += ""
$report += "## Source locations searched"
$report += ""
foreach ($r in $SourceRoots) {
    $exists = if (Test-Path -LiteralPath $r) { "found" } else { "missing" }
    $report += "- $r ($exists)"
}
$report += ""
$report += "## Excluded locations / patterns"
$report += ""
$report += "- Archive root (self-copy guard): $ArchiveRoot"
$report += "- Path segments: " + ($excludedSegments -join ", ")
$report += "- Secret file names: " + ($secretFileNames -join ", ")
$report += "- Secret file extensions: " + ($secretFileExt -join ", ")
$report += "- Secret content patterns: " + ($secretPatterns -join ", ")
$report += ""
$report += "## Totals"
$report += ""
$report += "- Total candidate files found: $totalCandidates"
$report += "- Total files copied: $copiedCount"
$report += "- Total duplicates detected: $dupCount"
$report += "- Total skipped items: $($skipped.Count)"
$report += "- Total copy failures: $copyFailures"
$report += ""
$report += "## Archive category counts"
$report += ""
foreach ($c in ($categories + @("Unknown_AI_Conversation"))) { $report += "- ${c}: $($counts[$c])" }
$report += ""
$report += "## Warnings"
$report += ""
if ($copyFailures -gt 0) { $report += "- $copyFailures copy/verify failure(s) — see manifest copy_status." }
if ($counts["Unknown_AI_Conversation"] -gt 0) { $report += "- $($counts['Unknown_AI_Conversation']) file(s) could not be confidently categorized." }
if ($skipped.Count -gt 0) { $report += "- $($skipped.Count) item(s) skipped (possible secrets / unreadable) — review skipped-items report." }
if ($report[-1] -eq "") { $report += "- None." }
$report += ""
$report += "## Protected actions avoided"
$report += ""
$report += "- No files deleted. No files moved. Originals unmodified."
$report += "- No external actions, emails, drafts, uploads, links, or API calls."
$report += "- No secrets/credentials copied."
$report += ""
$report += "## Recommended next step"
$report += ""
$report += "Review the manifest and this migration report before any destructive move/delete/cleanup task."
$report -join "`r`n" | Set-Content -LiteralPath $reportMd -Encoding UTF8

$dup = @()
$dup += "# Conversation Archive Duplicates Report"
$dup += ""
if ($duplicates.Count -eq 0) {
    $dup += "No duplicate (identical SHA256) files detected."
} else {
    foreach ($d in $duplicates) {
        $dup += "## Duplicate"
        $dup += "- Primary copied file: $($d.primary_destination)"
        $dup += "- Duplicate source path: $($d.duplicate_source)"
        $dup += "- SHA256: $($d.sha256)"
        $dup += "- Disposition: $($d.disposition)"
        $dup += ""
    }
}
$dup -join "`r`n" | Set-Content -LiteralPath $dupMd -Encoding UTF8

$skip = @()
$skip += "# Conversation Archive Skipped Items"
$skip += ""
if ($skipped.Count -eq 0) {
    $skip += "No items skipped."
} else {
    foreach ($s in $skipped) {
        $skip += "- Path: $($s.path)"
        $skip += "  - Reason: $($s.reason)"
        $skip += "  - User review recommended: $($s.review)"
        $skip += ""
    }
}
$skip -join "`r`n" | Set-Content -LiteralPath $skipMd -Encoding UTF8

# ---------------------------------------------------------------------------
# Phase 7 — Console safety summary
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "==== USL Conversation Archive Consolidation ($mode) ====" -ForegroundColor Cyan
Write-Host "Archive root:        $ArchiveRoot"
Write-Host "Candidates found:    $totalCandidates"
Write-Host "Copied:              $copiedCount"
Write-Host "Duplicates skipped:  $dupCount"
Write-Host "Skipped (secret/etc):$($skipped.Count)"
Write-Host "Copy failures:       $copyFailures"
Write-Host ""
Write-Host "Manifest (CSV):      $manifestCsv"
Write-Host "Manifest (JSON):     $manifestJson"
Write-Host "Migration report:    $reportMd"
Write-Host "Duplicates report:   $dupMd"
Write-Host "Skipped report:      $skipMd"
Write-Host ""
Write-Host "Originals were not deleted or moved. Archive root was excluded from discovery." -ForegroundColor Green
if ($DryRun) { Write-Host "DRY RUN — no files were copied. Re-run without -DryRun to copy." -ForegroundColor Yellow }
