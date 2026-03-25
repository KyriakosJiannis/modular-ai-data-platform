# Service Catalog

Compose files are the source of truth for this catalog. This document describes the current platform services, their access paths, and the overlays that change host exposure.

---

## Service Inventory

| Service | Compose File(s) | Layer | Profile | Networks | Traefik URL | Direct Host Access | Access Mode | Internal-Only in Base Topology |
|---|---|---|---|---|---|---|---|---|
| Traefik | `compose/docker-compose.yml` | Core | `infra` | `ai-infra-net`, `ai-public-net` | — | `http://127.0.0.1:8088/dashboard/` | Base | No |
| Dashboard | `compose/docker-compose.yml` | Core | `infra` | `ai-public-net`, `ai-infra-net` | `http://ai.localhost` | — | Traefik-first | No |
| PostgreSQL | `compose/docker-compose.yml` | Core | `infra` | `ai-infra-net` | — | `localhost:5432` | Dev-only via `docker-compose.dev-core.yml` | Yes |
| MongoDB | `compose/docker-compose.yml` | Core | `infra` | `ai-infra-net` | — | `localhost:27017` | Dev-only via `docker-compose.dev-core.yml` | Yes |
| Qdrant | `compose/docker-compose.yml` | Core | `infra` | `ai-infra-net`, `ai-public-net` | `http://qdrant.localhost/dashboard` | `http://localhost:6333` | Traefik-first; direct access via `docker-compose.dev-core.yml` | No |
| MinIO API | `compose/docker-compose.yml` | Core | `infra` | `ai-infra-net`, `ai-public-net` | — | `http://localhost:9000` | Direct access via `docker-compose.dev-core.yml` | Yes |
| MinIO Console | `compose/docker-compose.yml` | Core | `infra` | `ai-infra-net`, `ai-public-net` | `http://minio.localhost` | — | Traefik-first | No |
| MinIO Init | `compose/docker-compose.yml` | Core helper | `infra` | `ai-infra-net` | — | — | Internal helper | Yes |
| OpenWebUI | `compose/docker-compose.tools.yml` | Optional tools | `tools` | `ai-public-net`, `ai-infra-net` | `http://openwebui.localhost` | `http://localhost:3000` | Base | No |
| MLflow | `compose/docker-compose.tools.yml` | Optional tools | `tools` | `ai-infra-net`, `ai-public-net` | `http://mlflow.localhost` | — | Traefik-first | No |
| Adminer | `compose/docker-compose.tools.yml` | Optional tools | `tools` | `ai-public-net`, `ai-infra-net` | `http://db.localhost` | — | Traefik-first | No |
| cAdvisor | `compose/docker-compose.monitoring.yml` | Optional monitoring | `monitoring` | `ai-infra-net`, `ai-public-net` | `http://cadvisor.localhost` | `http://localhost:8082` | Base when monitoring is enabled | No |
| Node Exporter | `compose/docker-compose.monitoring.yml` | Optional monitoring | `monitoring` | `ai-infra-net` | — | `http://localhost:9100/metrics` | Base when monitoring is enabled | No |
| Prometheus | `compose/docker-compose.monitoring.yml` | Optional monitoring | `monitoring` | `ai-infra-net`, `ai-public-net` | `http://prometheus.localhost` | `http://localhost:9090` | Base when monitoring is enabled | No |
| Grafana | `compose/docker-compose.monitoring.yml` | Optional monitoring | `monitoring` | `ai-infra-net`, `ai-public-net` | `http://grafana.localhost` | `http://localhost:3001` | Base when monitoring is enabled | No |
| Prefect Server | `compose/docker-compose.orchestration.yml` | Optional orchestration | `orchestration` | `ai-infra-net`, `ai-public-net` | `http://prefect.localhost` | `http://localhost:4201` | Traefik-first; direct access via `docker-compose.dev-orchestration.yml` | No |
| Prefect Worker | `compose/docker-compose.orchestration.yml` | Optional orchestration | `orchestration` | `ai-infra-net`, `ai-public-net` | — | — | Background service | Yes |
| Dagster Webserver | `compose/docker-compose.orchestration.yml` | Optional orchestration | `orchestration` | `ai-infra-net`, `ai-public-net` | `http://dagster.localhost` | `http://localhost:3051` | Traefik-first; direct access via `docker-compose.dev-orchestration.yml` | No |
| Dagster Daemon | `compose/docker-compose.orchestration.yml` | Optional orchestration | `orchestration` | `ai-infra-net`, `ai-public-net` | — | — | Background service | Yes |
| SQL Server | `compose/docker-compose.sqlserver.yml` | Optional SQL layer | `sqlserver` | `ai-infra-net` | — | `localhost:1433` | Direct access via `docker-compose.dev-sqlserver.yml` | Yes |
| Ollama | `compose/docker-compose.runtime.ollama.base.yml` + runtime variant | Optional runtime | `runtime` | `ai-infra-net` | — | `http://localhost:11434` | Base when runtime profile is enabled | No |

