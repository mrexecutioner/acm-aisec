#!/usr/bin/env bash
# D5.2 - arbitrary file read via path traversal (REAL probe, v6).
# Replaces the retired substring heuristic (which false-positived on a benign
# /etc/ URL in localai's gallery JSON, see INSTRUMENT_NOTES v6). This sends
# genuine traversal payloads at a file-handling endpoint and scores INSECURE only
# on CONFIRMED leakage of real /etc/passwd content (a line matching root:.*:0:0:).
#
# endpoints.yml config keys:
#   traversal_kind   : none | get_path | post_body   (none -> N/A: no file surface)
#   traversal_port   : optional port override (e.g. tgwui Gradio on 7860)
#   traversal_get    : GET path template containing {PAYLOAD}     (get_path)
#   traversal_post_ep: POST endpoint path                          (post_body)
#   traversal_post   : POST body template containing {PAYLOAD}     (post_body)
#
# Writes runs_v6/<fw>/probes/D5.2.txt. Local-only (127.0.0.1).
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"
PID="D5.2"
OUT="$FW_RUN/probes/${PID}.txt"
mkdir -p "$FW_RUN/probes"

KIND="${EP_TRAVERSAL_KIND:-none}"
PORT="${EP_TRAVERSAL_PORT:-${EP_PORT:-}}"

# Genuine traversal payloads + an absolute-path attempt. LEAK_RE validates a real
# /etc/passwd, not a mere substring.
PAYLOADS=( "../../../../etc/passwd" "..%2f..%2f..%2f..%2fetc%2fpasswd" "....//....//....//etc/passwd" "/etc/passwd" )
LEAK_RE='root:.*:0:0:'

{
  echo "# $PID - REAL path-traversal probe"
  echo "# timestamp_utc: $(date -u +%FT%TZ)"
  echo "# framework: $FRAMEWORK  kind: $KIND  port: $PORT"
  echo "# leak validation regex: $LEAK_RE"
} > "$OUT"

if [ "$KIND" = "none" ] || [ -z "$PORT" ]; then
  echo "# RESULT: NO_FILE_PATH_SURFACE (scorer -> N/A)" >> "$OUT"
  echo "# note: ${EP_TRAVERSAL_NOTE:-no unauthenticated file-path/read endpoint exposed by default}" >> "$OUT"
  exit 0
fi

leak=0; reached=0
for p in "${PAYLOADS[@]}"; do
  echo "" >> "$OUT"; echo "### payload: $p" >> "$OUT"
  if [ "$KIND" = "get_path" ]; then
    tmpl="${EP_TRAVERSAL_GET:-/{PAYLOAD}}"; path="${tmpl//\{PAYLOAD\}/$p}"
    url="http://127.0.0.1:${PORT}${path}"
    case "$url" in http://127.0.0.1:*|http://localhost:*) : ;; *) echo "REFUSED non-local" >> "$OUT"; continue;; esac
    body=$(curl -sS -i --max-time 8 "$url" 2>&1 || true)
  else # post_body
    ep="${EP_TRAVERSAL_POST_EP:-/}"; tmpl="${EP_TRAVERSAL_POST:-{\"path\":\"{PAYLOAD}\"}}"
    pbody="${tmpl//\{PAYLOAD\}/$p}"
    url="http://127.0.0.1:${PORT}${ep}"
    case "$url" in http://127.0.0.1:*|http://localhost:*) : ;; *) echo "REFUSED non-local" >> "$OUT"; continue;; esac
    body=$(curl -sS -i --max-time 8 -X POST -H 'Content-Type: application/json' --data-binary "$pbody" "$url" 2>&1 || true)
  fi
  reached=1
  echo "$body" | head -c 800 >> "$OUT"; echo "" >> "$OUT"
  if echo "$body" | grep -Eq "$LEAK_RE"; then
    leak=1
    echo "# !!! LEAK CONFIRMED: response contains /etc/passwd structure ($LEAK_RE)" >> "$OUT"
  fi
done

echo "" >> "$OUT"
if [ "$leak" = "1" ]; then
  echo "# RESULT: FILE_LEAK_CONFIRMED (scorer -> INSECURE/HIGH; SEVERE — disclosure)" >> "$OUT"
elif [ "$reached" = "1" ]; then
  echo "# RESULT: TRAVERSAL_ATTEMPTED_NO_LEAK (scorer -> SECURE: rejected/sanitized)" >> "$OUT"
else
  echo "# RESULT: ENDPOINT_UNREACHABLE (scorer -> UNK)" >> "$OUT"
fi
