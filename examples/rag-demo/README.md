# RAG Demo

This example shows an end-to-end local retrieval workflow using the Harmonia stack.

- Demonstrates: document ingestion, embedding, vector retrieval, and grounded answer generation
- Uses: Qdrant, Ollama, and local sample data
- Outcome: a readable notebook that proves the stack can support a practical local RAG path

## Why Run It

This is a good example if you want to validate that the stack is useful for more than service packaging. It shows a complete retrieval flow instead of a thin chat wrapper.

## Services Used

- Qdrant for vector storage and retrieval
- Ollama for local model access

## Quick Start

Start the stack with direct data access enabled:

```powershell
.\scripts\windows\start-dev.ps1
```

Then install dependencies and open the notebook:

```powershell
cd examples/rag-demo
pip install -r requirements.txt
jupyter notebook rag_demo.ipynb
```

## Expected Result

After running the notebook, you should see:

- a Qdrant collection populated with embedded documents
- retrieval returning relevant context for a sample query
- generated answers grounded in the retrieved content

## Sample Flow

Documents -> Chunking -> Embeddings -> Qdrant -> Retrieval -> LLM -> Answer

## Files

```text
examples/rag-demo/
├── data/
├── rag_demo.ipynb
├── README.md
└── requirements.txt
```

## Notes

- The notebook is intentionally lightweight so the retrieval path remains easy to inspect
- It uses local model access through Ollama to keep the workflow self-contained
- It is a reference integration pattern, not a full application template

## Next Steps

- Swap in your own documents under `data/`
- Change the embedding or model choice in the notebook
- Use the same service pattern in an external RAG application

## Related Documentation

- [examples/README.md](../README.md)
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [SERVICES.md](../../docs/SERVICES.md)
