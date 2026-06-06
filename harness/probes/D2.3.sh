#!/usr/bin/env bash
# D2.3 - is admin (mgmt) gated differently from inference?
# Derived post-hoc from D2.1 vs D3.x. This probe writes a marker referencing them.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D2.3"
OUT="$FW_RUN/probes/${PID}.txt"
{
  echo "# $PID - admin vs inference gated differently? (derived)"
  echo "# Compare D2.1.txt (inference) with D3.1-D3.4 (mgmt). Same posture across both => WARNS/INSECURE."
  echo "# UNK by harness contract; the matrix step is the right place to compute this."
} > "$OUT"
