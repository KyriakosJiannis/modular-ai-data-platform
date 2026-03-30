<#
.SYNOPSIS
    Start Harmonia - Core + Tools + Monitoring

.DESCRIPTION
    Starts the complete platform stack including observability tools.
    Use this when you need metrics, dashboards, and container monitoring.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - Tools (OpenWebUI, MLflow, Adminer)
    - Monitoring (Prometheus, Grafana, cAdvisor, Node Exporter)

.EXAMPLE
    .\up-monitoring.ps1
    # Starts core + tools + monitoring

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Uses docker-compose.yml + docker-compose.tools.yml + docker-compose.monitoring.yml

    Service URLs:
    - Dashboard: http://ai.localhost
    - OpenWebUI: http://openwebui.localhost
    - MLflow: http://mlflow.localhost
    - Adminer: http://db.localhost
    - Prometheus: http://prometheus.localhost or http://127.0.0.1:9090
    - Grafana: http://grafana.localhost or http://127.0.0.1:3001
    - cAdvisor: http://cadvisor.localhost or http://127.0.0.1:8082

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

# Build compose command with base + tools + monitoring overlays
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "-f", "docker-compose.tools.yml",
    "-f", "docker-compose.monitoring.yml",
    "--profile", "infra",
    "--profile", "tools",
    "--profile", "monitoring",
    "up",
    "-d",
    "--remove-orphans"
)

Write-Host "Starting Harmonia - Core + Tools + Monitoring" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan

Push-Location $composeDir
try {
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack with monitoring started successfully" -ForegroundColor Green
        Write-Host "Dashboard: http://ai.localhost" -ForegroundColor Cyan
        Write-Host "Grafana: http://127.0.0.1:3001 (admin / check .env)" -ForegroundColor Cyan
        Write-Host "Prometheus: http://127.0.0.1:9090" -ForegroundColor Cyan
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
