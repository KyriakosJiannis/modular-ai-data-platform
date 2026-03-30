<#
.SYNOPSIS
    Display the status of running Harmonia services

.DESCRIPTION
    Shows a clean, human-friendly table of all running stack containers.
    Displays container names, status, and port mappings.

.EXAMPLE
    .\status.ps1
    # Shows all running platform containers

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled

    Output:
    - Container name
    - Current status (running, exited, etc.)
    - Port mappings

    Exit Codes:
    - 0: Success
    - 1: Docker error
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$platformServices = @(
    "traefik",
    "dashboard",
    "postgres",
    "mongodb",
    "qdrant",
    "minio",
    "minio-init",
    "open-webui",
    "adminer",
    "mlflow",
    "cadvisor",
    "node-exporter",
    "prometheus",
    "grafana",
    "prefect-server",
    "prefect-worker",
    "dagster-webserver",
    "dagster-daemon",
    "sqlserver",
    "ollama"
)

Write-Host "Harmonia - Service Status" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

try {
    $rows = & docker ps --filter "label=com.docker.compose.service" --format "{{.Names}}`t{{.Status}}`t{{.Ports}}"
    if ($LASTEXITCODE -ne 0) {
        throw "docker ps failed with exit code $LASTEXITCODE"
    }

    $matchingRows = @()

    foreach ($row in $rows) {
        if (-not $row) { continue }

        $parts = $row -split "`t", 3
        if ($parts.Count -lt 3) { continue }

        $containerName = $parts[0]

        $inspectJson = & docker inspect $containerName 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $inspectJson) { continue }

        $inspect = $inspectJson | ConvertFrom-Json
        if (-not $inspect) { continue }

        $serviceName = $inspect[0].Config.Labels.'com.docker.compose.service'

        if ($platformServices -contains $serviceName) {
            $matchingRows += [PSCustomObject]@{
                Name   = $parts[0]
                Status = $parts[1]
                Ports  = $parts[2]
            }
        }
    }

    if ($matchingRows.Count -eq 0) {
        Write-Host "No platform containers are currently running." -ForegroundColor Yellow
        exit 0
    }

    $matchingRows | Format-Table `
        @{Label='NAMES'; Expression={$_.Name}; Width=35}, `
        @{Label='STATUS'; Expression={$_.Status}; Width=25}, `
        @{Label='PORTS'; Expression={$_.Ports}} `
        -AutoSize

    exit 0
}
catch {
    Write-Error "Failed to get platform container status: $($_.Exception.Message)"
    exit 1
}
