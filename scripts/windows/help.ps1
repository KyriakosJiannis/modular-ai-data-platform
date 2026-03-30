<#
.SYNOPSIS
    Display available Harmonia commands

.DESCRIPTION
    Shows all available Harmonia management commands in a clean, organized format.
    Use this to discover what operations are available.

.EXAMPLE
    .\help.ps1
    # Shows all available commands

.NOTES
    This is the quickest way to see what you can do with the stack.
#>

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║             Harmonia - Available Commands                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "🚀 STARTUP COMMANDS" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  LIGHTWEIGHT:" -ForegroundColor Gray
Write-Host "    start.ps1              Default stack (recommended)" -ForegroundColor White
Write-Host "    start-dev.ps1          Default stack + direct data access" -ForegroundColor White
Write-Host "    up-core.ps1            Core infrastructure only" -ForegroundColor White
Write-Host "    up-tools.ps1           Core + tools" -ForegroundColor White
Write-Host ""
Write-Host "  COMPLETE LOCAL STACK:" -ForegroundColor Gray
Write-Host "    up-full.ps1            Core + tools + monitoring + dev access" -ForegroundColor White
Write-Host ""
Write-Host "  ORCHESTRATION:" -ForegroundColor Gray
Write-Host "    up-orchestration.ps1   Core + tools + Prefect + Dagster" -ForegroundColor White
Write-Host "    up-full-orchestration.ps1  Complete + orchestration + monitoring" -ForegroundColor White
Write-Host ""
Write-Host "  SPECIALIZED:" -ForegroundColor Gray
Write-Host "    up-monitoring.ps1      Core + tools + monitoring" -ForegroundColor White
Write-Host "    up-dev-tools.ps1       Core + tools + direct data access" -ForegroundColor White
Write-Host ""

Write-Host "🛠️  MANAGEMENT COMMANDS" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  status.ps1               Show running services" -ForegroundColor White
Write-Host "  restart.ps1              Restart default core + tools stack" -ForegroundColor White
Write-Host "  down.ps1                 Stop stack" -ForegroundColor White
Write-Host "  down.ps1 -RemoveVolumes  Stop and delete all data" -ForegroundColor White
Write-Host ""

Write-Host "🔍 DIAGNOSTIC COMMANDS" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  doctor.ps1               Verify setup and configuration" -ForegroundColor White
Write-Host "  help.ps1                 Show this help message" -ForegroundColor White
Write-Host ""

Write-Host "📚 QUICK START" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  1. .\doctor.ps1          Check your setup" -ForegroundColor Cyan
Write-Host "  2. .\start.ps1           Start the default stack" -ForegroundColor Cyan
Write-Host "  3. .\status.ps1          Verify services running" -ForegroundColor Cyan
Write-Host "  4. Open http://ai.localhost in your browser" -ForegroundColor Cyan
Write-Host ""

Write-Host "📖 SERVICE URLS" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Dashboard:    http://ai.localhost" -ForegroundColor Cyan
Write-Host "  OpenWebUI:    http://openwebui.localhost" -ForegroundColor Cyan
Write-Host "  MLflow:       http://mlflow.localhost" -ForegroundColor Cyan
Write-Host "  MinIO:        http://minio.localhost" -ForegroundColor Cyan
Write-Host "  Qdrant:       http://qdrant.localhost/dashboard" -ForegroundColor Cyan
Write-Host "  Adminer:      http://db.localhost" -ForegroundColor Cyan
Write-Host "  Traefik:      http://127.0.0.1:8088/dashboard/" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔧 INTERNAL HELPERS" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  init-orchestration-db.ps1  Internal helper used by orchestration startup scripts" -ForegroundColor DarkGray
Write-Host "  smoke-test.ps1             Validation utility for maintainers and release checks" -ForegroundColor DarkGray
Write-Host ""

Write-Host "💡 TIPS" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  • Run scripts from repo root: .\scripts\windows\start.ps1" -ForegroundColor Gray
Write-Host "  • Edit config: notepad config\env\.env" -ForegroundColor Gray
Write-Host "  • View logs: docker compose logs -f" -ForegroundColor Gray
Write-Host "  • Check status: .\scripts\windows\status.ps1" -ForegroundColor Gray
Write-Host ""

Write-Host "📖 DOCUMENTATION" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  README.md                Main documentation" -ForegroundColor Gray
Write-Host "  docs/ARCHITECTURE.md     System design" -ForegroundColor Gray
Write-Host "  docs/STRUCTURE.md        Repository organization" -ForegroundColor Gray
Write-Host ""
