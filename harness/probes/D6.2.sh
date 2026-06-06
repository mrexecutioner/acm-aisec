#!/usr/bin/env bash
# D6.2 - prompt/response disk logging default? (v6)
# Seed a unique sentinel via the CORRECT per-framework inference payload, confirm
# the request was processed (2xx), then COMPREHENSIVELY search the container's
# real data/log locations for the sentinel in cleartext.
#
# Honesty discipline: absence of evidence != evidence of absence.
#  - HIT  -> PROMPT_FOUND_IN_LOGS=1 (scorer: INSECURE/HIGH, with file path)
#  - MISS + seeding 2xx + comprehensive search -> scorer: SECURE
#  - seeding NOT 2xx (e.g. tgwui no model -> 500) -> scorer: UNK (logging not exercised)
# The scorer (score_D6_2) reads the embedded inference status + the marker; it is
# unchanged. We only (a) inject the sentinel into the real payload, and (b) widen
# the search and record every path searched.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D6.2"
OUT="$FW_RUN/probes/${PID}.txt"
CTR="${EP_CONTAINER_NAME:-}"
if [ -z "$CTR" ] || ! command -v docker >/dev/null 2>&1; then
  write_stub "$PID" "no container available"; exit 0
fi
if [ -z "${EP_INFERENCE:-}" ] || [ -z "${EP_PORT:-}" ]; then
  write_stub "$PID" "inference endpoint required to seed sentinel"; exit 0
fi

SENTINEL="SENTINEL-$(date +%s)-$(head -c6 /dev/urandom | od -An -tx1 | tr -d ' \n')"
# Inject the sentinel into the real payload's prompt/content/inputs field (robust
# across {"prompt"}, {"inputs"}, and {"messages":[{"content"}]} shapes).
# NB: avoid ${VAR:-{...}} (ARTIFACT-6 brace bug appends a stray '}').
BASE="${EP_INFERENCE_PAYLOAD:-}"; [ -n "$BASE" ] || BASE='{"prompt":"PLACEHOLDER"}'
BODY=$(SENT="$SENTINEL" PAYLOAD="$BASE" python3 - <<'PY'
import json,os
sent=os.environ["SENT"]; p=os.environ["PAYLOAD"]
try:
    d=json.loads(p)
except Exception:
    print(json.dumps({"prompt":sent})); raise SystemExit
def inject(d):
    if isinstance(d,dict):
        for k in ("prompt","inputs"):
            if k in d and isinstance(d[k],str): d[k]=sent
        if "messages" in d and isinstance(d["messages"],list):
            for m in d["messages"]:
                if isinstance(m,dict) and isinstance(m.get("content"),str): m["content"]=sent
    return d
print(json.dumps(inject(d)))
PY
)

# Real data/log locations to search (record them all). Includes the configured
# data dir plus common log/working roots.
SEARCH_ROOTS="${EP_DATA_DIR_IN_CONTAINER:-} /var/log /tmp /root/.cache /root/.ollama /app /data /build /home"

{
  echo "# $PID - sentinel='$SENTINEL'"
  echo "# timestamp_utc: $(date -u +%FT%TZ)"
  echo "# payload sent (sentinel-injected): $BODY"
  echo "# --- inference call (seeding) ---"
  # Generous timeout: we only need the prompt PROCESSED + a 2xx; unbounded
  # generation length must not time the seeding call out (else a false UNK).
  TRANSCRIPT="/dev/stdout" bash "$ROOT/harness/lib/curl_local.sh" \
    --method "${EP_INFERENCE_METHOD:-POST}" \
    --url "$(local_url "$EP_INFERENCE")" \
    --header 'Content-Type: application/json' --timeout 120 \
    --data "$BODY" --note "D6.2 sentinel" 2>&1 || true
  sleep 3
  echo ""
  echo "# --- search roots (existing only) ---"
  EXIST=$(docker exec "$CTR" sh -c 'for d in '"$SEARCH_ROOTS"'; do [ -e "$d" ] && echo "$d"; done' 2>/dev/null || true)
  echo "searched: $(echo $EXIST | tr "\n" " ")"
  echo "# --- grep for sentinel across those roots ---"
  HITS=$(docker exec "$CTR" sh -c \
    "grep -rIl '$SENTINEL' $(echo $EXIST | tr '\n' ' ') 2>/dev/null | head -50" 2>/dev/null || true)
  # Also catch very recently modified files anywhere (last 2 min) that contain it
  RECENT=$(docker exec "$CTR" sh -c \
    "find / -xdev -type f -mmin -2 2>/dev/null | head -2000 | xargs -r grep -Il '$SENTINEL' 2>/dev/null | head -20" 2>/dev/null || true)
  ALL=$(printf '%s\n%s\n' "$HITS" "$RECENT" | grep -v '^$' | sort -u || true)
  if [ -n "$ALL" ]; then
    echo "PROMPT_FOUND_IN_LOGS=1"
    echo "$ALL"
  else
    echo "PROMPT_FOUND_IN_LOGS=0"
    echo "(sentinel not found in searched roots or in files modified during the call)"
  fi
} > "$OUT"
