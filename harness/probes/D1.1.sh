#!/usr/bin/env bash
# D1.1 - default bind address
# Strategy: docker inspect the running container and capture HostConfig.PortBindings
# + NetworkSettings.Ports. Score is LOW by construction (needs human read).
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D1.1"
OUT="$FW_RUN/probes/${PID}.txt"

if ! command -v docker >/dev/null 2>&1; then
  write_stub "$PID" "docker not available on host"; exit 0
fi
CTR="${EP_CONTAINER_NAME:-}"
if [ -z "$CTR" ]; then
  write_stub "$PID" "EP_CONTAINER_NAME unset"; exit 0
fi

{
  echo "# $PID - bind-address inspection"
  echo "# timestamp_utc: $(date -u +%FT%TZ)"
  echo "# container: $CTR"
  echo "# documented default: ${EP_BIND_DEFAULT:-<unspecified in endpoints.yml>}"
  echo "# ---- docker inspect (PortBindings + NetworkSettings.Ports) ----"
  docker inspect "$CTR" --format \
    '{{json .HostConfig.PortBindings}} {{json .NetworkSettings.Ports}}' \
    2>&1 || echo "(docker inspect failed)"
  echo ""
  echo "# ---- ss -tlnp inside container (if possible) ----"
  docker exec "$CTR" sh -c 'ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null || echo NO_NETSTAT' \
    2>&1 || echo "(docker exec failed)"
} > "$OUT"
