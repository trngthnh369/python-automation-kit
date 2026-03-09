<#
.SYNOPSIS
    Installs the Python Automation Kit into the current project's agent skills directory.
.PARAMETER Agent
    Target agent: antigravity, claude-code, gemini-cli, cursor
#>
param(
    [string]$Agent = ""
)

$KitName = "python-automation-kit"
$KitRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (!(Test-Path "$KitRoot\kit.json")) { $KitRoot = Split-Path -Parent $PSScriptRoot }

# Auto-detect agent
if (-not $Agent) {
    if (Test-Path ".agents") { $Agent = "antigravity" }
    elseif (Test-Path ".claude") { $Agent = "claude-code" }
    elseif (Test-Path ".gemini") { $Agent = "gemini-cli" }
    elseif (Test-Path ".cursor") { $Agent = "cursor" }
    else { $Agent = "antigravity" }
}

$SkillsDir = switch ($Agent) {
    "antigravity" { ".agents\skills\$KitName" }
    "claude-code" { ".claude\skills\$KitName" }
    "gemini-cli"  { ".gemini\skills\$KitName" }
    "cursor"      { ".cursor\skills\$KitName" }
}

Write-Host "🐍 Installing $KitName for $Agent..." -ForegroundColor Cyan

if (Test-Path $SkillsDir) { Remove-Item $SkillsDir -Recurse -Force }
New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null

$items = @("_moc.md","_registry.yaml","kit.json","tier-1-orchestrators","tier-2-hubs","tier-3-utilities","tier-4-domains")
foreach ($item in $items) {
    $src = Join-Path $KitRoot $item
    if (Test-Path $src) { Copy-Item $src -Destination $SkillsDir -Recurse -Force }
}

Write-Host "✅ Installed to $SkillsDir" -ForegroundColor Green
Write-Host "📖 Entry point: $SkillsDir\_moc.md" -ForegroundColor Yellow
