#!/usr/bin/env bash
# D1.2 - default port + docs "expose" guidance
# Doc-based item; this probe records the documented port and a pointer to notes.md.
set -eu -o pipefail
source "$ROOT/harness/lib/probe_common.sh"

PID="D1.2"
OUT="$FW_RUN/probes/${PID}.txt"
{
  echo "# $PID - default port + expose-guidance (doc-derived)"
  echo "# documented port: ${EP_PORT:-<unset>}"
  echo "# documented default bind: ${EP_BIND_DEFAULT:-<unset>}"
  echo "# docs reference: see frameworks/${FRAMEWORK}/notes.md"
  echo "# UNK by harness contract - human reads the docs section linked in notes.md"
} > "$OUT"
