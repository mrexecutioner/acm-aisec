#!/usr/bin/env bash
# vLLM install via official Docker quickstart
# Source (cite): https://docs.vllm.ai/en/latest/serving/deploying_with_docker.html  (checked: 2026-05-30; verify at pre-batch gate)
#
# v2: tiny model (facebook/opt-125m, set in compose.yml) downloads on boot; the
# generous readiness ceiling (`make wait`, 15 min) covers download+load so the
# probe window measures security posture, not load time. Config snapshot path
# honors $FW_RUN. Requires NVIDIA CUDA; a genuine no-GPU failure is recorded as a
# true negative (UNK) by the scorer.
set -eu -o pipefail
cd "$(dirname "$0")"
FW=vllm
FW_RUN="${FW_RUN:-$(cd ../.. && pwd)/runs/$FW}"
echo "=== $FW install $(date -u +%FT%TZ) ==="
docker --version
docker compose version

if ! docker info 2>/dev/null | grep -qi 'nvidia'; then
  echo "[install] WARN: NVIDIA docker runtime not detected. vLLM may fail to start (honest UNK)."
fi

docker compose -p secdefaults-$FW up -d 2>&1 || echo "[install] FAILED to start"

mkdir -p "$FW_RUN/config_snapshot"
docker inspect secdefaults-$FW > "$FW_RUN/config_snapshot/inspect.json" 2>&1 || true
docker exec secdefaults-$FW env > "$FW_RUN/config_snapshot/env.txt" 2>&1 || true
echo "[install] container started (model facebook/opt-125m); readiness handled by 'make wait'"
echo "[install] done"
