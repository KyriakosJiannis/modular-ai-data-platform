# Orchestration Layer

The platform optionally includes workflow orchestration services used to schedule and manage data pipelines, ML workflows, and automation tasks.

These services are not required for the platform to run and can be enabled only when needed.

---

## Overview

Two orchestration tools are available.

| Service | Purpose | Best For | UI |
|---|---|---|---|
| **Prefect** | Python-first workflow orchestration | ML pipelines, LLM workflows, Python data pipelines | `http://prefect.localhost` |
| **Dagster** | Asset-based data orchestration | Data pipelines, lineage tracking, asset dependencies | `http://dagster.localhost` |

Both integrate with the platform data layer, including PostgreSQL, MinIO, and Qdrant.

---

## Architecture Principle

The platform follows a shallow orchestration model.

Orchestration services use the platform infrastructure but do not manage it.

```text
┌───────────────────────────────┐
│    Orchestration Layer        │
│   Prefect      Dagster        │
└───────────────┬───────────────┘
                │
┌────────────────────────────────────────────┐
│           Platform Infrastructure          │
│                                            │
│  PostgreSQL | MongoDB | Qdrant | MinIO     │
│  MLflow | Ollama                           │
│                                            │
│  Microsoft SQL Server (optional analytics) │
└────────────────────────────────────────────┘
```

Infrastructure services run independently.  
Orchestration coordinates workflows that use them.

---

## Prefect

Prefect is a Python-native workflow orchestration tool.

It is typically used for:

- ML pipelines
- LLM workflows
- scheduled Python jobs
- automation tasks
- batch data processing

Prefect workflows are defined directly in Python and can run locally or in containers.

UI:

```text
http://prefect.localhost
```

---

## Dagster

Dagster is a data orchestration platform focused on assets and lineage.

It is designed for:

- data pipelines
- asset dependency management
- lineage tracking
- complex multi-stage workflows

Dagster treats datasets as assets, allowing dependencies between pipelines to be tracked automatically.

UI:

```text
http://dagster.localhost
```

---

## When to Use Each

| Scenario | Recommended Tool |
|---|---|
| ML pipelines | Prefect |
| LLM workflows | Prefect |
| Python batch jobs | Prefect |
| Data engineering pipelines | Dagster |
| Data lineage tracking | Dagster |
| Asset dependency graphs | Dagster |

Both tools can coexist and serve different workloads.

---

## Integration with Platform Services

The orchestration layer integrates with the core platform infrastructure.

Typical integrations include:

- **PostgreSQL** -> workflow state and metadata
- **MinIO** -> pipeline artifacts and outputs
- **MLflow** -> experiment tracking
- **Qdrant** -> vector search pipelines
- **Ollama** -> LLM inference within workflows

---

## Running the Orchestration Layer

The supported orchestration startup paths are:

```powershell
.\scripts\windows\up-orchestration.ps1
.\scripts\windows\up-full-orchestration.ps1
```

`up-orchestration.ps1` starts:

- core infrastructure
- tools layer
- orchestration layer

`up-full-orchestration.ps1` starts:

- core infrastructure
- tools layer
- monitoring layer
- orchestration layer
- direct host access for core data services and orchestration UIs

Default access is through Traefik:

- `http://prefect.localhost`
- `http://dagster.localhost`

Direct localhost access for orchestration UIs is available only when the orchestration dev overlay is enabled:

- Prefect -> `http://localhost:4201`
- Dagster -> `http://localhost:3051`

---

## Usage Model

The orchestration layer is typically used to run:

- scheduled data pipelines
- ML training workflows
- RAG indexing pipelines
- ingestion workflows
- automated evaluation pipelines

These workflows may live:

- inside `/apps`
- inside external repositories
- inside notebooks or Python projects

---

## Related Documentation

- [SERVICES.md](SERVICES.md) -> service catalog
- [ARCHITECTURE.md](ARCHITECTURE.md) -> platform architecture
- [STRUCTURE.md](STRUCTURE.md) -> repository structure
- [RUNBOOK.md](RUNBOOK.md) -> operational procedures
