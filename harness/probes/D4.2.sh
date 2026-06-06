#!/usr/bin/env bash
# D4.2 - default rate limiting
# Send 100 rapid requests to a cheap endpoint (list-models) and concatenate all
# status lines into the transcript. Scorer counts 429/503 vs total.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D4.2"
need_var "$PID" EP_PORT || exit 0

if [ -n "${EP_LIST_MODELS:-}" ]; then
  URL="$(local_url "$EP_LIST_MODELS")"
  METHOD="GET"
  BODY=""
elif [ -n "${EP_INFERENCE:-}" ]; then
  URL="$(local_url "$EP_INFERENCE")"
  METHOD="${EP_INFERENCE_METHOD:-POST}"
  # NOTE: same brace bug as D2.1/D4.1 (ARTIFACT-6), ${VAR:-{}} appends a stray
  # '}'. Assign safely. (Only reached when a framework has no list-models endpoint;
  # unexercised for the current set, all of which expose /v1/models.)
  BODY="${EP_INFERENCE_PAYLOAD:-}"
  [ -n "$BODY" ] || BODY='{}'
else
  write_stub "$PID" "no list-models or inference endpoint to hammer"; exit 0
fi

OUT="$FW_RUN/probes/${PID}.txt"
{
  echo "# $PID - 100x burst to $URL"
  echo "# timestamp_utc: $(date -u +%FT%TZ)"
  echo "# --- raw response (headers + body) ---"
  for i in $(seq 1 100); do
    if [ "$METHOD" = "GET" ]; then
      curl -sS -o /dev/null -w "HTTP/1.1 %{http_code} (t=%{time_total})\n" \
        --max-time 5 "$URL" 2>&1 || echo "HTTP/1.1 000 curl_error_$?"
    else
      curl -sS -o /dev/null -w "HTTP/1.1 %{http_code} (t=%{time_total})\n" \
        --max-time 5 -X "$METHOD" -H 'Content-Type: application/json' \
        --data-binary "$BODY" "$URL" 2>&1 || echo "HTTP/1.1 000 curl_error_$?"
    fi
  done
  echo "# --- meta ---"
  echo "# curl_exit: 0"
} > "$OUT"