---

## Access Model

### Traefik-First Services

These services are intended to be accessed through `*.localhost` hostnames when enabled:

| Service | URL |
|---|---|
| Dashboard | `http://ai.localhost` |
| OpenWebUI | `http://openwebui.localhost` |
| MLflow | `http://mlflow.localhost` |
| Adminer | `http://db.localhost` |
| Qdrant | `http://qdrant.localhost/dashboard` |
| MinIO Console | `http://minio.localhost` |
| Prometheus | `http://prometheus.localhost` |
| Grafana | `http://grafana.localhost` |
| cAdvisor | `http://cadvisor.localhost` |
| Prefect Server | `http://prefect.localhost` |
| Dagster Webserver | `http://dagster.localhost` |

### Direct Host Ports in Standard Mode

These ports are published by the base compose files or non-dev optional overlays when those layers are enabled:

| Service | URL / Port | Notes |
|---|---|---|
| Traefik Dashboard | `http://127.0.0.1:8088/dashboard/` | Base infrastructure |
| OpenWebUI | `http://localhost:3000` | Tools overlay |
| Prometheus | `http://localhost:9090` | Monitoring overlay |
| Grafana | `http://localhost:3001` | Monitoring overlay |
| cAdvisor | `http://localhost:8082` | Monitoring overlay |
| Node Exporter | `http://localhost:9100/metrics` | Monitoring overlay |
| Ollama | `http://localhost:11434` | Runtime overlay only |

### Direct Host Ports Available Only Through Dev Overlays

These endpoints exist only when the corresponding dev overlay is added:

| Service | URL / Port | Dev Overlay |
|---|---|---|
| PostgreSQL | `localhost:5432` | `docker-compose.dev-core.yml` |
| MongoDB | `localhost:27017` | `docker-compose.dev-core.yml` |
| Qdrant | `http://localhost:6333` | `docker-compose.dev-core.yml` |
| MinIO API | `http://localhost:9000` | `docker-compose.dev-core.yml` |
| Prefect Server | `http://localhost:4201` | `docker-compose.dev-orchestration.yml` |
| Dagster Webserver | `http://localhost:3051` | `docker-compose.dev-orchestration.yml` |
| SQL Server | `localhost:1433` | `docker-compose.dev-sqlserver.yml` |

### Internal-Only Service Addresses

These service names are intended for container-to-container communication inside the platform network:

| Service | Internal Address |
|---|---|
| PostgreSQL | `postgres:5432` |
| MongoDB | `mongodb:27017` |
| Qdrant | `qdrant:6333` |
| MinIO API | `minio:9000` |
| SQL Server | `sqlserver:1433` |
| Prefect Worker | background service |
| Dagster Daemon | background service |
| MinIO Init | one-shot initialization container |

---

## Services by Layer

### Core Infrastructure (`infra`)

| Service | Purpose | Default Access |
|---|---|---|
| Traefik | Gateway and routing | `http://127.0.0.1:8088/dashboard/` |
| Dashboard | Platform landing page | `http://ai.localhost` |
| PostgreSQL | Relational platform database | Internal only; direct host port via dev-core overlay |
| MongoDB | Document store | Internal only; direct host port via dev-core overlay |
| Qdrant | Vector database | `http://qdrant.localhost/dashboard`; direct host port via dev-core overlay |
| MinIO | Object storage and console | `http://minio.localhost`; API direct host port via dev-core overlay |
| MinIO Init | Bucket/bootstrap helper | Internal only |

### Tools Layer (`tools`)

| Service | Purpose | Default Access |
|---|---|---|
| OpenWebUI | LLM interaction UI | `http://openwebui.localhost` and `http://localhost:3000` |
| MLflow | Experiment tracking | `http://mlflow.localhost` |
| Adminer | Database administration UI | `http://db.localhost` |

### Monitoring Layer (`monitoring`)

| Service | Purpose | Default Access |
|---|---|---|
| Prometheus | Metrics collection | `http://prometheus.localhost` and `http://localhost:9090` |
| Grafana | Dashboards and visualization | `http://grafana.localhost` and `http://localhost:3001` |
| cAdvisor | Container metrics | `http://cadvisor.localhost` and `http://localhost:8082` |
| Node Exporter | Host metrics | `http://localhost:9100/metrics` |

### Orchestration Layer (`orchestration`)

| Service | Purpose | Default Access |
|---|---|---|
| Prefect Server | Workflow orchestration UI/API | `http://prefect.localhost`; direct host port via dev-orchestration overlay |
| Prefect Worker | Flow execution | Background service |
| Dagster Webserver | Data orchestration UI | `http://dagster.localhost`; direct host port via dev-orchestration overlay |
| Dagster Daemon | Schedules and sensors | Background service |

