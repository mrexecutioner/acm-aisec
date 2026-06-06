#!/usr/bin/env bash
# Ollama install via official Docker quickstart
# Source (cite): https://github.com/ollama/ollama/blob/main/docs/docker.md  (checked: 2026-05-30; verify at pre-batch gate)
#
# v2: model is staged here (blocking) so it is present before probing; server
# readiness is gated separately by `make wait` (harness/lib/wait_ready.sh), not by
# a fixed timer. Config snapshot path honors $FW_RUN (set by the Makefile) so v2
# artifacts land under runs_v2/.
set -eu -o pipefail
cd "$(dirname "$0")"
FW=ollama
FW_RUN="${FW_RUN:-$(cd ../.. && pwd)/runs/$FW}"
echo "=== $FW install $(date -u +%FT%TZ) ==="
docker --version
docker compose version

# Bring up the container exactly as documented (no hardening).
docker compose -p secdefaults-$FW up -d 2>&1 || echo "[install] FAILED to start"

# Pre-stage the smallest practical model (tinyllama ~640MB) BEFORE the probe clock.
# /api/tags is up almost immediately, but inference probes need a model present;
# this pull blocks so the model is ready before `make wait`/probes run.
echo "[install] pre-staging tinyllama (blocking) ..."
for i in 1 2 3; do
  if docker exec secdefaults-$FW ollama pull tinyllama:latest 2>&1; then break; fi
  echo "[install] tinyllama pull attempt $i failed; retrying ..."
done

mkdir -p "$FW_RUN/config_snapshot"
docker exec secdefaults-$FW ollama --version > "$FW_RUN/config_snapshot/version.txt" 2>&1 || true
docker inspect secdefaults-$FW > "$FW_RUN/config_snapshot/inspect.json" 2>&1 || true
docker exec secdefaults-$FW env > "$FW_RUN/config_snapshot/env.txt" 2>&1 || true
echo "[install] container up + model staged; readiness handled by 'make wait'"
echo "[install] done"
