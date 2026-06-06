#!/usr/bin/env bash
# D7.1 - quickstart shows secure or insecure setup?
# Doc-based - probe captures a pointer to notes.md.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D7.1"
{
  echo "# $PID - quickstart honesty (doc-derived)"
  echo "# Human reads frameworks/${FRAMEWORK}/notes.md + the cited quickstart URL."
  echo "# UNK by harness contract."
} > "$FW_RUN/probes/${PID}.txt"
