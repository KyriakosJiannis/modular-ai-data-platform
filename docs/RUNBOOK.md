# Operations Runbook

This guide provides the operational procedures for starting, stopping, validating, and troubleshooting Harmonia — Modular AI & Data Platform.

---

## Operating Model

This platform is designed as a modular, local-first environment with a small supported Windows script surface.

Recommended usage pattern:

- use the PowerShell scripts under `scripts/windows/`
- use Traefik URLs (`*.localhost`) as the default access path
- use direct localhost ports only when the relevant dev overlay is enabled
- treat containerized runtime variants as advanced/experimental, not part of the default run path

For runtime-aware service URLs, use:

```powershell
.\scripts\windows\list-urls.ps1
```

## Starting the Platform

Run all startup scripts from the repository root, for example:

```powershell
.\scripts\windows\up-tools.ps1
.\scripts\windows\up-full.ps1
.\scripts\windows\up-full-orchestration.ps1
```

If PowerShell blocks a script with an execution policy error, unblock the Windows scripts once and rerun the command:

```powershell
Get-ChildItem .\scripts\windows\*.ps1 | Unblock-File
```

Temporary one-session alternative:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

### Default Stack (Recommended)

```powershell
.\scripts\windows\up-tools.ps1
```

Starts:

- core infrastructure
- tools layer
- dashboard
- OpenWebUI
- MLflow
- Adminer

### Development Mode (Direct Data Access)

```powershell
.\scripts\windows\down.ps1
.\scripts\windows\up-dev-tools.ps1
```

Starts the default stack and exposes core data services directly on localhost for development and debugging.

Direct data access provided in this mode:

- PostgreSQL -> localhost:5432
- MongoDB -> localhost:27017
- Qdrant -> localhost:6333
- MinIO API -> localhost:9000

### Full Local Stack

```powershell
.\scripts\windows\up-full.ps1
```

Starts:

- core
- tools
- monitoring
- dev data access

### Orchestration Stack

```powershell
.\scripts\windows\up-orchestration.ps1
```

Starts:

- core
- tools
- orchestration

### Full Stack with Orchestration

```powershell
.\scripts\windows\up-full-orchestration.ps1
```

Starts:

- core
- tools
- monitoring
- orchestration
- dev data access

### Core Only

```powershell
.\scripts\windows\up-core.ps1
```

Starts only the core infrastructure layer.

## Stopping the Platform

### Stop Active Services

```powershell
.\scripts\windows\down.ps1
```

This stops the platform while preserving data volumes.

### Clean Slate (Remove Volumes)

Run the following from the repository root:

```powershell
docker compose --env-file .\config\env\.env `
  -f .\compose\docker-compose.yml `
  down -v
```

Use this only when you intentionally want to remove persisted data.

## Restarting the Platform

### Restart Default Stack (Core + Tools)

```powershell
.\scripts\windows\restart.ps1
```

This script restarts the default core + tools stack only.  
It does not restore whichever stack was previously running.

### Restart a Specific Container

```powershell
docker restart <container-name>
```

Example container names commonly seen in the default stack:

- compose-traefik-1
- compose-postgres-1
- compose-mongodb-1
- compose-qdrant-1
- compose-minio-1
- compose-mlflow-1
- compose-open-webui-1

## Checking Platform Status

### Quick Platform Status

```powershell
.\scripts\windows\status.ps1
```

Shows platform containers currently running.

### Runtime-Aware Service URLs

```powershell
.\scripts\windows\list-urls.ps1
```

Shows currently active service URLs and direct-access endpoints.

### Diagnostic Check

```powershell
.\scripts\windows\doctor.ps1
```

Checks Docker, environment file presence, compose files, and expected local platform assets.

### Raw Container View

```powershell
docker ps
```

## Accessing Services

### Default Access Pattern

Use Traefik URLs first:

- Dashboard -> http://ai.localhost
- OpenWebUI -> http://openwebui.localhost
- MLflow -> http://mlflow.localhost
- Adminer -> http://db.localhost
- MinIO Console -> http://minio.localhost

### Monitoring (if enabled)

- Grafana -> http://grafana.localhost
- Prometheus -> http://prometheus.localhost

Direct ports also exist when monitoring is enabled:

- Grafana -> http://localhost:3001
- Prometheus -> http://localhost:9090
- cAdvisor -> http://localhost:8082
- Node Exporter -> http://localhost:9100/metrics

### Orchestration (if enabled)

- Prefect -> http://prefect.localhost
- Dagster -> http://dagster.localhost

Direct localhost ports are available only when orchestration dev access is enabled:

- Prefect -> http://localhost:4201
- Dagster -> http://localhost:3051

### SQL Server (if enabled)

SQL Server is optional and not part of the default stack.

Direct localhost access is available only when the SQL Server dev overlay is enabled:

- SQL Server -> localhost:1433

## Viewing Logs

### View Logs for a Specific Container

```powershell
docker logs <container-name>
```

### Follow Logs in Real Time

```powershell
docker logs -f <container-name>
```

### Show Last N Lines

```powershell
docker logs --tail 100 <container-name>
```

### Show Timestamps

```powershell
docker logs -t <container-name>
```

Example:

```powershell
docker logs compose-mlflow-1
docker logs -f compose-open-webui-1
docker logs --tail 50 compose-postgres-1
```

