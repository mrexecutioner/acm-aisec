#!/usr/bin/env bash
# D5.3 - runs as root / privileged container default?
# docker inspect the running container; capture User and Privileged fields.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D5.3"
OUT="$FW_RUN/probes/${PID}.txt"
if ! command -v docker >/dev/null 2>&1; then
  write_stub "$PID" "docker unavailable on host"; exit 0
fi
CTR="${EP_CONTAINER_NAME:-}"
if [ -z "$CTR" ]; then
  write_stub "$PID" "EP_CONTAINER_NAME unset"; exit 0
fi
{
  echo "# $PID - container User + Privileged"
  echo "# timestamp_utc: $(date -u +%FT%TZ)"
  echo "# container: $CTR"
  docker inspect "$CTR" --format \
    'User={{json .Config.User}} Privileged={{json .HostConfig.Privileged}} CapAdd={{json .HostConfig.CapAdd}}' \
    2>&1 || echo "(docker inspect failed)"
  echo ""
  echo "# Also: whoami inside container ->"
  docker exec "$CTR" sh -c 'id 2>/dev/null || whoami 2>/dev/null || echo NO_ID' 2>&1 \
    || echo "(docker exec failed)"
  echo ""
  echo "# Full JSON:"
  docker inspect "$CTR" 2>&1 | head -200
} > "$OUT"
