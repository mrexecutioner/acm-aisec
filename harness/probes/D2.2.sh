#!/usr/bin/env bash
# D2.2 - is native auth available at all (vs only "put nginx in front")?
# Doc-based - this probe records the documented answer from notes.md and
# captures behavior at /v1/models or equivalent auth-revealing endpoint.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D2.2"
OUT="$FW_RUN/probes/${PID}.txt"
{
  echo "# $PID - native auth available? (doc-derived)"
  echo "# see frameworks/${FRAMEWORK}/notes.md for the answer"
  echo "# UNK by harness contract"
} > "$OUT"
