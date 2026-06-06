#!/usr/bin/env bash
# D7.2 - gap score: # of D1-D6 INSECURE-by-default *despite* a secure option in docs.
# Computed after matrix is built. The probe writes a placeholder transcript.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D7.2"
{
  echo "# $PID - gap score (derived from D1-D6 + docs)"
  echo "# Counted at analysis/matrix.csv build time."
  echo "# UNK by harness contract."
} > "$FW_RUN/probes/${PID}.txt"
