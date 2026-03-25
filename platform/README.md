# Platform Assets

This directory contains build context, configuration, and static assets used by platform services.

It is not a second documentation layer. Compose files remain the source of truth for service topology and startup behavior, and the main repository documentation lives under `docs/`.

Subdirectories are organized by asset domain:

- `core/` - shared platform service assets
- `tools/` - UI and tool assets
- `monitoring/` - observability configuration
- `runtime/` - runtime-related assets
- `orchestration/` - orchestration service build context
- `shared/` - shared utilities and future common assets

For platform usage and operations, use:

- [README.md](../README.md)
- [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- [docs/SERVICES.md](../docs/SERVICES.md)
- [docs/RUNBOOK.md](../docs/RUNBOOK.md)
