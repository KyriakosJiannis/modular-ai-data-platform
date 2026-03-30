<#
.SYNOPSIS
    Start Harmonia - Core Infrastructure Only

.DESCRIPTION
    Starts only the core infrastructure layer (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard).
    This is the minimal platform needed for development.

    Stack includes:
    - Traefik (reverse proxy & service discovery)
    - PostgreSQL (relational database)
    - MongoDB (document store)
    - Qdrant (vector database)
    - MinIO (S3-compatible object storage)
    - Dashboard (control plane UI)

.EXAMPLE
    .\up-core.ps1
    # Starts core infrastructure

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Uses docker-compose.yml (canonical base)

    Exit Codes:
    - 0: Success
    - 1: Docker Compose error
    - 2: Configuration error
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve paths relative to repository root
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$composeDir = Join-Path $repoRoot "compose"
$envFile = Join-Path $repoRoot "config\env\.env"

# Validate environment file exists
if (-not (Test-Path $envFile)) {
    Write-Error "Missing $envFile. Create it from config/env/.env.example before starting the platform."
    exit 2
}

# Build compose command with canonical base file
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "--profile", "infra",
    "up",
    "-d",
    "--remove-orphans"
)

Write-Host "Starting Harmonia - Core Infrastructure" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan

Push-Location $composeDir
try {
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Core infrastructure started successfully" -ForegroundColor Green
        Write-Host "Dashboard: http://ai.localhost" -ForegroundColor Cyan
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
