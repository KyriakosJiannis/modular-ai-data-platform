<#
.SYNOPSIS
    Start Harmonia - Core + Tools

.DESCRIPTION
    Starts the core infrastructure plus user-facing tools.
    This is the recommended stack for most development work.

    Stack includes:
    - Core infrastructure (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)
    - OpenWebUI (chat interface for LLM interaction)
    - MLflow (experiment tracking & model registry)
    - Adminer (database administration UI)

.EXAMPLE
    .\up-tools.ps1
    # Starts core + tools

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Uses docker-compose.yml (base) + docker-compose.tools.yml (overlay)

    Service URLs:
    - Dashboard: http://ai.localhost
    - OpenWebUI: http://openwebui.localhost
    - MLflow: http://mlflow.localhost
    - Adminer: http://db.localhost

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

# Build compose command with base + tools overlay
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "-f", "docker-compose.tools.yml",
    "--profile", "infra",
    "--profile", "tools",
    "up",
    "-d",
    "--remove-orphans"
)

Write-Host "Starting Harmonia - Core + Tools" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan

Push-Location $composeDir
try {
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Stack started successfully" -ForegroundColor Green
        Write-Host "Dashboard: http://ai.localhost" -ForegroundColor Cyan
        Write-Host "OpenWebUI: http://openwebui.localhost" -ForegroundColor Cyan
        Write-Host "MLflow: http://mlflow.localhost" -ForegroundColor Cyan
        Write-Host "Adminer: http://db.localhost" -ForegroundColor Cyan
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
