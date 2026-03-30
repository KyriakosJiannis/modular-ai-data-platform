<#
.SYNOPSIS
    Start Harmonia using the recommended default stack

.DESCRIPTION
    Thin wrapper around the default startup flow.
    Starts core infrastructure plus the main tools layer.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - OpenWebUI
    - MLflow
    - Adminer

.EXAMPLE
    .\start.ps1

.NOTES
    This is the default entry point for first-time local setup.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$defaultScript = Join-Path $PSScriptRoot "up-tools.ps1"
$envFile = Join-Path $repoRoot "config\env\.env"

if (-not (Test-Path $envFile)) {
    Write-Error "Missing $envFile. Create it from config/env/.env.example before starting the stack."
    exit 2
}

if (-not (Test-Path $defaultScript)) {
    Write-Error "Missing default startup script: $defaultScript"
    exit 2
}

Write-Host "Starting Harmonia - Recommended Default Stack" -ForegroundColor Green
Write-Host "This starts core infrastructure plus the main tools layer." -ForegroundColor Cyan
Write-Host "Main entry point: http://ai.localhost" -ForegroundColor Yellow

& $defaultScript
exit $LASTEXITCODE
