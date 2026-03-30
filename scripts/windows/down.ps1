<#
.SYNOPSIS
    Stop Harmonia

.DESCRIPTION
    Stops all running stack services cleanly.
    Preserves data volumes (databases, storage) by default.
    Use -RemoveVolumes to also delete all data.

.PARAMETER RemoveVolumes
    If specified, also removes all data volumes (databases, storage).
    WARNING: This is destructive and cannot be undone.

.EXAMPLE
    .\down.ps1
    # Stops all services, keeps data

.EXAMPLE
    .\down.ps1 -RemoveVolumes
    # Stops all services and deletes all data

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Environment:
    - Uses config/env/.env for configuration
    - Stops all compose layers (base, tools, monitoring, runtime)

    Data Preservation:
    - By default, all data volumes are preserved
    - Use -RemoveVolumes to delete data (destructive)

    Exit Codes:
    - 0: Success
    - 1: Docker Compose error
    - 2: Configuration error
#>

param(
    [switch]$RemoveVolumes
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve paths relative to repository root
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$composeDir = Join-Path $repoRoot "compose"
$envFile = Join-Path $repoRoot "config\env\.env"

# Validate environment file exists
if (-not (Test-Path $envFile)) {
    Write-Error "Missing $envFile. Create it from config/env/.env.example before managing the stack."
    exit 2
}

# Build compose command to stop all layers
# Include all possible compose files so we can stop any running combination
# Note: 'down' command doesn't require profiles - it stops all services from included files
$composeArgs = @(
    "--env-file", $envFile,
    "-f", "docker-compose.yml",
    "-f", "docker-compose.tools.yml",
    "-f", "docker-compose.monitoring.yml",
    "-f", "docker-compose.orchestration.yml",
    "-f", "docker-compose.sqlserver.yml",
    "-f", "docker-compose.runtime.ollama.base.yml",
    "-f", "docker-compose.runtime.ollama.rocm.yml",
    "-f", "docker-compose.runtime.ollama.cuda.yml",
    "-f", "docker-compose.runtime.ollama.cpu.yml",
    "-f", "docker-compose.dev-core.yml",
    "-f", "docker-compose.dev-orchestration.yml",
    "-f", "docker-compose.dev-sqlserver.yml",
    "down",
    "--remove-orphans"
)

# Add volume removal flag if requested
if ($RemoveVolumes) {
    $composeArgs += "-v"
Write-Host "Stopping Harmonia and removing all data volumes" -ForegroundColor Red
    Write-Host "WARNING: This will delete all databases and storage data!" -ForegroundColor Yellow
}
else {
Write-Host "Stopping Harmonia (data preserved)" -ForegroundColor Green
}

Write-Host "Using environment: $envFile" -ForegroundColor Cyan

Push-Location $composeDir
try {
    & docker compose @composeArgs
    if ($LASTEXITCODE -eq 0) {
        if ($RemoveVolumes) {
            Write-Host "`n✅ Stack stopped and all data removed" -ForegroundColor Green
        }
        else {
            Write-Host "`n✅ Stack stopped successfully" -ForegroundColor Green
            Write-Host "Data preserved in volumes/" -ForegroundColor Cyan
        }
    }
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
