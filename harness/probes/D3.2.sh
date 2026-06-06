#!/usr/bin/env bash
# D3.2 - unauthenticated pull/load endpoint
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D3.2"
need_var "$PID" EP_PULL || exit 0
need_var "$PID" EP_PORT || exit 0
URL="$(local_url "$EP_PULL")"
BODY="${EP_PULL_PAYLOAD:-{}}"
run_curl "$PID" "$URL" "POST" "$BODY" "unauth pull/load"
