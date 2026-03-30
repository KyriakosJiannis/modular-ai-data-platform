# Runbook

Minimal operating guide for Harmonia.

## Start

Recommended default:

```powershell
.\scripts\windows\start.ps1
```

Developer mode with direct localhost data access:

```powershell
.\scripts\windows\start-dev.ps1
```

Other modes:

```powershell
.\scripts\windows\up-full.ps1
.\scripts\windows\up-orchestration.ps1
.\scripts\windows\up-full-orchestration.ps1
```

## Access

- Dashboard: `http://ai.localhost`
- List active URLs: `.\scripts\windows\list-urls.ps1`
- Check running services: `.\scripts\windows\status.ps1`

## Stop

```powershell
.\scripts\windows\down.ps1
```

Remove volumes only when you want a clean reset:

```powershell
docker compose --env-file .\config\env\.env -f .\compose\docker-compose.yml down -v
```

## Check and Debug

```powershell
.\scripts\windows\doctor.ps1
docker ps
docker logs <container-name>
docker logs -f <container-name>
```

## Common Notes

- Use Traefik URLs (`*.localhost`) by default
- Use direct localhost ports only in dev-enabled stacks
- If PowerShell blocks scripts, run:

```powershell
Get-ChildItem .\scripts\windows\*.ps1 | Unblock-File
```

## Related Docs

- [README.md](../README.md)
- [SERVICES.md](SERVICES.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
