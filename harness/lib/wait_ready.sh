#!/usr/bin/env bash
# wait_ready.sh - poll a framework's readiness endpoint until it returns 2xx,
# or until a ceiling is reached. This replaces v1's fixed-timer health checks so
# probes fire only after the server is actually serving (v1 ARTIFACT-4).
#
# Reads EP_PORT and EP_READINESS from frameworks/<fw>/endpoints.yml (loaded via
# load_endpoints.sh). Records time-to-ready to $FW_RUN/ready.txt and stdout so the
# batch log distinguishes "slow boot" from "won't boot".
#
# LOCAL ONLY: only ever contacts 127.0.0.1 (PROTOCOL.md constraint 1).
#
# Required env: FRAMEWORK, FW_DIR, FW_RUN, ROOT
# Optional env: CEILING (seconds, default 900), INTERVAL (seconds, default 5)
#
# Always exits 0: a genuine timeout is a true negative the probes record as UNK;
# the batch must not abort. Self-test: bash wait_ready.sh --selftest
set -eu -o pipefail

if [ "${1:-}" = "--selftest" ]; then
  # Pure-logic checks (no network): the 2xx classifier.
  is2xx() { [ "$1" -ge 200 ] 2>/dev/null && [ "$1" -lt 300 ] 2>/dev/null; }
  fail=0
  for c in 200 204 299; do is2xx "$c" || { echo "selftest FALSE NEG on $c"; fail=1; }; done
  for c in 000 301 401 404 500 503; do if is2xx "$c"; then echo "selftest FALSE POS on $c"; fail=1; fi; done
  if [ "$fail" -eq 0 ]; then echo "wait_ready.sh selftest OK"; exit 0; else exit 1; fi
fi

: "${FRAMEWORK:?need FRAMEWORK}"
: "${FW_DIR:?need FW_DIR}"
: "${FW_RUN:?need FW_RUN}"
: "${ROOT:?need ROOT}"
CEILING="${CEILING:-900}"
INTERVAL="${INTERVAL:-5}"

mkdir -p "$FW_RUN"
OUT="$FW_RUN/ready.txt"

# shellcheck disable=SC1091
source "$ROOT/harness/lib/load_endpoints.sh" "$FW_DIR/endpoints.yml"

PORT="${EP_PORT:-}"
READINESS="${EP_READINESS:-}"

if [ -z "$PORT" ] || [ -z "$READINESS" ]; then
  {
    echo "READY_STATUS=SKIPPED"
    echo "reason=no port/readiness endpoint configured in endpoints.yml"
    echo "framework=$FRAMEWORK"
  } > "$OUT"
  echo "[wait] $FRAMEWORK: SKIPPED (no readiness endpoint configured)"
  exit 0
fi

URL="http://127.0.0.1:${PORT}${READINESS}"
case "$URL" in
  http://127.0.0.1:*|http://localhost:*) : ;;
  *) echo "[wait] REFUSED non-local readiness URL: $URL" >&2;
     echo "READY_STATUS=REFUSED_NONLOCAL" > "$OUT"; exit 0;;
esac

start=$(date +%s)
last_code=000
ready=0
while :; do
  last_code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 5 "$URL" 2>/dev/null || echo 000)
  now=$(date +%s); elapsed=$(( now - start ))
  if [ "$last_code" -ge 200 ] 2>/dev/null && [ "$last_code" -lt 300 ] 2>/dev/null; then
    ready=1; break
  fi
  if [ "$elapsed" -ge "$CEILING" ]; then break; fi
  sleep "$INTERVAL"
done
end=$(date +%s); ttr=$(( end - start ))

if [ "$ready" -eq 1 ]; then
  {
    echo "READY_STATUS=READY"
    echo "time_to_ready_seconds=$ttr"
    echo "readiness_url=$URL"
    echo "last_http_code=$last_code"
    echo "ceiling_seconds=$CEILING"
  } > "$OUT"
  echo "[wait] $FRAMEWORK: READY in ${ttr}s (via $READINESS -> $last_code)"
else
  {
    echo "READY_STATUS=FAILED"
    echo "time_to_ready_seconds=$ttr"
    echo "readiness_url=$URL"
    echo "last_http_code=$last_code"
    echo "ceiling_seconds=$CEILING"
    echo "reason=readiness never returned 2xx within ceiling (TRUE startup failure)"
  } > "$OUT"
  echo "[wait] $FRAMEWORK: FAILED to become ready within ${CEILING}s (last code $last_code) — TRUE negative; dependent items will be UNK"
fi
exit 0
