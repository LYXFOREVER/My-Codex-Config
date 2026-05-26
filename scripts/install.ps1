param(
    [switch]$SkipPull
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $RepoRoot

if (-not $SkipPull) {
    git pull --ff-only
}

if ($env:CODEX_HOME) {
    $CodexHome = $env:CODEX_HOME
} else {
    $CodexHome = Join-Path $env:USERPROFILE ".codex"
}

$SkillsDest = Join-Path $CodexHome "skills"
New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null

Copy-Item -Path (Join-Path $RepoRoot "AGENTS.md") -Destination (Join-Path $CodexHome "AGENTS.md") -Force

$SkillsSrc = Join-Path $RepoRoot "skills"
Get-ChildItem -Path $SkillsSrc -Directory | ForEach-Object {
    $Dest = Join-Path $SkillsDest $_.Name
    if (Test-Path $Dest) {
        Remove-Item -Path $Dest -Recurse -Force
    }
    Copy-Item -Path $_.FullName -Destination $Dest -Recurse -Force
}

Write-Host "Installed Codex config to: $CodexHome"
Write-Host "Installed skills to: $SkillsDest"
