# trit-librarian

A fully local, CPU-first RAG assistant over technical books and docs
(EPUB/MOBI/AZW3/PDF/MD/TXT). Everything runs in one rootless Podman pod; the
only published port is `127.0.0.1:7860`. No network is needed at runtime.

Status: phase 0 (scaffold). The components below are not implemented yet.

## Architecture

```
                    127.0.0.1:7860 (only published port)
                              |
+- pod: trit -----------------+---------------------------------------------+
|                             v                                             |
|  app (Gradio + ingest)  --> llm     llama-server   :8080  CPU             |
|          |              --> qdrant                 :6333  CPU             |
|          |              --> embed   TEI bge-m3     :8081  GPU (CDI)       |
|          |              --> rerank  TEI reranker   :8082  GPU (CDI)       |
|                                                                           |
|  volumes: models  qdrant-data  library  uploads                           |
+---------------------------------------------------------------------------+
```

Generator: Ternary Bonsai 4B, ternary GGUF (`Q2_0`) on upstream llama.cpp.
Retrieval: bge-m3 dense + BM25 sparse, fused with RRF, reranked by
bge-reranker-v2-m3. Vector store: Qdrant.

## Quickstart

Requires Python 3.12, [`uv`](https://docs.astral.sh/uv/) and
[`just`](https://just.systems/).

```sh
uv sync          # create the venv and install dev dependencies
just lint test   # ruff + pytest
just             # list all recipes
```

Pod operations (`just up`, `just ingest`, `just bundle`) arrive in later phases.

## Limitations

- English-only generation. Source documents may be in other languages —
  retrieval with bge-m3 is cross-lingual — but answers are English.
- CPU-only generation. The 4 GB GPU is reserved for embedding and reranking.
- Single user, loopback only. No authentication, no remote access.
- Scanned PDFs go through Tesseract OCR; no handwriting, no table layout
  reconstruction.
