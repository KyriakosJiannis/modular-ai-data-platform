# Examples

These examples validate how external projects consume services from the AI Platform.

## Purpose

Each example is designed to prove a specific platform capability:

- `mlflow-demo/` validates experiment tracking and artifact logging
- `rag-demo/` validates vector retrieval and local LLM integration

They are reference integrations for the platform's infrastructure-backbone model, not platform-integrated services. For services that run inside the platform itself, see `apps/`.

## Format

Examples use lightweight notebooks and scripts so the platform interaction remains easy to inspect.

## Startup Requirements

Use the startup mode required by each example:

- `mlflow-demo/` -> `.\scripts\windows\up-tools.ps1`
- `rag-demo/` -> `.\scripts\windows\up-dev-tools.ps1`

After the required services are running, install the example dependencies and open the notebook from the example directory.
