#!/usr/bin/env bash
# curl_local.sh - localhost-only curl wrapper for the security-defaults harness.
#
# Refuses to run against any host that is not 127.0.0.1, ::1, or localhost.
# Saves the full transcript (request line, headers, body, status, timing) to
# the path supplied by the caller via $TRANSCRIPT, otherwise to stdout.
#
# Usage:
#   TRANSCRIPT=/path/to/file.txt bash curl_local.sh \
#       --method POST --url http://127.0.0.1:11434/api/generate \
#       --header 'Content-Type: application/json' \
#       --data '{"model":"x","prompt":"y"}'
#
# Self-test: bash curl_local.sh --selftest
set -eu -o pipefail

usage() {
  cat <<'EOF'
Usage: TRANSCRIPT=<file> curl_local.sh [opts]
  --method M         HTTP method (default GET)
  --url URL          full URL (host MUST be 127.0.0.1, ::1, or localhost)
  --header H         repeatable; "Name: value"
  --data D           request body
  --timeout N        seconds (default 8)
  --note "..."       free-text note recorded at top of transcript
  --selftest         run built-in checks and exit
EOF
}

METHOD=GET
URL=""
HEADERS=()
DATA=""
TIMEOUT=8
NOTE=""

if [ $# -eq 0 ]; then usage; exit 2; fi

while [ $# -gt 0 ]; do
  case "$1" in
    --method)   METHOD="$2"; shift 2;;
    --url)      URL="$2"; shift 2;;
    --header)   HEADERS+=("$2"); shift 2;;
    --data)     DATA="$2"; shift 2;;
    --timeout)  TIMEOUT="$2"; shift 2;;
    --note)     NOTE="$2"; shift 2;;
    --selftest) SELFTEST=1; shift;;
    -h|--help)  usage; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

is_local_url() {
  # Accept http(s)://(127.0.0.1|::1|localhost)(:port)?(/path)?
  local u="$1"
  [[ "$u" =~ ^https?://(127\.0\.0\.1|\[::1\]|localhost)(:[0-9]+)?(/.*)?$ ]]
}

if [ "${SELFTEST:-0}" = "1" ]; then
  fail=0
  for u in "http://127.0.0.1:8080/foo" "https://localhost/bar" "http://[::1]:1234/"; do
    is_local_url "$u" || { echo "selftest: FALSE NEG on $u"; fail=1; }
  done
  for u in "http://example.com/" "https://8.8.8.8/" "http://127.0.0.1.evil.com/" "http://192.168.1.1/"; do
    if is_local_url "$u"; then echo "selftest: FALSE POS on $u"; fail=1; fi
  done
  if [ $fail -eq 0 ]; then echo "curl_local.sh selftest OK"; exit 0; else exit 1; fi
fi

if [ -z "$URL" ]; then echo "ERROR: --url required" >&2; exit 2; fi
if ! is_local_url "$URL"; then
  echo "REFUSED: non-local URL: $URL" >&2
  echo "Per PROTOCOL.md hard constraint 1 (LOCAL ONLY), this wrapper only contacts 127.0.0.1/::1/localhost." >&2
  exit 3
fi

# Build curl invocation
CURL_OPTS=(-sS -i -L --max-time "$TIMEOUT" -X "$METHOD")
for h in "${HEADERS[@]:-}"; do
  [ -n "$h" ] && CURL_OPTS+=(-H "$h")
done
if [ -n "$DATA" ]; then
  CURL_OPTS+=(--data-binary "$DATA")
fi

TS=$(date -u +%FT%TZ)
TRANSCRIPT="${TRANSCRIPT:-/dev/stdout}"

write_transcript() {
  cat <<EOF
# curl_local transcript
# timestamp_utc: $TS
# method: $METHOD
# url: $URL
# headers: ${HEADERS[*]:-}
# data_len: ${#DATA}
# timeout_s: $TIMEOUT
# note: $NOTE
# --- raw response (headers + body) ---
$RAW
# --- meta ---
# curl_exit: $RC
EOF
}

set +e
RAW=$(curl "${CURL_OPTS[@]}" "$URL" 2>&1)
RC=$?
set -e

if [ "$TRANSCRIPT" = "/dev/stdout" ]; then
  write_transcript
else
  mkdir -p "$(dirname "$TRANSCRIPT")"
  write_transcript > "$TRANSCRIPT"
fi

exit $RC
