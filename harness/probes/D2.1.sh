#!/usr/bin/env bash
# D2.1 - is auth required by default for inference?
# Send the inference call with no auth header; transcript will show 2xx (INSECURE)
# or 401/403 (SECURE).
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D2.1"
need_var "$PID" EP_INFERENCE || exit 0
need_var "$PID" EP_PORT || exit 0

METHOD="${EP_INFERENCE_METHOD:-POST}"
# NOTE: do NOT use ${VAR:-{...}}, the '}' inside the default closes the ${...}
# expansion early and appends a stray '}' to the body (62 vs 61 bytes), which
# strict servers (vllm/sglang pydantic) reject as JSON "Extra data". Assign safely.
BODY="${EP_INFERENCE_PAYLOAD:-}"
[ -n "$BODY" ] || BODY='{"prompt":"hello"}'
URL="$(local_url "$EP_INFERENCE")"

run_curl "$PID" "$URL" "$METHOD" "$BODY" "unauth inference"
