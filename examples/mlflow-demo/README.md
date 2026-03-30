# MLflow Demo

This example shows a simple local experiment-tracking workflow using the Harmonia stack.

- Demonstrates: model training, run tracking, metric logging, and artifact storage
- Uses: MLflow, PostgreSQL-backed tracking, and MinIO-backed artifacts
- Outcome: a readable notebook that proves the stack can support practical local MLOps workflows

## Why Run It

This is a good example if you want to validate that the stack supports repeatable experimentation, not just infrastructure startup. It shows the basic MLflow feedback loop end to end.

## Services Used

- MLflow for experiment tracking
- PostgreSQL for tracking metadata
- MinIO for artifacts

## Quick Start

Start the stack with the default startup path:

```powershell
.\scripts\windows\start.ps1
```

Then install dependencies and open the notebook:

```powershell
cd examples/mlflow-demo
pip install -r requirements.txt
jupyter notebook mlflow_demo.ipynb
```

## Expected Result

After running the notebook, you should see:

- one or more runs recorded in MLflow
- logged parameters and evaluation metrics
- generated artifacts available through the stack-backed artifact store

Open:

- `http://mlflow.localhost`

## Files

```text
examples/mlflow-demo/
├── artifacts/
├── data/
├── mlflow_demo.ipynb
├── README.md
└── requirements.txt
```

## Notes

- The notebook keeps the workflow readable and easy to adapt
- It is designed to validate the tracking path, not to benchmark model quality
- It can be reused as a starting point for external ML experiments

## Next Steps

- Change the model or dataset in the notebook
- Log additional metrics or artifacts
- Reuse the same tracking setup in a separate training project

## Related Documentation

- [examples/README.md](../README.md)
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [SERVICES.md](../../docs/SERVICES.md)
