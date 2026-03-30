<#
.SYNOPSIS
    Harmonia Smoke Test

.DESCRIPTION
    Performs practical smoke tests to validate Harmonia is operational.
    Tests different stack layers (core, tools, orchestration, SQL Server) independently.

    This is NOT a comprehensive test framework - it's a quick validation utility
    for pre-release checks, local environment verification, and regression testing.

.PARAMETER Core
    Test core infrastructure only (Traefik, PostgreSQL, MongoDB, Qdrant, MinIO, Dashboard)

.PARAMETER Tools
    Test core + tools overlay (OpenWebUI, MLflow, Adminer)

.PARAMETER Orchestration
    Test core + orchestration overlay (Prefect, Dagster)

.PARAMETER SqlServer
    Test core + SQL Server overlay

.PARAMETER All
    Test all layers sequentially (Core, Tools, Orchestration, SqlServer)

.PARAMETER KeepRunning
    Keep services running after tests complete (default: stop services after tests)

.PARAMETER NoStart
    Skip starting services - test already running services only

.PARAMETER Timeout
    Maximum seconds to wait for service readiness (default: 120)

.EXAMPLE
    .\smoke-test.ps1 -Core
    # Test core infrastructure only

.EXAMPLE
    .\smoke-test.ps1 -Tools -KeepRunning
    # Test core + tools, leave services running

.EXAMPLE
    .\smoke-test.ps1 -All
    # Test all stack layers

.EXAMPLE
    .\smoke-test.ps1 -Core -NoStart
    # Test already running core services

.NOTES
    Prerequisites:
    - Docker Desktop with WSL2 enabled
    - config/env/.env file created from .env.example

    Exit Codes:
    - 0: All tests passed
    - 1: One or more tests failed
    - 2: Configuration error
    - 3: Docker not available
#>

[CmdletBinding(DefaultParameterSetName='Core')]
param(
    [Parameter(ParameterSetName='Core')]
    [switch]$Core,

    [Parameter(ParameterSetName='Tools')]
    [switch]$Tools,

    [Parameter(ParameterSetName='Orchestration')]
    [switch]$Orchestration,

    [Parameter(ParameterSetName='SqlServer')]
    [switch]$SqlServer,

    [Parameter(ParameterSetName='All')]
    [switch]$All,

    [switch]$KeepRunning,
    [switch]$NoStart,

    [int]$Timeout = 120
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================================
# CONFIGURATION
# ============================================================================

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$composeDir = Join-Path $repoRoot "compose"
$envFile = Join-Path $repoRoot "config\env\.env"

# Test results tracking
$script:TestResults = @()
$script:FailedTests = 0
$script:PassedTests = 0

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-TestHeader {
    param([string]$Message)
    Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $($Message.PadRight(60))║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = ""
    )

    $status = if ($Passed) { "✅ PASS" } else { "❌ FAIL" }
    $color = if ($Passed) { "Green" } else { "Red" }

    Write-Host "  $status - $TestName" -ForegroundColor $color
    if ($Message) {
        Write-Host "         $Message" -ForegroundColor Gray
    }

    $script:TestResults += @{
        Name = $TestName
        Passed = $Passed
        Message = $Message
    }

    if ($Passed) {
        $script:PassedTests++
    } else {
        $script:FailedTests++
    }
}

function Test-DockerAvailable {
    try {
        $null = docker ps 2>&1
        return $true
    } catch {
        return $false
    }
}

function Test-ContainerRunning {
    param([string]$ServiceName)

    $containers = docker ps --filter "label=com.docker.compose.service=$ServiceName" --format "{{.Names}}" 2>$null
    return ($null -ne $containers -and $containers.Length -gt 0)
}

function Test-ContainerHealthy {
    param([string]$ServiceName)

    $health = docker ps --filter "label=com.docker.compose.service=$ServiceName" --format "{{.Status}}" 2>$null
    return ($health -like "*healthy*")
}

function Get-ContainerNameByService {
    param([string]$ServiceName)

    return (docker ps --filter "label=com.docker.compose.service=$ServiceName" --format "{{.Names}}" 2>$null | Select-Object -First 1)
}

function Test-HttpEndpoint {
    param(
        [string]$Url,
        [int]$TimeoutSeconds = 10,
        [int]$MaxRetries = 3
    )

    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -TimeoutSec $TimeoutSeconds -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
                return $true
            }
        } catch {
            if ($i -eq ($MaxRetries - 1)) {
                return $false
            }
            Start-Sleep -Seconds 2
        }
    }

    return $false
}

