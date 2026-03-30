<#
.SYNOPSIS
    Start Harmonia using the recommended developer stack

.DESCRIPTION
    Thin wrapper around the developer startup flow.
    Starts core infrastructure plus the main tools layer and exposes
    core data services on localhost for development.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - OpenWebUI
    - MLflow
    - Adminer
    - Direct localhost access to core data services

.EXAMPLE
    .\start-dev.ps1

.NOTES
    Use this when you want the default stack plus direct local access
    to databases and data services for scripts, notebooks, and tooling.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$devScript = Join-Path $PSScriptRoot "up-dev-tools.ps1"
$envFile = Join-Path $repoRoot "config\env\.env"

if (-not (Test-Path $envFile)) {
    Write-Error "Missing $envFile. Create it from config/env/.env.example before starting the stack."
    exit 2
}

if (-not (Test-Path $devScript)) {
    Write-Error "Missing developer startup script: $devScript"
    exit 2
}

Write-Host "Starting Harmonia - Developer Stack" -ForegroundColor Green
Write-Host "This starts the default stack plus direct localhost access to core data services." -ForegroundColor Cyan
Write-Host "Main entry point: http://ai.localhost" -ForegroundColor Yellow
Write-Host "Direct access: PostgreSQL 5432, MongoDB 27017, Qdrant 6333, MinIO 9000" -ForegroundColor Yellow

& $devScript
exit $LASTEXITCODE
