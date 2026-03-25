# Architecture

This document defines the architecture of the Modular AI & Data Platform — a local-first infrastructure backbone for building, testing, and operating modern AI systems.

It outlines system layers, service responsibilities, and interaction patterns, aligned with production-grade AI platform design.

The platform is designed as a modular infrastructure backbone for AI and data projects, allowing engineers and data scientists to experiment with modern AI system architectures locally while remaining aligned with real-world production patterns.

---

## Architecture Overview

The platform is organized into logical layers, with external systems interacting through a gateway and shared infrastructure services.

### Logical Layers

1. **External Systems**
   - RAG applications
   - ML pipelines
   - APIs
   - agentic workflows

2. **Gateway Layer**
   - Traefik
   - hostname-based routing
   - service entry point

3. **Applications and Tools Layer**
   - OpenWebUI
   - MLflow
   - Adminer
   - optional platform-integrated services under `/apps`

4. **Runtime Layer**
   - Ollama
   - external LLM APIs
   - local or host-based inference

5. **Data Layer**
   - PostgreSQL
   - MongoDB
   - Qdrant
   - MinIO
   - SQL Server (optional)

6. **Cross-Cutting Optional Layers**
   - Orchestration: Prefect, Dagster
   - Monitoring: Prometheus, Grafana, cAdvisor

Each layer provides a different set of capabilities while remaining loosely coupled.

---

## Platform Architecture Philosophy

The platform is designed to act primarily as an AI infrastructure backbone.

It provides shared services such as:

- databases
- vector search
- experiment tracking
- object storage
- monitoring
- workflow orchestration
- LLM runtime

Applications are not tightly coupled to the platform.

---

### Infrastructure Backbone Model (Recommended)

AI or data applications live in separate repositories and connect to platform services.

Examples include:

- RAG systems
- ML experimentation
- analytics pipelines
- trading systems
- chatbots
- data engineering workflows

These applications connect through:

- APIs
- databases
- MLflow
- vector search
- object storage
- LLM runtime

This keeps the platform clean while enabling reuse across multiple projects.

---

### Platform-Integrated Services

Reusable services may also be deployed inside the platform repository under `/apps`.

Examples include:

- RAG APIs
- ingestion pipelines
- feature store services
- model serving APIs
- training workers

This approach is optional and complements the backbone model.

---

## Design Principle: Loose Coupling

Services are designed to operate independently and communicate through well-defined interfaces such as HTTP APIs, database connections, or service endpoints.

This enables:

- independent scaling
- service replacement without system-wide impact
- reuse across multiple projects
- clearer system boundaries

---

## Architecture Layers

### Gateway Layer

**Traefik**

Responsible for:

- HTTP routing
- service discovery
- hostname-based access (`*.localhost`)
- entry point for platform services

---

### Applications and Tools Layer

User-facing and platform-facing tools include:

- **OpenWebUI** — LLM interaction interface
- **MLflow** — experiment tracking and model registry
- **Adminer** — database administration UI

Optional application services may also exist in `/apps`.

These components provide direct access to platform capabilities.

---

### Runtime Layer

**Ollama / External LLM APIs**

Provides LLM execution.

The platform follows a runtime abstraction model:

- local runtime via Ollama
- external APIs such as OpenAI

#### Host Runtime Model

In most local-first setups:

- Ollama runs on the host machine outside Docker
- containers connect via `host.docker.internal`

Benefits include:

- direct GPU access
- simpler model lifecycle
- reduced container complexity

Containerized runtime remains optional.

---

### Data Layer

The data layer acts as the central backbone of the platform, supporting both operational and analytical workloads.

#### PostgreSQL

Primary relational database for:

- application backends
- MLflow metadata
- orchestration state
- structured pipelines

#### Microsoft SQL Server (Optional)

Enterprise analytics database for:

- BI workloads
- Power BI integration
- reporting systems

#### MongoDB

Document database for:

- ingestion pipelines
- semi-structured datasets
- metadata storage

#### Qdrant

Vector database for:

- embeddings
- semantic search
- RAG pipelines

#### MinIO

S3-compatible object storage for:

- datasets
- ML artifacts
- model files
- experiment outputs

---

### Orchestration Layer (Optional)

Workflow orchestration services include:

- **Prefect**
- **Dagster**

Used for:

- data pipelines
- ML workflows
- scheduling
- automation

These operate as consumers of platform services, not infrastructure controllers.

---

### Monitoring Layer (Optional)

Observability services include:

- **Prometheus** — metrics collection
- **Grafana** — dashboards
- **cAdvisor** — container metrics

Monitoring is optional and can be enabled as needed.

---

## Data Flow Examples

### Chat Request

1. User accesses OpenWebUI through Traefik  
2. OpenWebUI sends the prompt to Ollama or an external API  
3. Response is returned to the user  

### Experiment Tracking

1. Training script logs metrics to MLflow  
2. MLflow stores metadata in PostgreSQL  
3. Artifacts are stored in MinIO  
4. Results are viewed through the MLflow UI  

### RAG Pipeline

1. Documents are ingested  
2. Text is chunked  
3. Embeddings are generated  
4. Vectors are stored in Qdrant  
5. Metadata is stored in MongoDB  
6. Artifacts are stored in MinIO  
7. Queries perform semantic retrieval  
8. Context is sent to the LLM  
9. Response is generated  

---

## Related Documentation

- **[README.md](../README.md)** — platform overview
- **[STRUCTURE.md](STRUCTURE.md)** — repository structure
- **[SERVICES.md](SERVICES.md)** — service catalog
- **[RUNBOOK.md](RUNBOOK.md)** — operational procedures
- **[ORCHESTRATION.md](ORCHESTRATION.md)** — orchestration architecture
- **[ROADMAP.md](ROADMAP.md)** — platform evolution
