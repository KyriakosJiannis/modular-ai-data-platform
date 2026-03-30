<#
.SYNOPSIS
    Start Harmonia - Complete Local Stack (Core + Tools + Monitoring + Dev)

.DESCRIPTION
    Starts the complete local platform stack with all features and developer conveniences.
    This is the "full" platform for comprehensive local development and testing.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - Tools (OpenWebUI, MLflow, Adminer)
    - Monitoring (Prometheus, Grafana, cAdvisor, Node Exporter)
    - Dev overrides (local database port exposure for developer tools)

    Use this when you want the complete platform with all observability and local access.

.EXAMPLE
    .\up-full.ps1
    # Starts complete local platform

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Uses docker-compose.yml + tools + monitoring + dev overlays

    Local Database Access (via dev override):
    - PostgreSQL: localhost:5432
    - MongoDB: localhost:27017
    - Qdrant: localhost:6333
    - MinIO: localhost:9000

    Service URLs:
    - Dashboard: http://ai.localhost
    - OpenWebUI: http://openwebui.localhost
    - MLflow: http://mlflow.localhost
    - Adminer: http://db.localhost
    - Prometheus: http://prometheus.localhost or http://127.0.0.1:9090
    - Grafana: http://127.0.0.1:3001 (admin / check .env)
    - cAdvisor: http://127.0.0.1:8082

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

# Build compose command with base + tools + monitoring + dev overlays
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "-f", "docker-compose.tools.yml",
    "-f", "docker-compose.monitoring.yml",
    "-f", "docker-compose.dev-core.yml",
    "--profile", "infra",
    "--profile", "tools",
    "--profile", "monitoring",
    "up",
    "-d",
    "--remove-orphans"
)

Write-Host "Starting Harmonia - Complete Local Stack" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan
Write-Host "Stack: Core + Tools + Monitoring + Dev Access" -ForegroundColor Yellow

Push-Location $composeDir
try {
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Complete stack started successfully" -ForegroundColor Green
        Write-Host "`nService URLs:" -ForegroundColor Cyan
        Write-Host "  Dashboard: http://ai.localhost" -ForegroundColor Cyan
        Write-Host "  OpenWebUI: http://openwebui.localhost" -ForegroundColor Cyan
        Write-Host "  MLflow: http://mlflow.localhost" -ForegroundColor Cyan
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
