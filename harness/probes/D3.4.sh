#!/usr/bin/env bash
# D3.4 - unauthenticated delete/mutate endpoint
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D3.4"
if [ -z "${EP_DELETE:-}" ]; then
  write_stub "$PID" "no delete endpoint documented for this framework"
  exit 0
fi
need_var "$PID" EP_PORT || exit 0
URL="$(local_url "$EP_DELETE")"
BODY="${EP_DELETE_TARGET:-{}}"
run_curl "$PID" "$URL" "DELETE" "$BODY" "unauth delete"
