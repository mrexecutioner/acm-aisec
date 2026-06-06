#!/usr/bin/env bash
# D3.3 - unauthenticated push/export endpoint
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D3.3"
if [ -z "${EP_PUSH:-}" ]; then
  write_stub "$PID" "no push/export endpoint documented for this framework (likely N/A)"
  exit 0
fi
need_var "$PID" EP_PORT || exit 0
URL="$(local_url "$EP_PUSH")"
BODY="${EP_PUSH_PAYLOAD:-{}}"
run_curl "$PID" "$URL" "POST" "$BODY" "unauth push/export"
