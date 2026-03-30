<#
.SYNOPSIS
    Start Harmonia - Core + Tools + Orchestration

.DESCRIPTION
    Starts the platform with orchestration services (Prefect and Dagster).
    This stack includes all core infrastructure, tools, and workflow orchestration.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - Tools (OpenWebUI, MLflow, Adminer)
    - Orchestration (Prefect Server, Prefect Agent, Dagster Web, Dagster Daemon)

    Use this when you need workflow orchestration for ML pipelines or data workflows.

.EXAMPLE
    .\up-orchestration.ps1
    # Starts platform with orchestration services

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Uses docker-compose.yml + tools + orchestration overlays

    Service URLs:
    - Dashboard: http://ai.localhost
    - OpenWebUI: http://openwebui.localhost
    - MLflow: http://mlflow.localhost
    - Prefect: http://prefect.localhost
    - Dagster: http://dagster.localhost

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

# Build compose command arrays
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "-f", "docker-compose.tools.yml",
    "-f", "docker-compose.orchestration.yml",
    "--profile", "infra",
    "--profile", "tools",
    "--profile", "orchestration",
    "up",
    "-d",
    "--remove-orphans"
)

$infraOnlyArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "--profile", "infra",
    "up",
    "-d",
    "--remove-orphans"
)

Write-Host "Starting Harmonia - Core + Tools + Orchestration (staged startup)" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan
Write-Host "Stack: Core + Tools + Orchestration" -ForegroundColor Yellow

Push-Location $composeDir
try {
    # Step 1: Start core infrastructure only
    Write-Host "[1/3] Starting core infrastructure (infra profile)..." -ForegroundColor Yellow
    & docker compose @infraOnlyArgs
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to start core infrastructure."; exit 1 }

    # Step 2: Initialize orchestration databases
    Write-Host "[2/3] Initializing orchestration databases..." -ForegroundColor Yellow
    & "$PSScriptRoot\init-orchestration-db.ps1"
    if ($LASTEXITCODE -ne 0) { Write-Error "Database initialization failed."; exit 1 }

    # Step 3: Start remaining services (tools + orchestration)
    Write-Host "[3/3] Starting remaining services (tools + orchestration)..." -ForegroundColor Yellow
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack with orchestration started successfully" -ForegroundColor Green
        Write-Host "`nService URLs:" -ForegroundColor Cyan
        Write-Host "  Dashboard: http://ai.localhost" -ForegroundColor Cyan
        Write-Host "  OpenWebUI: http://openwebui.localhost" -ForegroundColor Cyan
        Write-Host "  MLflow: http://mlflow.localhost" -ForegroundColor Cyan
        Write-Host "  Prefect: http://prefect.localhost" -ForegroundColor Cyan
        Write-Host "  Dagster: http://dagster.localhost" -ForegroundColor Cyan
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