### Optional SQL Layer (`sqlserver`)

| Service | Purpose | Default Access |
|---|---|---|
| SQL Server | Optional Microsoft SQL engine | Internal only; direct host port via dev-sqlserver overlay |

### Optional Runtime Layer (`runtime`)

| Service | Purpose | Default Access |
|---|---|---|
| Ollama | Optional containerized local runtime | `http://localhost:11434` when runtime profile is enabled |

---

## Supported Startup Configurations

These configurations reflect the supported Windows script surface.

| Configuration | Script | Compose Shape |
|---|---|---|
| Core only | `.\scripts\windows\up-core.ps1` | Base `infra` profile |
| Core + tools | `.\scripts\windows\up-tools.ps1` | Base + tools |
| Core + tools + direct data access | `.\scripts\windows\up-dev-tools.ps1` | Base + tools + dev-core |
| Core + tools + monitoring | `.\scripts\windows\up-monitoring.ps1` | Base + tools + monitoring |
| Core + tools + orchestration | `.\scripts\windows\up-orchestration.ps1` | Base + tools + orchestration |
| Full local stack | `.\scripts\windows\up-full.ps1` | Base + tools + monitoring + dev-core |
| Full local stack + orchestration | `.\scripts\windows\up-full-orchestration.ps1` | Base + tools + monitoring + orchestration + dev-core + dev-orchestration |

---

## Database Connection Patterns

Use values from `config/env/.env` rather than treating the examples below as fixed credentials.

### From Containers

| Service | Connection Pattern |
|---|---|
| PostgreSQL | `postgresql://<POSTGRES_USER>:<POSTGRES_PASSWORD>@postgres:5432/<POSTGRES_DB>` |
| MongoDB | `mongodb://<MONGO_INITDB_ROOT_USERNAME>:<MONGO_INITDB_ROOT_PASSWORD>@mongodb:27017` |
| Qdrant | `http://qdrant:6333` |
| MinIO API | `http://minio:9000` |
| SQL Server | `Server=sqlserver,1433;Database=master;User Id=sa;Password=<MSSQL_SA_PASSWORD>;` |

### From Host

These require the matching dev overlay:

| Service | Connection / URL Pattern | Overlay |
|---|---|---|
| PostgreSQL | `postgresql://<POSTGRES_USER>:<POSTGRES_PASSWORD>@localhost:5432/<POSTGRES_DB>` | `docker-compose.dev-core.yml` |
| MongoDB | `mongodb://<MONGO_INITDB_ROOT_USERNAME>:<MONGO_INITDB_ROOT_PASSWORD>@localhost:27017` | `docker-compose.dev-core.yml` |
| Qdrant | `http://localhost:6333` | `docker-compose.dev-core.yml` |
| MinIO API | `http://localhost:9000` | `docker-compose.dev-core.yml` |
| SQL Server | `Server=localhost,1433;Database=master;User Id=sa;Password=<MSSQL_SA_PASSWORD>;` | `docker-compose.dev-sqlserver.yml` |

---

## Storage and Local Runtime State

| Path | Service | Purpose |
|---|---|---|
| `volumes/postgres/` | PostgreSQL | Relational database files |
| `volumes/mongodb/` | MongoDB | Document database files |
| `volumes/qdrant/` | Qdrant | Vector storage |
| `volumes/minio/` | MinIO | Object storage data |
| `volumes/open-webui/` | OpenWebUI | User and application data |
| `volumes/grafana/` | Grafana | Dashboards and settings |
| `volumes/prometheus/` | Prometheus | Metrics storage |
| `volumes/prefect/` | Prefect | State and configuration |
| `volumes/dagster/` | Dagster | State and run metadata |
| `volumes/sqlserver/` | SQL Server | SQL Server data files |
| `volumes/ollama/` | Ollama | Local model cache |

These directories represent local runtime state in this repository layout and are excluded from version control.

---

## Network Model

### `ai-public-net`

Used for gateway-routed services and externally reachable UIs:

- Traefik
- Dashboard
- Qdrant
- MinIO
- OpenWebUI
- MLflow
- Adminer
- Prometheus
- Grafana
- cAdvisor
- Prefect Server
- Prefect Worker
- Dagster Webserver
- Dagster Daemon

### `ai-infra-net`

Used for internal service-to-service communication across the full stack:

- Traefik
- Dashboard
- PostgreSQL
- MongoDB
- Qdrant
- MinIO
- MinIO Init
- OpenWebUI
- MLflow
- Adminer
- Prometheus
- Grafana
- cAdvisor
- Node Exporter
- Prefect Server
- Prefect Worker
- Dagster Webserver
- Dagster Daemon
- SQL Server
- Ollama

---

## Related Documentation

- [README.md](../README.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [RUNBOOK.md](RUNBOOK.md)
- [ORCHESTRATION.md](ORCHESTRATION.md)
