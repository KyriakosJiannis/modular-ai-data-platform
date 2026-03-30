# Examples

These examples are the fastest way to see what the stack is useful for in practice.

They are lightweight, notebook-based reference integrations for external projects using the shared infrastructure.

## Choose an Example

| Example | Best For | Start Mode | What You Get |
|---|---|---|---|
| `mlflow-demo/` | Experiment tracking and local MLOps workflows | `.\scripts\windows\start.ps1` | A notebook that logs runs, metrics, and artifacts to MLflow |
| `rag-demo/` | Retrieval workflows and local LLM integration | `.\scripts\windows\start-dev.ps1` | A notebook that ingests documents, stores embeddings, and runs retrieval against Qdrant |

## How to Use Them

1. Start the required stack mode.
2. Open the example folder.
3. Install dependencies from `requirements.txt`.
4. Launch the notebook and run it end to end.

Examples use notebooks on purpose so the service interaction stays readable and easy to inspect.

## Next Step

Pick one:

- [MLflow Demo](./mlflow-demo/README.md)
- [RAG Demo](./rag-demo/README.md)