## Database Access

These commands are mainly useful when the relevant containers are running and, where needed, dev access is enabled.

### PostgreSQL

```powershell
docker exec -it compose-postgres-1 psql -U postgres
```

Common commands inside `psql`:

```text
\l
\c ai
\dt
\q
```

### MongoDB

```powershell
docker exec -it compose-mongodb-1 mongosh
```

Common commands inside `mongosh`:

```text
show dbs
use ai
show collections
exit
```

### Qdrant

If dev data access is enabled:

```powershell
curl http://localhost:6333/collections
```

Example:

```powershell
curl http://localhost:6333/collections/platform_docs
```

## Health Checks

### PostgreSQL

```powershell
docker exec compose-postgres-1 pg_isready -U postgres
```

### MongoDB

```powershell
docker exec compose-mongodb-1 mongosh --eval "db.adminCommand('ping')"
```

### Traefik Dashboard

```powershell
curl http://127.0.0.1:8088/dashboard/
```

### Qdrant

Only when direct dev access is enabled:

```powershell
curl http://localhost:6333/health
```

## Backup and Restore

### Volume-Level Backup

```powershell
docker volume ls
```

Example volume backup pattern:

```powershell
docker run --rm -v compose_postgres_data:/data -v C:\backups:/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
docker run --rm -v compose_mongodb_data:/data -v C:\backups:/backup alpine tar czf /backup/mongodb_backup.tar.gz -C /data .
docker run --rm -v compose_qdrant_data:/data -v C:\backups:/backup alpine tar czf /backup/qdrant_backup.tar.gz -C /data .
```

### Logical Dumps

```powershell
docker exec compose-postgres-1 pg_dump -U postgres ai > backup_ai.sql
docker exec compose-mongodb-1 mongodump --out /tmp/backup
docker cp compose-mongodb-1:/tmp/backup ./mongodb_backup
```

### Restore PostgreSQL

```powershell
docker exec -i compose-postgres-1 psql -U postgres < backup_ai.sql
docker run --rm -v compose_postgres_data:/data -v C:\backups:/backup alpine tar xzf /backup/postgres_backup.tar.gz -C /data
```

### Restore MongoDB

```powershell
docker exec -i compose-mongodb-1 mongorestore /tmp/backup
docker run --rm -v compose_mongodb_data:/data -v C:\backups:/backup alpine tar xzf /backup/mongodb_backup.tar.gz -C /data
```

## Troubleshooting

### Services Start but You See Orphan Container Warnings

Typical warning:

```text
Found orphan containers ([...])
```

This usually happens when switching between stack shapes without first bringing the previous stack down.

Recommended cleanup:

```powershell
.\scripts\windows\down.ps1
docker container prune -f
```

Then start the desired stack again.

### A Service Won't Start

```powershell
docker logs <container-name>
docker stats
docker restart <container-name>
```

If needed, restart the default stack:

```powershell
.\scripts\windows\restart.ps1
```

### Database Connection Issues

```powershell
docker exec compose-postgres-1 pg_isready -U postgres
docker exec compose-mongodb-1 mongosh --eval "db.adminCommand('ping')"
docker network ls
docker network inspect compose_ai-infra-net
```

### Orchestration Database Initialization Fails

```powershell
docker ps | findstr postgres
docker logs compose-postgres-1
docker restart compose-postgres-1
Start-Sleep -Seconds 30
.\scripts\windows\up-orchestration.ps1
```

### Prefect or Dagster Not Reachable

```powershell
docker ps | findstr traefik
curl http://127.0.0.1:8088/dashboard/
docker logs compose-traefik-1
docker logs compose-prefect-server-1
docker logs compose-dagster-webserver-1
```

### Port Conflict

```powershell
netstat -ano | findstr :5432
taskkill /PID <PID> /F
```

If needed, stop the stack cleanly and restart:

```powershell
.\scripts\windows\down.ps1
Start-Sleep -Seconds 10
```

### High Memory Usage

```powershell
docker stats
docker restart <container-name>
```

### Ollama / Runtime Issues

By default, OpenWebUI is typically used with Ollama running on the host machine.

Check host Ollama availability with:

```powershell
ollama list
```

If using a containerized runtime path instead, ensure port 11434 is exposed and reachable.

## Maintenance

### Clean Up Unused Docker Resources

```powershell
docker image prune -a
docker volume prune
docker network prune
docker system prune -a
```

### Update Images

```powershell
docker compose pull
docker compose up -d
```

### Check Disk Usage

```powershell
docker system df
docker run --rm -v compose_postgres_data:/data alpine du -sh /data
```

## Monitoring

To enable monitoring:

```powershell
.\scripts\windows\up-full.ps1
```

Access:

- Grafana -> http://localhost:3001
- Prometheus -> http://localhost:9090

## Validation Utilities

### Smoke Test

```powershell
.\scripts\windows\smoke-test.ps1
```

This is a maintainer-oriented validation utility and can be used to confirm that supported stack combinations still start correctly.

### Internal Helper

```powershell
.\scripts\windows\init-orchestration-db.ps1
```

This is an internal/helper script used by orchestration startup flows and is not usually required during normal platform usage.

## Related Documentation

- [README.md](../README.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [SERVICES.md](SERVICES.md)
- [ORCHESTRATION.md](ORCHESTRATION.md)
