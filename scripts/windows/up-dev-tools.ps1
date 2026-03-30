<#
.SYNOPSIS
    Start Harmonia - Core + Tools + Dev Mode

.DESCRIPTION
    Starts the core infrastructure plus user-facing tools with development mode enabled.
    This configuration exposes database ports to localhost for direct access.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - OpenWebUI (chat interface for LLM interaction)
    - MLflow (experiment tracking & model registry)
    - Adminer (database administration UI)
    - Dev mode (direct database access on localhost)

    Dev mode exposes:
    - PostgreSQL: localhost:5432
    - MongoDB: localhost:27017
    - Qdrant: localhost:6333, localhost:6334
    - MinIO: localhost:9000

.EXAMPLE
    .\up-dev-tools.ps1
    # Starts core + tools + dev mode

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Uses docker-compose.yml (base) + docker-compose.tools.yml + docker-compose.dev-core.yml

    Service URLs:
    - Dashboard: http://ai.localhost
    - OpenWebUI: http://openwebui.localhost
    - MLflow: http://mlflow.localhost
    - Adminer: http://db.localhost

    Database Access (Dev Mode):
    - PostgreSQL: localhost:5432
    - MongoDB: localhost:27017
    - Qdrant: localhost:6333

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
    Write-Error "Missing $envFile. Create it from config/env/.env.example before starting the stack."
    exit 2
}

# Build compose command with base + tools + dev-core overlay
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "-f", "docker-compose.tools.yml",
    "-f", "docker-compose.dev-core.yml",
    "--profile", "infra",
    "--profile", "tools",
    "up",
    "-d",
    "--remove-orphans"
)

Write-Host "Starting Harmonia - Core + Tools + Dev Mode" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan
Write-Host "Dev mode: Database ports exposed to localhost" -ForegroundColor Yellow

Push-Location $composeDir
try {
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack started successfully" -ForegroundColor Green
        Write-Host "`nService URLs:" -ForegroundColor Cyan
        Write-Host "  Dashboard: http://ai.localhost" -ForegroundColor White
        Write-Host "  OpenWebUI: http://openwebui.localhost" -ForegroundColor White
        Write-Host "  MLflow: http://mlflow.localhost" -ForegroundColor White
        Write-Host "  Adminer: http://db.localhost" -ForegroundColor White
        Write-Host "`nDatabase Access (Dev Mode):" -ForegroundColor Yellow
        Write-Host "  PostgreSQL: localhost:5432" -ForegroundColor White
        Write-Host "  MongoDB: localhost:27017" -ForegroundColor White
        Write-Host "  Qdrant: localhost:6333" -ForegroundColor White
        Write-Host "  MinIO: localhost:9000" -ForegroundColor White
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
