#!/usr/bin/env bash
# llama.cpp (llama-server) via official Docker image
# Source (cite): https://github.com/ggerganov/llama.cpp/blob/master/docs/docker.md  (checked: 2026-05-30; verify at pre-batch gate)
#
# v2: the v1 blocker was a missing model file. We now PRE-STAGE a tiny, ungated,
# pinned GGUF into the mounted models dir BEFORE container start, named model.gguf
# (matches compose's `-m /models/model.gguf`). This separates one-time download
# from the timed probe window. Config snapshot path honors $FW_RUN.
set -eu -o pipefail
cd "$(dirname "$0")"
FW=llamacpp
FW_RUN="${FW_RUN:-$(cd ../.. && pwd)/runs/$FW}"
echo "=== $FW install $(date -u +%FT%TZ) ==="
docker --version
docker compose version

# Pinned tiny model (TinyLlama 1.1B Chat, Q4_K_M, ~669MB). TheBloke GGUF repos are
# ungated/stable. Substrate only, not an object of study.
MODEL_HOST_DIR="${LLAMACPP_MODEL_DIR:-./models}"
GGUF_URL="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
mkdir -p "$MODEL_HOST_DIR"
if [ ! -s "$MODEL_HOST_DIR/model.gguf" ]; then
  echo "[install] pre-staging GGUF (TinyLlama-1.1B-Chat Q4_K_M) -> $MODEL_HOST_DIR/model.gguf ..."
  if ! curl -fL --retry 3 --retry-delay 5 -o "$MODEL_HOST_DIR/model.gguf.part" "$GGUF_URL"; then
    echo "[install] WARN: GGUF download failed; container will fail to start (honest UNK)."
    rm -f "$MODEL_HOST_DIR/model.gguf.part"
  else
    mv "$MODEL_HOST_DIR/model.gguf.part" "$MODEL_HOST_DIR/model.gguf"
    echo "[install] GGUF staged ($(du -h "$MODEL_HOST_DIR/model.gguf" | cut -f1))."
  fi
else
  echo "[install] GGUF already staged; reusing $MODEL_HOST_DIR/model.gguf"
fi

LLAMACPP_MODEL_DIR="$MODEL_HOST_DIR" \
  docker compose -p secdefaults-$FW up -d 2>&1 || echo "[install] FAILED to start"

mkdir -p "$FW_RUN/config_snapshot"
docker inspect secdefaults-$FW > "$FW_RUN/config_snapshot/inspect.json" 2>&1 || true
echo "[install] container started; readiness handled by 'make wait'"
echo "[install] done"
