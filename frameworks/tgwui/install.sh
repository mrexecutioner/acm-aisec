#!/usr/bin/env bash
# Text-Generation-WebUI (oobabooga) via official Docker quickstart
# Source (cite): https://github.com/oobabooga/text-generation-webui/wiki/09-%E2%80%90-Docker  (checked: 2026-05-30; verify at pre-batch gate)
#
# v2: CPU image (atinoda/text-generation-webui:default-cpu) with --listen --api.
# No model is loaded by default (that IS the default posture); the OpenAI-compat
# API /v1/models comes up regardless, which is the readiness gate. Inference probes
# may return errors with no model loaded, that is honest default behavior.
# Config snapshot path honors $FW_RUN.
set -eu -o pipefail
cd "$(dirname "$0")"
FW=tgwui
FW_RUN="${FW_RUN:-$(cd ../.. && pwd)/runs/$FW}"
echo "=== $FW install $(date -u +%FT%TZ) ==="
docker --version
docker compose version

docker compose -p secdefaults-$FW up -d 2>&1 || echo "[install] FAILED to start"

mkdir -p "$FW_RUN/config_snapshot"
docker inspect secdefaults-$FW > "$FW_RUN/config_snapshot/inspect.json" 2>&1 || true
echo "[install] container started (API on :5000); readiness handled by 'make wait'"
echo "[install] done"
