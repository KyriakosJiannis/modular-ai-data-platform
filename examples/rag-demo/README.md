# RAG Demo

This example validates the platform's retrieval workflow by ingesting documents, storing embeddings in Qdrant, and generating answers with a local LLM through Ollama.

## What It Proves

- The platform can support an end-to-end RAG flow with local infrastructure
- External projects can use Qdrant and Ollama together without cloud dependencies
- Document ingestion, retrieval, and answer generation work as a connected path

## Retrieval Flow

Documents -> Chunking -> Embeddings -> Qdrant -> Retriever -> LLM -> Answer

## Required Services

Start the platform with direct data access enabled:

```powershell
.\scripts\windows\up-dev-tools.ps1
```

Expected services:

- Qdrant -> http://localhost:6333
- Ollama -> http://localhost:11434

## Install

```powershell
cd examples/rag-demo
pip install -r requirements.txt
```

## Run

```powershell
jupyter notebook rag_demo.ipynb
```

## Expected Outcome

After running the notebook, you should have:

- a Qdrant collection populated with embedded platform documents
- a retrieval step that returns relevant context for user questions
- generated answers grounded in the retrieved content

## Notes

- The example is intentionally lightweight so the retrieval path is easy to inspect
- It uses local models through Ollama to keep the workflow self-contained
- It is a reference integration pattern, not a full application template

## Related Documentation

- [README.md](../README.md)
- [ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [SERVICES.md](../../docs/SERVICES.md)
