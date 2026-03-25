<#
.SYNOPSIS
    Diagnose AI Platform setup and configuration

.DESCRIPTION
    Performs basic checks to verify the platform is properly configured.
    Checks for:
    - Docker CLI installed and working
    - Docker daemon running
    - Environment file exists
    - Compose files exist
    - Dashboard assets exist
    - Required directories exist

.EXAMPLE
    .\doctor.ps1
    # Runs diagnostic checks

.NOTES
    Prerequisites:
    - PowerShell 5.0+

    Exit Codes:
    - 0: All checks passed
    - 1: One or more checks failed
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Resolve paths relative to repository root
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$composeDir = Join-Path $repoRoot "compose"
$envFile = Join-Path $repoRoot "config\env\.env"
$envExample = Join-Path $repoRoot "config\env\.env.example"
$dashboardDir = Join-Path $repoRoot "platform\tools\dashboard"
$volumesDir = Join-Path $repoRoot "volumes"

$allChecksPassed = $true

Write-Host "AI Platform - Diagnostic Check" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""

# Check 1: Docker CLI installed
Write-Host "Checking Docker CLI..." -ForegroundColor Cyan
try {
    $dockerVersion = & docker --version 2>&1
    Write-Host "  ✅ Docker CLI installed: $dockerVersion" -ForegroundColor Green
}
catch {
    Write-Host "  ❌ Docker CLI not found. Install Docker Desktop." -ForegroundColor Red
    $allChecksPassed = $false
}

# Check 2: Docker daemon running
Write-Host "Checking Docker daemon..." -ForegroundColor Cyan
try {
    & docker ps > $null 2>&1
    Write-Host "  ✅ Docker daemon is running" -ForegroundColor Green
}
catch {
    Write-Host "  ❌ Docker daemon not running. Start Docker Desktop." -ForegroundColor Red
    $allChecksPassed = $false
}

# Check 3: Environment file exists
Write-Host "Checking environment configuration..." -ForegroundColor Cyan
if (Test-Path $envFile) {
    Write-Host "  ✅ Environment file exists: $envFile" -ForegroundColor Green
}
else {
    Write-Host "  ⚠️  Environment file missing: $envFile" -ForegroundColor Yellow
    if (Test-Path $envExample) {
        Write-Host "     Run: Copy-Item $envExample $envFile" -ForegroundColor Yellow
    }
    $allChecksPassed = $false
}

# Check 4: Compose files exist
Write-Host "Checking compose files..." -ForegroundColor Cyan
$composeFiles = @(
    "docker-compose.yml",
    "docker-compose.tools.yml",
    "docker-compose.monitoring.yml",
    "docker-compose.orchestration.yml",
    "docker-compose.sqlserver.yml",
    "docker-compose.dev-core.yml",
    "docker-compose.dev-orchestration.yml",
    "docker-compose.dev-sqlserver.yml",
    "docker-compose.runtime.ollama.base.yml",
    "docker-compose.runtime.ollama.cpu.yml",
    "docker-compose.runtime.ollama.cuda.yml",
    "docker-compose.runtime.ollama.rocm.yml"
)

$missingFiles = @()
foreach ($file in $composeFiles) {
    $filePath = Join-Path $composeDir $file
    if (-not (Test-Path $filePath)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -eq 0) {
    Write-Host "  ✅ All core compose files found" -ForegroundColor Green
}
else {
    Write-Host "  ❌ Missing compose files: $($missingFiles -join ', ')" -ForegroundColor Red
    $allChecksPassed = $false
}

# Check 5: Dashboard assets exist
Write-Host "Checking dashboard assets..." -ForegroundColor Cyan
if (Test-Path $dashboardDir) {
    $dashboardFile = Join-Path $dashboardDir "index.html"
    if (Test-Path $dashboardFile) {
        Write-Host "  ✅ Dashboard assets found" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  Dashboard index.html not found" -ForegroundColor Yellow
    }
}
else {
    Write-Host "  ⚠️  Dashboard directory not found: $dashboardDir" -ForegroundColor Yellow
}

# Check 6: Volumes directory exists
Write-Host "Checking volumes directory..." -ForegroundColor Cyan
if (Test-Path $volumesDir) {
    Write-Host "  ✅ Volumes directory exists" -ForegroundColor Green
}
else {
    Write-Host "  ℹ️  Volumes directory will be created on first startup" -ForegroundColor Cyan
}

# Summary
Write-Host ""
if ($allChecksPassed) {
    Write-Host "✅ All checks passed! Platform is ready to use." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Edit config/env/.env with your settings" -ForegroundColor Cyan
    Write-Host "  2. Run: .\scripts\windows\up-tools.ps1" -ForegroundColor Cyan
    Write-Host "  3. Open: http://ai.localhost" -ForegroundColor Cyan
    exit 0
}
else {
    Write-Host "❌ Some checks failed. Please fix the issues above." -ForegroundColor Red
    exit 1
}
