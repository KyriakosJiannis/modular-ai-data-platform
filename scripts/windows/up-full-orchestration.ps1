<#
.SYNOPSIS
    Start Harmonia - Complete Stack with Orchestration

.DESCRIPTION
    Starts the complete local platform stack with orchestration services.
    This is the most comprehensive configuration including monitoring and orchestration.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - Tools (OpenWebUI, MLflow, Adminer)
    - Monitoring (Prometheus, Grafana, cAdvisor, Node Exporter)
    - Orchestration (Prefect Server, Prefect Agent, Dagster Web, Dagster Daemon)
    - Dev overrides (local database port exposure)

    Use this when you need the complete platform with all features.

.EXAMPLE
    .\up-full-orchestration.ps1
    # Starts complete platform with orchestration and monitoring

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Uses docker-compose.yml + tools + monitoring + orchestration + dev overlays

    Service URLs:
    - Dashboard: http://ai.localhost
    - OpenWebUI: http://openwebui.localhost
    - MLflow: http://mlflow.localhost
    - Prefect: http://prefect.localhost
    - Dagster: http://dagster.localhost
    - Grafana: http://127.0.0.1:3001
    - Prometheus: http://127.0.0.1:9090

    Local Database Access:
    - PostgreSQL: localhost:5432
    - MongoDB: localhost:27017
    - Qdrant: localhost:6333
    - MinIO: localhost:9000

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

# Build compose command with all overlays
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "-f", "docker-compose.tools.yml",
    "-f", "docker-compose.monitoring.yml",
    "-f", "docker-compose.orchestration.yml",
    "-f", "docker-compose.dev-core.yml",
    "-f", "docker-compose.dev-orchestration.yml",
    "--profile", "infra",
    "--profile", "tools",
    "--profile", "monitoring",
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

Write-Host "Starting Harmonia - Complete Stack with Orchestration (staged startup)" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan
Write-Host "Stack: Core + Tools + Monitoring + Orchestration + Dev Access" -ForegroundColor Yellow

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

    # Step 3: Start remaining services (tools + monitoring + orchestration + dev)
    Write-Host "[3/3] Starting remaining services (tools + monitoring + orchestration + dev)..." -ForegroundColor Yellow
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Complete stack with orchestration started successfully" -ForegroundColor Green
        Write-Host "`nService URLs:" -ForegroundColor Cyan
        Write-Host "  Dashboard: http://ai.localhost" -ForegroundColor Cyan
        Write-Host "  OpenWebUI: http://openwebui.localhost" -ForegroundColor Cyan
        Write-Host "  MLflow: http://mlflow.localhost" -ForegroundColor Cyan
        Write-Host "  Prefect: http://prefect.localhost" -ForegroundColor Cyan
        Write-Host "  Dagster: http://dagster.localhost" -ForegroundColor Cyan
        Write-Host "  Grafana: http://127.0.0.1:3001" -ForegroundColor Cyan
        Write-Host "  Prometheus: http://127.0.0.1:9090" -ForegroundColor Cyan
        Write-Host "`nLocal Database Access:" -ForegroundColor Cyan
        Write-Host "  PostgreSQL: localhost:5432" -ForegroundColor Cyan
        Write-Host "  MongoDB: localhost:27017" -ForegroundColor Cyan
        Write-Host "  Qdrant: localhost:6333" -ForegroundColor Cyan
        Write-Host "  MinIO: localhost:9000" -ForegroundColor Cyan
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
