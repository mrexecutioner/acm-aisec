#!/usr/bin/env bash
# D5.1 - template / tool-exec exposed by default?
# Sends an inference request whose body exercises a template/tool field.
# This is a per-framework concern - the transcript is for human reading.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D5.1"
if [ -z "${EP_TEMPLATE_PAYLOAD:-}" ] || [ -z "${EP_INFERENCE:-}" ]; then
  write_stub "$PID" "no EP_TEMPLATE_PAYLOAD configured (framework-specific)"; exit 0
fi
need_var "$PID" EP_PORT || exit 0
URL="$(local_url "$EP_INFERENCE")"
run_curl "$PID" "$URL" "POST" "$EP_TEMPLATE_PAYLOAD" \
  "template/tool exposure probe (human-judge response)"
