#!/usr/bin/env bash
# D6.1 - telemetry / phone-home on by default? (v6)
# Captures NON-private egress while the framework (re)boots AND serves one benign
# inference, using a host-network tcpdump sidecar (the framework images have no
# tcpdump). Restarting the framework container with capture already running is how
# we catch BOOT-time phone-home.
#
# Honesty discipline: absence of evidence != evidence of absence.
#   - capture didn't attach / framework didn't become ready -> D61_CAPTURE=INCOMPLETE -> UNK
#   - egress to external dest(s) from the container IP -> listed; scorer flags for
#     human telemetry-vs-CDN confirmation (model weights are pre-staged, so inference
#     egress should not be a model pull)
#   - no external egress AND capture covered boot+inference -> SECURE
#
# Writes runs_v6/<fw>/probes/D6.1.txt (+ d61.pcap, gitignored).
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D6.1"; OUT="$FW_RUN/probes/${PID}.txt"
CTR="${EP_CONTAINER_NAME:-}"
CAP="secdefaults-cap-${FRAMEWORK}"
PCAP_DIR="$FW_RUN"; PCAP="$PCAP_DIR/d61.pcap"
PORT="${EP_PORT:-}"; READY="${EP_READINESS:-/}"
FILTER='ip and not dst net 127.0.0.0/8 and not dst net 10.0.0.0/8 and not dst net 172.16.0.0/12 and not dst net 192.168.0.0/16 and not dst net 169.254.0.0/16 and not dst net 224.0.0.0/4'

if [ -z "$CTR" ] || ! command -v docker >/dev/null 2>&1; then write_stub "$PID" "no container"; exit 0; fi

exec > "$OUT" 2>&1
echo "# $PID - telemetry/phone-home capture (boot + one inference)"
echo "# timestamp_utc: $(date -u +%FT%TZ)"
echo "# method: host-net alpine+tcpdump sidecar; restart framework to catch boot egress"

docker rm -f "$CAP" >/dev/null 2>&1 || true
rm -f "$PCAP" 2>/dev/null || true
# Start the capture sidecar on the host network namespace.
docker run -d --name "$CAP" --net=host --cap-add=NET_ADMIN -v "$PCAP_DIR":/cap alpine \
  sh -c "apk add -q --no-cache tcpdump >/dev/null 2>&1 && tcpdump -i any -nn -U -w /cap/d61.pcap '$FILTER'" >/dev/null 2>&1 \
  || { echo "D61_CAPTURE=INCOMPLETE (could not start capture sidecar)"; exit 0; }

# Wait until tcpdump is actually capturing (pcap file appears + sidecar still up).
ok=0
for i in $(seq 1 20); do
  sleep 2
  if docker ps --format '{{.Names}}' | grep -q "^$CAP$" && [ -f "$PCAP" ]; then ok=1; break; fi
done
[ "$ok" = "1" ] || { echo "D61_CAPTURE=INCOMPLETE (tcpdump did not start within 40s)"; docker rm -f "$CAP" >/dev/null 2>&1 || true; exit 0; }
echo "# capture started; restarting framework to capture boot egress ..."

docker restart "$CTR" >/dev/null 2>&1 || true
# Wait for readiness (bounded; this probe is not the place for a 15-min wait).
ready=0
for i in $(seq 1 90); do
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 4 "http://127.0.0.1:${PORT}${READY}" 2>/dev/null || echo 000)
  [ "$code" -ge 200 ] 2>/dev/null && [ "$code" -lt 300 ] 2>/dev/null && { ready=1; break; }
  sleep 2
done
echo "# framework ready after restart: $ready (last code ${code:-NA})"

# One benign inference call (weights are pre-staged, so this should not pull).
if [ "$ready" = "1" ] && [ -n "${EP_INFERENCE:-}" ]; then
  IB="${EP_INFERENCE_PAYLOAD:-}"; [ -n "$IB" ] || IB='{"prompt":"hello"}'
  curl -sS -o /dev/null --max-time 30 -X "${EP_INFERENCE_METHOD:-POST}" \
    -H 'Content-Type: application/json' --data-binary "$IB" \
    "http://127.0.0.1:${PORT}${EP_INFERENCE}" 2>/dev/null || true
fi
sleep 4
docker stop "$CAP" >/dev/null 2>&1 || true

# Attribute egress to the container's bridge IP (excludes the sidecar's own apk traffic, which is src=host).
FW_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CTR" 2>/dev/null || true)
echo "# container bridge IP: ${FW_IP:-unknown}"
echo "# --- external destinations observed FROM the container IP ---"
DESTS=$(docker run --rm -v "$PCAP_DIR":/cap alpine sh -c \
  "apk add -q --no-cache tcpdump >/dev/null 2>&1 && tcpdump -nn -r /cap/d61.pcap ${FW_IP:+src host $FW_IP} 2>/dev/null | grep -oE '> [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u" 2>/dev/null || true)
docker rm -f "$CAP" >/dev/null 2>&1 || true

if [ "$ready" != "1" ]; then
  echo "D61_CAPTURE=INCOMPLETE (framework not ready after restart; boot/inference egress not reliably covered)"
  exit 0
fi
if [ -n "$DESTS" ]; then
  echo "$DESTS"
  echo "D61_CAPTURE=OK"
  echo "D61_EXTERNAL_EGRESS=YES"
else
  echo "(no external (non-private) destinations from container IP during boot+inference)"
  echo "D61_CAPTURE=OK"
  echo "D61_EXTERNAL_EGRESS=NO"
fi
