#!/usr/bin/env bash
# D3.1 - unauthenticated list-models endpoint
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D3.1"
need_var "$PID" EP_LIST_MODELS || exit 0
need_var "$PID" EP_PORT || exit 0
URL="$(local_url "$EP_LIST_MODELS")"
run_curl "$PID" "$URL" "GET" "" "unauth list-models"
