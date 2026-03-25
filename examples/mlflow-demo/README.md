# MLflow Demo

This example validates the platform's ML experiment-tracking path by training simple models and logging parameters, metrics, and artifacts to MLflow.

## What It Proves

- External projects can connect cleanly to the platform's MLflow service
- Runs, metrics, and artifacts are persisted through the shared platform stack
- The platform can support a standard notebook-based experimentation workflow

## Required Services

Start the platform with the tools layer enabled:

```powershell
.\scripts\windows\up-tools.ps1
```

Expected service:

- MLflow -> http://mlflow.localhost

## Install

```powershell
cd examples/mlflow-demo
pip install -r requirements.txt
```

## Run

```powershell
jupyter notebook mlflow_demo.ipynb
```

## Expected Outcome

After running the notebook, you should see:

- one or more MLflow runs recorded in the tracking UI
- logged parameters and evaluation metrics
- generated artifacts stored in the platform-backed artifact store

## Files

```text
examples/mlflow-demo/
├── mlflow_demo.ipynb
└── requirements.txt
```

## Related Documentation

- [examples/README.md](../README.md)
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [SERVICES.md](../../docs/SERVICES.md)
