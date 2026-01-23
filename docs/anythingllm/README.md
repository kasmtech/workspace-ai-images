
# AnythingLLM Workspace configuration


### Pre-configuring Workspace to use a local or private model

*You will need access to a machine with a recent NVIDIA graphics card.*

1. Ensure the Ollama host is setup with the appropriate NVIDIA drivers - follow [this](https://kasm.com/docs/latest/how_to/gpu.html#ubuntu-24-04-lts) script for a quick and easy way to do this for Ubuntu 24.04 systems. Reboot if necessary.
2. Install [ollama](https://ollama.com/) on a host with GPU `curl -fsSL https://ollama.com/install.sh | sh` (install docs [here](https://github.com/ollama/ollama/blob/main/docs/linux.md))
3. Pull a model (e.g. `ollama pull phi4:latest`)
4. Ensure ollama is serving the model, e.g:
```shell
$ curl -X POST http://<ollama host>:11434/api/generate -d '{
  "model": "phi4:latest",
  "prompt": "hi, please identify yourself"
}'
```
should return output from the model.

5. Ensure any firewall rules permit access to the Ollama URL

6. Set the following environment variables inside the `Docker Run Config` of the workspace: 
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

7. Start an AnythingLLM workspace and confirm that AnythingLLM is pre-configured - you should be able to start a chat right away with the private model.
