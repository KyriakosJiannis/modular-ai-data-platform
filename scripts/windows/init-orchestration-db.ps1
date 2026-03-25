<#
.SYNOPSIS
    Initialize orchestration databases for Prefect and Dagster

.DESCRIPTION
    Internal helper used by orchestration startup scripts.
    Resolves the running PostgreSQL container dynamically and ensures
    the required orchestration databases exist.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$envFile = Join-Path $repoRoot "config\env\.env"
$postgresContainer = docker ps --filter "label=com.docker.compose.service=postgres" --format "{{.Names}}" 2>$null | Select-Object -First 1

if (-not $postgresContainer) {
    Write-Error "Postgres container not found. Ensure the infra profile is running."
    exit 1
}

# 1. Pull the DB User from your .env file
$postgresUser = Select-String -Path $envFile -Pattern "^POSTGRES_USER=(.*)" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
if (-not $postgresUser) { $postgresUser = "ai" }

Write-Host "Checking if Postgres is ready..." -ForegroundColor Yellow

# 2. Wait for Postgres to be ready
$retryCount = 0
while ($retryCount -lt 15) {
    & docker exec $postgresContainer pg_isready -U $postgresUser > $null 2>&1
    if ($LASTEXITCODE -eq 0) { break }
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 2
    $retryCount++
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Postgres was not ready in time. Ensure the 'infra' profile is running."
    exit 1
}

Write-Host "`nCreating orchestration databases..." -ForegroundColor Cyan

# 3. Create Databases
$databases = @("prefect", "dagster")
foreach ($db in $databases) {
    Write-Host "  Ensuring '$db' exists..." -ForegroundColor Gray
    $exists = & docker exec $postgresContainer psql -U $postgresUser -d postgres -t -A -c "SELECT 1 FROM pg_database WHERE datname = '$db' LIMIT 1;" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to check existence of database '$db'."
        exit 1
    }
    # Check if database exists (query returns "1" if it does)
    if ([string]::IsNullOrWhiteSpace($exists)) {
        # Database does not exist, create it
        & docker exec $postgresContainer psql -U $postgresUser -d postgres -c "CREATE DATABASE $db;" 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create database '$db'."
            exit 1
        } else {
            Write-Host "    Created." -ForegroundColor Green
        }
    } else {
        Write-Host "    Already exists." -ForegroundColor DarkGray
    }
}

Write-Host "✅ Databases initialized." -ForegroundColor Green
