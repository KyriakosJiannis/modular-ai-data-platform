# Architecture

Harmonia is a local-first AI infrastructure stack for running shared services used by AI and data workflows.

## Layers

1. **Gateway**: Traefik for local routing and service entry points
2. **Tools**: OpenWebUI, MLflow, Adminer
3. **Runtime**: Ollama or external LLM APIs
4. **Data**: PostgreSQL, MongoDB, Qdrant, MinIO, optional SQL Server
5. **Optional Layers**: Prefect, Dagster, Prometheus, Grafana, cAdvisor

## Model

- External projects are the primary consumers of the stack
- `/apps` is optional and secondary
- Services are loosely coupled and connected through HTTP, databases, and shared endpoints
- The stack is local-first and production-inspired, but not a production control plane

## Typical Flows

- **Chat**: OpenWebUI -> Ollama or external API
- **Experiment Tracking**: training code -> MLflow -> PostgreSQL + MinIO
- **RAG**: documents -> embeddings -> Qdrant -> retrieval -> LLM response

## Notes

- Traefik is used for routing, not as an advanced AI gateway
- Orchestration and monitoring are optional
- The repository is primarily an infrastructure backbone, not a full application platform

## Trade-offs

- The stack favors local reproducibility over production hardening by default
- Some defaults prioritize visibility and debugging speed over stricter security
- Persistent storage is optimized for local inspection, not server-grade operations

## Related Docs

- [README.md](../README.md)
- [STRUCTURE.md](STRUCTURE.md)
- [SERVICES.md](SERVICES.md)
- [RUNBOOK.md](RUNBOOK.md)
- [ROADMAP.md](ROADMAP.md)
