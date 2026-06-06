#!/usr/bin/env bash
# Jan - GUI desktop application; no headless install path.
# Source (cite): https://jan.ai/docs   (checked: 2026-05-30; verify at pre-batch gate)
#
# Per PROTOCOL.md hard constraint #4: failed install -> UNK rows. Human runs a VM
# snapshot to score Jan.
set -eu -o pipefail
cd "$(dirname "$0")"
echo "=== jan install $(date -u +%FT%TZ) ==="
echo "[install] FAILED: Jan is a GUI desktop application (Electron-based)."
echo "[install] No headless container quickstart exists in the official docs."
echo "[install] Per PROTOCOL.md, requires a VM snapshot pass by the human."
echo "[install] All D1-D7 items will be UNK in this batch."

mkdir -p ../../runs/jan/config_snapshot
{
  echo "framework: jan"
  echo "install_status: FAILED-BY-DESIGN (desktop app)"
  echo "documented_install: GUI installer from https://jan.ai"
  echo "documented_server_port: 1337"
  echo "documented_default_bind: 127.0.0.1"
  echo "note: API server is started from Jan's local API server panel"
} > ../../runs/jan/config_snapshot/manual_only.txt

exit 0
