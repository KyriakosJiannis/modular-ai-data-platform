# Repository Structure

This document explains how the Harmonia - Local-First AI Infrastructure Stack repository is organized.

The repository is structured around a simple model:

- `compose/` defines how the stack runs
- `platform/` contains service assets and build context
- `apps/` holds optional integrated services
- `examples/` shows how external projects consume the stack
- `docs/` contains the main documentation set
- `scripts/` contains operational helpers
- `config/` contains shared environment and service configuration
- `volumes/` contains local runtime state

---

## Top-Level Structure

```text
ai-platform/
├── compose/      # Docker Compose definitions and overlays
├── platform/     # Service assets, Dockerfiles, configs, dashboards
├── apps/         # Optional integrated services
├── examples/     # Example integrations and demos
├── docs/         # Architecture, services, runbook, roadmap
├── config/       # Shared configuration and environment files
├── scripts/      # Operational scripts
└── volumes/      # Local persistent runtime state (gitignored)
```

---

## Directory Overview

### `compose/`

Contains the Docker Compose files that define the stack topology.

Key files:

- `docker-compose.yml` -> canonical base infrastructure
- `docker-compose.tools.yml` -> tools layer
- `docker-compose.monitoring.yml` -> monitoring layer
- `docker-compose.orchestration.yml` -> orchestration layer
- `docker-compose.sqlserver.yml` -> optional SQL Server layer
- `docker-compose.dev-core.yml` -> direct host access for core data services
- `docker-compose.dev-orchestration.yml` -> direct host access for orchestration UIs
- `docker-compose.dev-sqlserver.yml` -> direct host access for SQL Server
- `docker-compose.runtime.ollama.*.yml` -> optional containerized runtime variants

This directory defines the stack as a layered compose model rather than a single monolithic stack.

---

### `platform/`

Contains assets used by the packaged services.

Examples:

- service Dockerfiles
- dashboard assets
- orchestration build context
- monitoring configuration

This directory represents what the shared services run from.

---

### `apps/`

Contains optional integrated services that may run alongside the shared infrastructure.

Typical examples include:

- RAG APIs
- ingestion services
- feature-oriented services
- training or worker components

This directory is optional. The repository is primarily designed to support external projects connecting into the shared infrastructure backbone.

---

### `examples/`

Contains runnable examples that demonstrate how external projects consume the shared services.

These examples are intended for:

- integration reference
- experimentation
- validation of stack usage patterns

Examples are not the stack itself and should not be interpreted as the primary product surface.

---

### `docs/`

Contains the primary documentation set.

First-class documents in `docs/` include:

- `ARCHITECTURE.md`
- `SERVICES.md`
- `RUNBOOK.md`
- `ROADMAP.md`
- `ORCHESTRATION.md`
- `STRUCTURE.md`

The repository-level `README.md` provides the public overview and entry point into the documentation set.

Legacy review notes and internal working material should remain clearly separated from the first-class public documentation set.

---

### `config/`

Contains shared configuration used by the compose stack and packaged services.

Typical contents:

- `.env.example`
- local `.env`
- service configuration files

---

### `scripts/`

Contains operational scripts used to start, stop, inspect, and validate the stack.

The supported Windows operational surface is intentionally small and focused on:

- starting the default stack
- starting the developer stack with direct localhost data access
- enabling monitoring
- enabling orchestration
- stopping the stack
- checking stack status
- validating local setup

Primary entry points:

- `start.ps1` -> recommended default startup
- `start-dev.ps1` -> default startup plus localhost access to core data services

These scripts are part of the operational interface of the repository and should remain aligned with the compose source of truth.

---

### `volumes/`

Contains local persistent runtime state created by Docker and the packaged services.

Examples:

- relational database files
- document database files
- vector indexes
- object storage data
- local dashboards and metrics state
- model/runtime caches

This directory is local-only runtime state and is excluded from version control.

---

## Working Model

The repository supports two usage patterns.

### 1. Infrastructure Backbone (Recommended)

External AI or data projects live in separate repositories and connect to the shared services through APIs, databases, object storage, vector storage, and runtime endpoints.

Typical examples:

- RAG systems
- ML experimentation projects
- analytics pipelines
- agentic workflows

### 2. Repository-Integrated Services

Reusable services may also live inside `/apps` and run within the same repository environment.

This is optional and secondary to the infrastructure-backbone model.

---

## Quick Summary

| Directory | Purpose |
|---|---|
| `compose/` | Compose topology and overlays |
| `platform/` | Service assets and build context |
| `apps/` | Optional integrated services |
| `examples/` | Example stack consumers |
| `docs/` | Main documentation set |
| `config/` | Shared environment and config |
| `scripts/` | Operational commands |
| `volumes/` | Local runtime state |

---

## Related Documentation

- [README.md](../README.md) -> repository overview
- [ARCHITECTURE.md](ARCHITECTURE.md) -> system design
- [SERVICES.md](SERVICES.md) -> service catalog
- [RUNBOOK.md](RUNBOOK.md) -> operations
- [ROADMAP.md](ROADMAP.md) -> stack evolution
