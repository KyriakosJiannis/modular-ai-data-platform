# Orchestration

Harmonia can optionally run Prefect and Dagster for workflow orchestration.

## Tools

- **Prefect**: best for Python-first workflows, ML pipelines, and LLM jobs
- **Dagster**: best for data pipelines, assets, and lineage-oriented workflows

## Start

```powershell
.\scripts\windows\up-orchestration.ps1
.\scripts\windows\up-full-orchestration.ps1
```

## Access

- Prefect: `http://prefect.localhost`
- Dagster: `http://dagster.localhost`

Direct localhost access is available only when the orchestration dev overlay is enabled:

- Prefect: `http://localhost:4201`
- Dagster: `http://localhost:3051`

## Notes

- Orchestration is optional
- These services use the shared stack; they do not manage the infrastructure itself
- Typical uses: ingestion, scheduling, training flows, RAG indexing, and automation

## Related Docs

- [RUNBOOK.md](RUNBOOK.md)
- [SERVICES.md](SERVICES.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
