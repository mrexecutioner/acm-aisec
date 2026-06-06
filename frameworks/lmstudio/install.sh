#!/usr/bin/env bash
# LM Studio - GUI desktop application; no headless install path.
# Source (cite): https://lmstudio.ai/docs   (checked: 2026-05-30; verify at pre-batch gate)
#
# This script does NOT install LM Studio. Per PROTOCOL.md hard constraint #4,
# we record the install failure honestly and the scorer emits UNK rows.
# A human-driven VM snapshot pass is required to score LM Studio.
set -eu -o pipefail
cd "$(dirname "$0")"
echo "=== lmstudio install $(date -u +%FT%TZ) ==="
echo "[install] FAILED: LM Studio is a GUI desktop application."
echo "[install] No headless container quickstart exists in the official docs."
echo "[install] Per PROTOCOL.md, this framework requires a VM snapshot run by the human."
echo "[install] All D1-D7 items will be scored UNK in this batch."

mkdir -p ../../runs/lmstudio/config_snapshot
{
  echo "framework: lmstudio"
  echo "install_status: FAILED-BY-DESIGN (desktop app)"
  echo "documented_install: GUI installer from https://lmstudio.ai"
  echo "documented_server_port: 1234"
  echo "documented_default_bind: 127.0.0.1 (per LM Studio defaults to localhost; opt-in to LAN serve)"
  echo "note: server mode is started from the GUI (Developer tab) or via CLI 'lms server start'"
} > ../../runs/lmstudio/config_snapshot/manual_only.txt

exit 0
