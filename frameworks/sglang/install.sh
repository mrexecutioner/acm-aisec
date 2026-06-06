#!/usr/bin/env bash
# SGLang via official Docker quickstart
# Source (cite): https://docs.sglang.ai/start/install.html  (checked: 2026-05-30; verify at pre-batch gate)
#
# v2: ungated tiny model Qwen/Qwen2.5-0.5B-Instruct (set in compose.yml; v1 used
# HF-gated meta-llama/Llama-3.2-1B-Instruct which could not download). Weights
# download on boot; the generous readiness ceiling (`make wait`, 15 min) covers it.
# Requires NVIDIA CUDA; a genuine no-GPU failure is an honest UNK. $FW_RUN-aware.
set -eu -o pipefail
cd "$(dirname "$0")"
FW=sglang
FW_RUN="${FW_RUN:-$(cd ../.. && pwd)/runs/$FW}"
echo "=== $FW install $(date -u +%FT%TZ) ==="
docker --version
docker compose version

if ! docker info 2>/dev/null | grep -qi 'nvidia'; then
  echo "[install] WARN: NVIDIA docker runtime not detected. SGLang may fail to start (honest UNK)."
fi

docker compose -p secdefaults-$FW up -d 2>&1 || echo "[install] FAILED to start"

mkdir -p "$FW_RUN/config_snapshot"
docker inspect secdefaults-$FW > "$FW_RUN/config_snapshot/inspect.json" 2>&1 || true
docker exec secdefaults-$FW env > "$FW_RUN/config_snapshot/env.txt" 2>&1 || true
echo "[install] container started (model Qwen/Qwen2.5-0.5B-Instruct); readiness handled by 'make wait'"
echo "[install] done"
