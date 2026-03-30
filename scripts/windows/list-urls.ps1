<#
.SYNOPSIS
    List all accessible URLs for running Harmonia services

.DESCRIPTION
    Detects which services are currently running and displays their accessible URLs.
    Shows both Traefik URLs and direct port access where available.

    This script checks running Docker containers and provides:
    - Service status (running/stopped)
    - Traefik URLs (*.localhost)
    - Direct port access (localhost:PORT)
    - Database connection strings (if dev mode is active)

.EXAMPLE
    .\list-urls.ps1
    # Lists all accessible URLs for running services

.EXAMPLE
    .\list-urls.ps1 -Detailed
    # Shows detailed information including container status

.NOTES
    Prerequisites:
    - Docker Desktop running
    - Stack services started

    Exit Codes:
    - 0: Success
    - 1: Docker not available
#>

[CmdletBinding()]
param(
    [switch]$Detailed
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Check if Docker is available
try {
    $null = docker ps 2>&1
} catch {
    Write-Error "Docker is not available. Please ensure Docker Desktop is running."
    exit 1
}

# Function to check if a container is running
function Test-ContainerRunning {
    param(
        [string]$ContainerName,
        [string]$ServiceName
    )

    if ($ServiceName) {
        $result = docker ps --filter "label=com.docker.compose.service=$ServiceName" --format "{{.Names}}" 2>$null
    }
    else {
        $result = docker ps --filter "name=$ContainerName" --format "{{.Names}}" 2>$null
    }

    if (-not $result) {
        return $false
    }

    foreach ($name in ($result -split "`r?`n")) {
        if ($ServiceName -or $name -eq $ContainerName -or $name -like "*$ContainerName*") {
            return $true
        }
    }

    return $false
}

# Function to check if a port is exposed
function Test-PortExposed {
    param(
        [string]$ContainerName,
        [string]$ServiceName,
        [int]$Port
    )

    if ($ServiceName) {
        $result = docker ps --filter "label=com.docker.compose.service=$ServiceName" --format "{{.Ports}}" 2>$null
    }
    else {
        $result = docker ps --filter "name=$ContainerName" --format "{{.Ports}}" 2>$null
    }

    if (-not $result) {
        return $false
    }

    return $result -like "*:$Port->*" -or
           $result -like "*0.0.0.0:$Port->*" -or
           $result -like "*127.0.0.1:$Port->*" -or
           $result -like "*[::]:$Port->*"
}

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        Harmonia - Stack URLs                                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Define services with a consistent schema
$services = @(
    @{
        Name       = "Dashboard"
        Container  = "compose-dashboard-1"
        Service    = "dashboard"
        TraefikUrl = "http://ai.localhost"
        DirectUrl  = $null
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Core"
    },
    @{
        Name       = "Traefik"
        Container  = "compose-traefik-1"
        Service    = "traefik"
        TraefikUrl = $null
        DirectUrl  = "http://127.0.0.1:8088/dashboard/"
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Core"
    },
    @{
        Name       = "OpenWebUI"
        Container  = "compose-open-webui-1"
        Service    = "open-webui"
        TraefikUrl = "http://openwebui.localhost"
        DirectUrl  = "http://localhost:3000"
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Tools"
    },
    @{
        Name       = "MLflow"
        Container  = "compose-mlflow-1"
        Service    = "mlflow"
        TraefikUrl = "http://mlflow.localhost"
        DirectUrl  = $null
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Tools"
    },
    @{
        Name       = "Adminer"
        Container  = "compose-adminer-1"
        Service    = "adminer"
        TraefikUrl = "http://db.localhost"
        DirectUrl  = $null
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Tools"
    },
    @{
        Name       = "Qdrant"
        Container  = "compose-qdrant-1"
        Service    = "qdrant"
        TraefikUrl = "http://qdrant.localhost/dashboard"
        DirectUrl  = $null
        DevPort    = 6333
        Port       = $null
        Connection = $null
        Category   = "Data"
    },
    @{
        Name       = "MinIO Console"
        Container  = "compose-minio-1"
        Service    = "minio"
        TraefikUrl = "http://minio.localhost"
        DirectUrl  = $null
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Data"
    },
    @{
        Name       = "Prometheus"
        Container  = "compose-prometheus-1"
        Service    = "prometheus"
        TraefikUrl = "http://prometheus.localhost"
        DirectUrl  = "http://localhost:9090"
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Monitoring"
    },
    @{
        Name       = "Grafana"
        Container  = "compose-grafana-1"
        Service    = "grafana"
        TraefikUrl = "http://grafana.localhost"
        DirectUrl  = "http://localhost:3001"
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Monitoring"
    },
    @{
        Name       = "cAdvisor"
        Container  = "compose-cadvisor-1"
        Service    = "cadvisor"
        TraefikUrl = "http://cadvisor.localhost"
        DirectUrl  = "http://localhost:8082"
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Monitoring"
    },
    @{
        Name       = "Node Exporter"
        Container  = "compose-node-exporter-1"
        Service    = "node-exporter"
        TraefikUrl = $null
        DirectUrl  = "http://localhost:9100/metrics"
        DevPort    = $null
        Port       = $null
        Connection = $null
        Category   = "Monitoring"
    },
    @{
        Name       = "Prefect"
        Container  = "compose-prefect-server-1"
        Service    = "prefect-server"
        TraefikUrl = "http://prefect.localhost"
        DirectUrl  = $null
        DevPort    = 4201
        Port       = $null
        Connection = $null
        Category   = "Orchestration"
    },
    @{
        Name       = "Dagster"
        Container  = "compose-dagster-webserver-1"
        Service    = "dagster-webserver"
        TraefikUrl = "http://dagster.localhost"
        DirectUrl  = $null
        DevPort    = 3051
        Port       = $null
        Connection = $null
        Category   = "Orchestration"
    }
)

# Database services (internal only, but show if dev mode is active)
$databases = @(
    @{
        Name       = "PostgreSQL"
        Container  = "compose-postgres-1"
        Service    = "postgres"
        TraefikUrl = $null
        DirectUrl  = $null
        DevPort    = $null
        Port       = 5432
        Connection = "postgresql://ai:password@localhost:5432/ai"
        Category   = "Database"
    },
    @{
        Name       = "MongoDB"
        Container  = "compose-mongodb-1"
        Service    = "mongodb"
        TraefikUrl = $null
        DirectUrl  = $null
        DevPort    = $null
        Port       = 27017
        Connection = "mongodb://root:password@localhost:27017"
        Category   = "Database"
    },
    @{
        Name       = "SQL Server"
        Container  = "compose-sqlserver-1"
        Service    = "sqlserver"
        TraefikUrl = $null
        DirectUrl  = $null
        DevPort    = $null
        Port       = 1433
        Connection = "Server=localhost,1433;Database=master;User Id=sa;Password=***"
        Category   = "Database"
    }
)

# Group services by category
$categories = $services | Group-Object -Property Category

# Display running services by category
foreach ($category in $categories) {
    $runningServices = $category.Group | Where-Object { Test-ContainerRunning -ContainerName $_.Container -ServiceName $_.Service }

    if ($runningServices) {
        Write-Host "═══ $($category.Name) Services ═══" -ForegroundColor Yellow
        Write-Host ""

        foreach ($service in $runningServices) {
            $isRunning = Test-ContainerRunning -ContainerName $service.Container -ServiceName $service.Service
            $status = if ($isRunning) { "●" } else { "○" }
            $statusColor = if ($isRunning) { "Green" } else { "Red" }

            Write-Host "  $status " -ForegroundColor $statusColor -NoNewline
            Write-Host "$($service.Name)" -ForegroundColor White

            if ($service.TraefikUrl) {
                Write-Host "    ├─ Traefik: " -ForegroundColor Gray -NoNewline
                Write-Host $service.TraefikUrl -ForegroundColor Cyan
            }

            if ($service.DirectUrl) {
                Write-Host "    ├─ Direct:  " -ForegroundColor Gray -NoNewline
                Write-Host $service.DirectUrl -ForegroundColor Cyan
            }

            if ($service.DevPort -and (Test-PortExposed -ContainerName $service.Container -ServiceName $service.Service -Port $service.DevPort)) {
                Write-Host "    ├─ Dev:     " -ForegroundColor Gray -NoNewline
                Write-Host "http://localhost:$($service.DevPort)" -ForegroundColor Yellow
            }

            Write-Host ""
        }
    }
}

# Check for database access (dev mode)
$devModeActive = $false
$runningDatabases = @()

foreach ($db in $databases) {
    if ((Test-ContainerRunning -ContainerName $db.Container -ServiceName $db.Service) -and (Test-PortExposed -ContainerName $db.Container -ServiceName $db.Service -Port $db.Port)) {
        $devModeActive = $true
        $runningDatabases += $db
    }
}

if ($devModeActive) {
    Write-Host "═══ Database Access (Dev Mode Active) ═══" -ForegroundColor Yellow
    Write-Host ""

    foreach ($db in $runningDatabases) {
        Write-Host "  ● " -ForegroundColor Green -NoNewline
        Write-Host "$($db.Name)" -ForegroundColor White
        Write-Host "    ├─ Port:       " -ForegroundColor Gray -NoNewline
        Write-Host "localhost:$($db.Port)" -ForegroundColor Yellow
        Write-Host "    └─ Connection: " -ForegroundColor Gray -NoNewline
        Write-Host $db.Connection -ForegroundColor Cyan
        Write-Host ""
    }
}

# Show stopped services if detailed mode
if ($Detailed) {
    $stoppedServices = $services | Where-Object { -not (Test-ContainerRunning -ContainerName $_.Container -ServiceName $_.Service) }

    if ($stoppedServices) {
        Write-Host "═══ Stopped Services ═══" -ForegroundColor DarkGray
        Write-Host ""

        foreach ($service in $stoppedServices) {
            Write-Host "  ○ " -ForegroundColor Red -NoNewline
            Write-Host "$($service.Name) " -ForegroundColor DarkGray -NoNewline
            Write-Host "($($service.Category))" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

# Summary
$totalServices = $services.Count
$runningCount = ($services | Where-Object { Test-ContainerRunning -ContainerName $_.Container -ServiceName $_.Service }).Count

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# More accurate wording
Write-Host "  Active service endpoints: $runningCount/$totalServices" -ForegroundColor $(if ($runningCount -eq $totalServices) { "Green" } else { "Yellow" })

if ($devModeActive) {
    Write-Host "  Developer database access detected (some ports exposed)" -ForegroundColor Yellow
}

Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "ℹ️  Note: Output reflects currently running containers. Optional services may still appear if not fully stopped." -ForegroundColor DarkGray
Write-Host ""

# Tips
Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "   • Use " -NoNewline
Write-Host "-Detailed" -ForegroundColor Yellow -NoNewline
Write-Host " to see stopped services"
Write-Host "   • Run " -NoNewline
Write-Host ".\start-dev.ps1" -ForegroundColor Yellow -NoNewline
Write-Host " to enable database access"
Write-Host "   • Visit " -NoNewline
Write-Host "http://ai.localhost" -ForegroundColor Cyan -NoNewline
Write-Host " for the stack dashboard`n"

exit 0
