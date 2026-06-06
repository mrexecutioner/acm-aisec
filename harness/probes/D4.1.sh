#!/usr/bin/env bash
# D4.1 - unauthenticated inference (overlap with D2.1; FRAMEWORK_PLAYBOOK says
# score both).
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D4.1"
need_var "$PID" EP_INFERENCE || exit 0
need_var "$PID" EP_PORT || exit 0
METHOD="${EP_INFERENCE_METHOD:-POST}"
# See D2.1.sh: avoid ${VAR:-{...}} (appends a stray '}' that breaks strict servers).
BODY="${EP_INFERENCE_PAYLOAD:-}"
[ -n "$BODY" ] || BODY='{"prompt":"hello"}'
URL="$(local_url "$EP_INFERENCE")"
run_curl "$PID" "$URL" "$METHOD" "$BODY" "unauth inference (D4.1 = D2.1 by design)"
