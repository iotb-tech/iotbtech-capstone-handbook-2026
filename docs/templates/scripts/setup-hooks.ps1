#
# IOTBTECH 2026 Capstone - install git hooks (Windows PowerShell)
# Run once per clone:  .\scripts\setup-hooks.ps1
#
# If PowerShell blocks the script, run it as:
#     powershell -ExecutionPolicy Bypass -File .\scripts\setup-hooks.ps1
# or use Git Bash instead:  bash scripts/setup-hooks.sh
#
# This points git at the version-controlled scripts\git-hooks directory
# instead of copying files into .git\hooks. A global core.hooksPath (Husky,
# dotfiles) silently overrides .git\hooks, so a copied hook can look
# installed and do nothing. A repo-local setting always wins.
#
$ErrorActionPreference = "Stop"

git rev-parse --git-dir *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: not inside a git repository. cd to the repo root first." -ForegroundColor Red
    exit 1
}

Set-Location (git rev-parse --show-toplevel)

if (-not (Test-Path "scripts\git-hooks")) {
    Write-Host "Error: scripts\git-hooks not found at the repo root." -ForegroundColor Red
    Write-Host "Copy it from the capstone handbook templates first."
    exit 1
}

$previousGlobal = (git config --global --get core.hooksPath)

git config core.hooksPath scripts/git-hooks

$active = (git config --get core.hooksPath)
if ($active -ne "scripts/git-hooks") {
    Write-Host "Error: failed to set core.hooksPath (got '$active'). Tell the Tech Lead." -ForegroundColor Red
    exit 1
}

Write-Host "Hooks active from scripts/git-hooks for this repository."
Get-ChildItem -File "scripts\git-hooks" | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Host ""
Write-Host "Git runs these hooks on Windows without any chmod step."

if ($previousGlobal) {
    Write-Host ""
    Write-Host "Note: you have a GLOBAL core.hooksPath set ($previousGlobal)."
    Write-Host "      This repo now overrides it locally, which is what we want."
}

Write-Host ""
Write-Host "Now verify it - you WANT the push below to be refused:"
Write-Host ""
Write-Host "    git checkout main"
Write-Host "    git push"
Write-Host "    # -> BLOCKED: direct push to 'main' is not allowed."
Write-Host "    git checkout dev"
Write-Host ""
Write-Host "If that push SUCCEEDED, the hook is not active. Tell the Tech Lead."
