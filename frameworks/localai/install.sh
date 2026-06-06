#!/usr/bin/env bash
# LocalAI install, v4 (plain image + pre-staged GGUF + model-def YAML + llama-cpp
# backend, so inference actually serves, recovers D2.1/D4.1).
# Source (cite): https://localai.io/basics/getting_started/  and
#   https://localai.io/backends/  (checked: 2026-05-31)
#
# History: v2's latest-aio-cpu downloaded multi-GB bundled models on first boot and
# blew past the readiness ceiling. v3 switched to plain localai/localai:latest +
# a pre-staged GGUF (fast boot, /readyz immediate) but the plain image neither
# auto-registers bare GGUFs nor bundles backends, so inference 404'd/500'd. v4
# adds (a) a model-definition YAML so the model registers, and (b) installs the
# llama-cpp backend from the gallery + restarts so it is picked up. $FW_RUN-aware.
set -eu -o pipefail
cd "$(dirname "$0")"
FW=localai
FW_RUN="${FW_RUN:-$(cd ../.. && pwd)/runs/$FW}"
echo "=== $FW install $(date -u +%FT%TZ) ==="
docker --version
docker compose version

MODEL_DIR="./models"
mkdir -p "$MODEL_DIR"
GGUF_URL="https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf"
SHARED_GGUF="../llamacpp/models/model.gguf"
if [ ! -s "$MODEL_DIR/tinyllama.gguf" ]; then
  if [ -s "$SHARED_GGUF" ]; then
    echo "[install] reusing already-staged GGUF from llamacpp ($(du -h "$SHARED_GGUF" | cut -f1))"
    cp "$SHARED_GGUF" "$MODEL_DIR/tinyllama.gguf"
  else
    echo "[install] pre-staging GGUF (TinyLlama-1.1B-Chat Q4_K_M) -> $MODEL_DIR/tinyllama.gguf ..."
    if curl -fL --retry 3 --retry-delay 5 -o "$MODEL_DIR/tinyllama.gguf.part" "$GGUF_URL"; then
      mv "$MODEL_DIR/tinyllama.gguf.part" "$MODEL_DIR/tinyllama.gguf"
    else
      echo "[install] WARN: GGUF download failed; LocalAI will have no model (honest UNK)."
      rm -f "$MODEL_DIR/tinyllama.gguf.part"
    fi
  fi
else
  echo "[install] GGUF already staged; reusing $MODEL_DIR/tinyllama.gguf"
fi

# Model-definition YAML so the plain image registers "tinyllama" (it does NOT
# auto-register bare GGUFs). max_tokens is set per-request by the probe payload.
cat > "$MODEL_DIR/tinyllama.yaml" <<'YAML'
name: tinyllama
backend: llama-cpp
parameters:
  model: tinyllama.gguf
YAML

docker compose -p secdefaults-$FW up -d 2>&1 || echo "[install] FAILED to start"

# The plain image ships no inference backends; install llama-cpp from the gallery,
# then restart so the server rescans /backends and can load the model.
echo "[install] installing llama-cpp backend (gallery) ..."
docker exec secdefaults-$FW /local-ai backends install llama-cpp 2>&1 | tail -2 || \
  echo "[install] WARN: backend install failed; inference items will be UNK"
docker restart secdefaults-$FW >/dev/null 2>&1 && echo "[install] restarted to pick up backend"

mkdir -p "$FW_RUN/config_snapshot"
docker inspect secdefaults-$FW > "$FW_RUN/config_snapshot/inspect.json" 2>&1 || true
docker exec secdefaults-$FW env > "$FW_RUN/config_snapshot/env.txt" 2>&1 || true
echo "[install] container started (plain image, tinyllama staged); readiness handled by 'make wait'"
echo "[install] done"
