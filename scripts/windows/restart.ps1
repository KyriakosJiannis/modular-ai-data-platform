<#
.SYNOPSIS
    Restart Harmonia - Modular AI & Data Platform

.DESCRIPTION
    Restarts the supported default platform stack.
    Useful for applying configuration changes or recovering from issues.

    This script:
    1. Stops the default stack
    2. Waits briefly for cleanup
    3. Starts core + tools again

.EXAMPLE
    .\restart.ps1
    # Restarts the default core + tools stack

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example
    Environment:
    - Uses config/env/.env for configuration
    - Restarts docker-compose.yml + docker-compose.tools.yml

    Data:
    - All data is preserved during restart
    - Restart typically takes 10-30 seconds

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
    Write-Error "Missing $envFile. Create it from config/env/.env.example before managing the platform."
    exit 2
}

Write-Host "Restarting Harmonia - Modular AI & Data Platform" -ForegroundColor Green
Write-Host "Using environment: $envFile" -ForegroundColor Cyan

Push-Location $composeDir
try {
    # Stop the supported default stack
    Write-Host "`nStopping services..." -ForegroundColor Yellow
    & docker compose --env-file $envFile -f docker-compose.yml -f docker-compose.tools.yml down

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to stop services"
        exit 1
    }

    # Brief pause for cleanup
    Write-Host "Waiting for cleanup..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    # Start the common stack (core + tools)
    # This is the most common configuration
    Write-Host "Starting services..." -ForegroundColor Yellow
    $composeArgs = @(
        "--env-file", $envFile,
        "-f", "docker-compose.yml",
        "-f", "docker-compose.tools.yml",
        "--profile", "infra",
        "--profile", "tools",
        "up",
        "-d"
    )

    & docker compose @composeArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Platform restarted successfully" -ForegroundColor Green
        Write-Host "Dashboard: http://ai.localhost" -ForegroundColor Cyan
    }

    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