function Test-PostgreSQL {
    param([string]$ServiceName = "postgres")

    $containerName = Get-ContainerNameByService -ServiceName $ServiceName
    if (-not $containerName) {
        return $false
    }

    try {
        $result = docker exec $containerName pg_isready -U ai 2>&1
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-MongoDB {
    param([string]$ServiceName = "mongodb")

    $containerName = Get-ContainerNameByService -ServiceName $ServiceName
    if (-not $containerName) {
        return $false
    }

    try {
        $result = docker exec $containerName mongosh --quiet --eval "db.adminCommand('ping').ok" 2>&1
        return ($result -like "*1*")
    } catch {
        return $false
    }
}

function Test-PortOpen {
    param(
        [string]$Host = "localhost",
        [int]$Port,
        [int]$TimeoutMs = 1000
    )

    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($Host, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne($TimeoutMs, $false)

        if ($wait) {
            try {
                $tcpClient.EndConnect($connect)
                $tcpClient.Close()
                return $true
            } catch {
                return $false
            }
        } else {
            $tcpClient.Close()
            return $false
        }
    } catch {
        return $false
    }
}

function Start-PlatformStack {
    param(
        [string[]]$ComposeFiles,
        [string[]]$Profiles
    )

    Write-Host "`n🚀 Starting stack..." -ForegroundColor Yellow
    Write-Host "   Compose files: $($ComposeFiles -join ', ')" -ForegroundColor Gray
    Write-Host "   Profiles: $($Profiles -join ', ')" -ForegroundColor Gray

    $composeArgs = @("--env-file", $envFile)

    foreach ($file in $ComposeFiles) {
        $composeArgs += @("-f", $file)
    }

    foreach ($profile in $Profiles) {
        $composeArgs += @("--profile", $profile)
    }

    $composeArgs += @("up", "-d")

    Push-Location $composeDir
    try {
        & docker compose @composeArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   ❌ Failed to start stack" -ForegroundColor Red
            return $false
        }
        Write-Host "   ✅ Stack started" -ForegroundColor Green
        return $true
    } finally {
        Pop-Location
    }
}

function Stop-PlatformStack {
    param(
        [string[]]$ComposeFiles
    )

    Write-Host "`n🛑 Stopping stack..." -ForegroundColor Yellow

    $composeArgs = @("--env-file", $envFile)

    foreach ($file in $ComposeFiles) {
        $composeArgs += @("-f", $file)
    }

    $composeArgs += @("down")

    Push-Location $composeDir
    try {
        & docker compose @composeArgs 2>&1 | Out-Null
        Write-Host "   ✅ Stack stopped" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}

# ============================================================================
# TEST SUITES
# ============================================================================

function Test-CoreInfrastructure {
    Write-TestHeader "Testing Core Infrastructure"

    # Wait for containers to be running
    Write-Host "`n⏳ Waiting for containers to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5

    # Test Traefik
    $traefikRunning = Test-ContainerRunning "traefik"
    Write-TestResult "Traefik container running" $traefikRunning

    if ($traefikRunning) {
        Start-Sleep -Seconds 3  # Give Traefik time to initialize
        $traefikDashboard = Test-HttpEndpoint "http://127.0.0.1:8088/dashboard/"
        Write-TestResult "Traefik dashboard accessible" $traefikDashboard "http://127.0.0.1:8088/dashboard/"
    }

    # Test Dashboard
    $dashboardRunning = Test-ContainerRunning "dashboard"
    Write-TestResult "Dashboard container running" $dashboardRunning

    if ($dashboardRunning) {
        Start-Sleep -Seconds 2
        $dashboardHttp = Test-HttpEndpoint "http://ai.localhost"
        Write-TestResult "Dashboard HTTP accessible" $dashboardHttp "http://ai.localhost"
    }

    # Test PostgreSQL
    $postgresRunning = Test-ContainerRunning "postgres"
    Write-TestResult "PostgreSQL container running" $postgresRunning

    if ($postgresRunning) {
        # Wait for PostgreSQL to be ready
        Write-Host "   ⏳ Waiting for PostgreSQL to be ready..." -ForegroundColor Gray
        Start-Sleep -Seconds 10

        $postgresReady = Test-PostgreSQL
        Write-TestResult "PostgreSQL ready" $postgresReady "pg_isready check"
    }

    # Test MongoDB
    $mongoRunning = Test-ContainerRunning "mongodb"
    Write-TestResult "MongoDB container running" $mongoRunning

    if ($mongoRunning) {
        Start-Sleep -Seconds 5
        $mongoPing = Test-MongoDB
        Write-TestResult "MongoDB responding" $mongoPing "ping command"
    }

    # Test Qdrant
    $qdrantRunning = Test-ContainerRunning "qdrant"
    Write-TestResult "Qdrant container running" $qdrantRunning

    if ($qdrantRunning) {
        Start-Sleep -Seconds 3
        $qdrantHttp = Test-HttpEndpoint "http://qdrant.localhost"
        Write-TestResult "Qdrant HTTP accessible" $qdrantHttp "http://qdrant.localhost"
    }

    # Test MinIO
    $minioRunning = Test-ContainerRunning "minio"
    Write-TestResult "MinIO container running" $minioRunning

    if ($minioRunning) {
        $minioHealthy = Test-ContainerHealthy "minio"
        Write-TestResult "MinIO healthy" $minioHealthy "health check"

        if ($minioHealthy) {
            $minioHttp = Test-HttpEndpoint "http://minio.localhost"
            Write-TestResult "MinIO console accessible" $minioHttp "http://minio.localhost"
        }
    }
}

function Test-ToolsLayer {
    Write-TestHeader "Testing Tools Layer"

    # Wait for tools to start
    Write-Host "`n⏳ Waiting for tools to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5

    # Test OpenWebUI
    $openwebuiRunning = Test-ContainerRunning "open-webui"
    Write-TestResult "OpenWebUI container running" $openwebuiRunning

    if ($openwebuiRunning) {
        Start-Sleep -Seconds 5
        $openwebuiHttp = Test-HttpEndpoint "http://openwebui.localhost" -TimeoutSeconds 15
        Write-TestResult "OpenWebUI accessible" $openwebuiHttp "http://openwebui.localhost"
    }

    # Test MLflow
    $mlflowRunning = Test-ContainerRunning "mlflow"
    Write-TestResult "MLflow container running" $mlflowRunning

    if ($mlflowRunning) {
        Start-Sleep -Seconds 5
        $mlflowHttp = Test-HttpEndpoint "http://mlflow.localhost" -TimeoutSeconds 15
        Write-TestResult "MLflow accessible" $mlflowHttp "http://mlflow.localhost"
    }

    # Test Adminer
    $adminerRunning = Test-ContainerRunning "adminer"
    Write-TestResult "Adminer container running" $adminerRunning

    if ($adminerRunning) {
        Start-Sleep -Seconds 3
        $adminerHttp = Test-HttpEndpoint "http://db.localhost"
        Write-TestResult "Adminer accessible" $adminerHttp "http://db.localhost"
    }
}

function Test-OrchestrationLayer {
    Write-TestHeader "Testing Orchestration Layer"

    # Wait for orchestration services to start
    Write-Host "`n⏳ Waiting for orchestration services to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10

    # Test Prefect
    $prefectRunning = Test-ContainerRunning "prefect-server"
    Write-TestResult "Prefect server container running" $prefectRunning

    if ($prefectRunning) {
        # Prefect takes longer to start
        Write-Host "   ⏳ Waiting for Prefect to be ready..." -ForegroundColor Gray
        Start-Sleep -Seconds 15

        $prefectHttp = Test-HttpEndpoint "http://prefect.localhost" -TimeoutSeconds 20
        Write-TestResult "Prefect UI accessible" $prefectHttp "http://prefect.localhost"
    }

    # Test Dagster
    $dagsterRunning = Test-ContainerRunning "dagster-webserver"
    Write-TestResult "Dagster webserver container running" $dagsterRunning

    if ($dagsterRunning) {
        # Dagster also takes time to start
        Write-Host "   ⏳ Waiting for Dagster to be ready..." -ForegroundColor Gray
        Start-Sleep -Seconds 15

        $dagsterHttp = Test-HttpEndpoint "http://dagster.localhost" -TimeoutSeconds 20
        Write-TestResult "Dagster UI accessible" $dagsterHttp "http://dagster.localhost"
    }
}

function Test-SqlServerLayer {
    Write-TestHeader "Testing SQL Server Layer"

    # Wait for SQL Server to start
    Write-Host "`n⏳ Waiting for SQL Server to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10

    # Test SQL Server container
    $sqlserverRunning = Test-ContainerRunning "sqlserver"
    Write-TestResult "SQL Server container running" $sqlserverRunning

    if ($sqlserverRunning) {
        # SQL Server takes significant time to initialize
        Write-Host "   ⏳ Waiting for SQL Server to initialize (this may take 30-60s)..." -ForegroundColor Gray
        Start-Sleep -Seconds 30

        # Check if port 1433 is accessible (requires dev overlay)
        $portOpen = Test-PortOpen -Port 1433
        Write-TestResult "SQL Server port 1433 accessible" $portOpen "localhost:1433"

        # Check container health if defined
        $sqlserverHealthy = Test-ContainerHealthy "sqlserver"
        if ($sqlserverHealthy) {
            Write-TestResult "SQL Server healthy" $true "health check passed"
        } else {
            Write-TestResult "SQL Server health check" $false "health check not passed yet (may need more time)"
        }
    }
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              Harmonia - Stack Tests                           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    # Validate prerequisites
    if (-not (Test-Path $envFile)) {
        Write-Host "❌ Missing $envFile" -ForegroundColor Red
        Write-Host "   Create it from config/env/.env.example before running tests." -ForegroundColor Yellow
        exit 2
    }

    if (-not (Test-DockerAvailable)) {
        Write-Host "❌ Docker is not available" -ForegroundColor Red
        Write-Host "   Please ensure Docker Desktop is running." -ForegroundColor Yellow
        exit 3
    }

    Write-Host "✅ Prerequisites validated" -ForegroundColor Green
    Write-Host "   Environment file: $envFile" -ForegroundColor Gray
    Write-Host "   Docker: Available" -ForegroundColor Gray

    # Determine test mode
    $testMode = if ($All) { "All" }
                elseif ($Tools) { "Tools" }
                elseif ($Orchestration) { "Orchestration" }
                elseif ($SqlServer) { "SqlServer" }
                else { "Core" }

    Write-Host "`n📋 Test Mode: $testMode" -ForegroundColor Cyan
    Write-Host "   Keep Running: $KeepRunning" -ForegroundColor Gray
    Write-Host "   No Start: $NoStart" -ForegroundColor Gray
    Write-Host "   Timeout: $Timeout seconds" -ForegroundColor Gray

    # Define compose file combinations
    $coreFiles = @("docker-compose.yml")
    $toolsFiles = @("docker-compose.yml", "docker-compose.tools.yml")
    $orchestrationFiles = @("docker-compose.yml", "docker-compose.orchestration.yml")
    $sqlserverFiles = @("docker-compose.yml", "docker-compose.sqlserver.yml", "docker-compose.dev-sqlserver.yml")

    try {
        if ($testMode -eq "All") {
            # Test all layers sequentially

            # Core
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $coreFiles -Profiles @("infra")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $coreFiles
            }

            # Tools
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $toolsFiles -Profiles @("infra", "tools")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            Test-ToolsLayer
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $toolsFiles
            }

            # Orchestration
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $orchestrationFiles -Profiles @("infra", "orchestration")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            Test-OrchestrationLayer
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $orchestrationFiles
            }

            # SQL Server
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $sqlserverFiles -Profiles @("infra", "sqlserver")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            Test-SqlServerLayer
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $sqlserverFiles
            }

        } elseif ($testMode -eq "Core") {
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $coreFiles -Profiles @("infra")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $coreFiles
            }

        } elseif ($testMode -eq "Tools") {
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $toolsFiles -Profiles @("infra", "tools")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            Test-ToolsLayer
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $toolsFiles
            }

        } elseif ($testMode -eq "Orchestration") {
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $orchestrationFiles -Profiles @("infra", "orchestration")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            Test-OrchestrationLayer
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $orchestrationFiles
            }

        } elseif ($testMode -eq "SqlServer") {
            if (-not $NoStart) {
                $started = Start-PlatformStack -ComposeFiles $sqlserverFiles -Profiles @("infra", "sqlserver")
                if (-not $started) { exit 1 }
            }
            Test-CoreInfrastructure
            Test-SqlServerLayer
            if (-not $KeepRunning) {
                Stop-PlatformStack -ComposeFiles $sqlserverFiles
            }
        }

    } catch {
        Write-Host "`n❌ Test execution error: $_" -ForegroundColor Red
        exit 1
    }

    # Print summary
    Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                      Test Summary                              ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

    Write-Host "  Total Tests: $($script:PassedTests + $script:FailedTests)" -ForegroundColor White
    Write-Host "  ✅ Passed: $script:PassedTests" -ForegroundColor Green
    Write-Host "  ❌ Failed: $script:FailedTests" -ForegroundColor $(if ($script:FailedTests -gt 0) { "Red" } else { "Green" })

    if ($script:FailedTests -gt 0) {
        Write-Host "`n❌ SMOKE TEST FAILED" -ForegroundColor Red
        Write-Host "`nFailed tests:" -ForegroundColor Yellow
        foreach ($result in $script:TestResults) {
            if (-not $result.Passed) {
                Write-Host "  • $($result.Name)" -ForegroundColor Red
                if ($result.Message) {
                    Write-Host "    $($result.Message)" -ForegroundColor Gray
                }
            }
        }
        exit 1
    } else {
        Write-Host "`n✅ ALL TESTS PASSED" -ForegroundColor Green
        exit 0
    }
}

# Run main
Main
