
# AnythingLLM Workspace configuration


### Pre-configuring Workspace to use a local or private model

1. Install [ollama](https://ollama.com/) on a host with GPU `curl -fsSL https://ollama.com/install.sh | sh` (install docs [here](https://github.com/ollama/ollama/blob/main/docs/linux.md))
2. Pull a model (e.g. `ollama pull phi4:latest`)
3. Ensure any firewall rules permit access to the Ollama URL
4. Set the following environment variables inside the `Docker Run Config` of the workspace: 
```json
{
  "environment": {
    "LLM_PROVIDER": "ollama",
    "OLLAMA_BASE_PATH": "http://<ollama host>:11434",
    "OLLAMA_MODEL_PREF": "<ollama model e.g. 'phi4:latest'>",
    "OLLAMA_MODEL_TOKEN_LIMIT": "32000",
    "OLLAMA_PERFORMANCE_MODE": "base",
    "OLLAMA_KEEP_ALIVE_TIMEOUT": "300",
    "EMBEDDING_ENGINE": "native",
    "VECTOR_DB": "lancedb"
  }
}
```
5. Start an AnythingLLM workspace and confirm that AnythingLLM is pre-configured - you should be able to start a chat right away with the private model.
