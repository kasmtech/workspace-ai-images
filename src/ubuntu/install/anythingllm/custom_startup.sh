#!/usr/bin/env bash
set -ex
exec env APPDIR=/opt/AnythingLLMDesktop/anythingllm-desktop "/opt/AnythingLLMDesktop/start" --no-sandbox
