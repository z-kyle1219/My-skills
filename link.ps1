<#
link.ps1 - Sync skills from D:\My-skills to each Agent skills folder via junctions.

Usage:
  powershell -ExecutionPolicy Bypass -File D:\My-skills\link.ps1
  powershell -ExecutionPolicy Bypass -File D:\My-skills\link.ps1 -Force

Notes:
  - Default: only create MISSING links; existing links are skipped (idempotent).
  - -Force : rebuild links that point elsewhere / are dangling.
  - Safety: a REAL directory (not a link) is NEVER deleted; only a warning is shown.
  - Uses junctions, so no admin rights needed.
#>
[CmdletBinding()]
param(
    [switch]$Force,
    [string]$Source = 'D:\My-skills',
    [string[]]$Targets = @(
        "$env:USERPROFILE\.workbuddy\skills",
        "$env:APPDATA\AirJelly\skills"
    )
)

$ErrorActionPreference = 'Continue'

function Say($m)  { Write-Host $m }
function Good($m) { Write-Host $m -ForegroundColor Green }
function Warn($m) { Write-Host $m -ForegroundColor Yellow }
function Bad($m)  { Write-Host $m -ForegroundColor Red }

Say "Source: $Source"
Say "Mode  : $(if ($Force) {'-Force (rebuild links)'} else {'default (add missing only)'})"
Say "Target: $($Targets -join ' | ')"
Say ('-' * 60)

if (-not (Test-Path -LiteralPath $Source)) { Bad "Source folder not found: $Source"; exit 1 }

$skills = Get-ChildItem -LiteralPath $Source -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
}
if (-not $skills) { Warn "No skill folder (containing SKILL.md) found under $Source."; exit 0 }
Say "Found $($skills.Count) skill(s): $($skills.Name -join ', ')"
Say ('-' * 60)

$created = 0; $skipped = 0; $rebuilt = 0; $blocked = 0

foreach ($skill in $skills) {
    $skillSrc = $skill.FullName
    foreach ($targetRoot in $Targets) {
        if (-not (Test-Path -LiteralPath $targetRoot)) {
            try { New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null; Good "Created target dir: $targetRoot" }
            catch { Bad "Cannot create target dir $targetRoot : $($_.Exception.Message)"; continue }
        }

        $linkPath = Join-Path $targetRoot $skill.Name
        $label = "  [$($skill.Name)] -> $targetRoot"

        if (-not (Test-Path -LiteralPath $linkPath)) {
            try {
                New-Item -ItemType Junction -Path $linkPath -Target $skillSrc -ErrorAction Stop | Out-Null
                Good "$label  created"; $created++
            } catch {
                Bad "$label  failed to create: $($_.Exception.Message)"
            }
            continue
        }

        $item = Get-Item -LiteralPath $linkPath -Force
        $linkType = $item.LinkType

        if (-not $linkType) {
            Warn "$label  already a REAL directory (not a link) - skipped, not touched."
            Warn "    To switch to a link: back up/move that folder yourself, then rerun."
            $blocked++
            continue
        }

        $curTarget = @($item.Target)[0]
        $sameTarget = $false
        if ($curTarget) {
            try { $sameTarget = ([IO.Path]::GetFullPath($curTarget)).TrimEnd('\') -ieq ($skillSrc.TrimEnd('\')) }
            catch { $sameTarget = ($curTarget -eq $skillSrc) }
        }

        if ($sameTarget) {
            if ($Force) {
                try {
                    [System.IO.Directory]::Delete($linkPath, $false)
                    New-Item -ItemType Junction -Path $linkPath -Target $skillSrc -ErrorAction Stop | Out-Null
                    Good "$label  rebuilt (-Force)"; $rebuilt++
                } catch {
                    Bad "$label  rebuild failed: $($_.Exception.Message)"
                }
            } else {
                Say "$label  already correct, skipped"; $skipped++
            }
        } else {
            if ($Force) {
                try {
                    [System.IO.Directory]::Delete($linkPath, $false)
                    New-Item -ItemType Junction -Path $linkPath -Target $skillSrc -ErrorAction Stop | Out-Null
                    Good "$label  old target [$curTarget] -> repointed to [$skillSrc]"; $rebuilt++
                } catch {
                    Bad "$label  repoint failed: $($_.Exception.Message)"
                }
            } else {
                Warn "$label  link points to [$curTarget] (expected $skillSrc) - use -Force to repoint."
                $blocked++
            }
        }
    }
}

Say ('-' * 60)
Good "Done: created $created | rebuilt $rebuilt | skipped $skipped | need attention $blocked"
if ($blocked -gt 0) { Warn "$blocked item(s) need manual attention (see warnings above)." }
Say "Tip: if a new skill does not show up in an Agent, restart it or click Refresh in its settings."
