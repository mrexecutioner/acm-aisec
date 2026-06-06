#!/usr/bin/env bash
# load_endpoints.sh - parse frameworks/<fw>/endpoints.yml into shell vars.
#
# Flat YAML only: "key: value" per line. Comments (#...) and blanks ignored.
# Quotes are stripped.
#
# Usage:  source load_endpoints.sh path/to/endpoints.yml
# Exports each top-level key as an env var (uppercased, dots->underscores).
#
# Example file:
#   port: 11434
#   bind_default: 0.0.0.0
#   inference: /api/generate
#   list_models: /api/tags
#   pull: /api/pull
set -eu -o pipefail

_endpoints_file="${1:?endpoints.yml path required}"
if [ ! -f "$_endpoints_file" ]; then
  echo "load_endpoints: missing $_endpoints_file" >&2
  return 1 2>/dev/null || exit 1
fi

while IFS= read -r _line || [ -n "$_line" ]; do
  # strip CR
  _line="${_line%$'\r'}"
  # skip comments / blanks
  case "$_line" in
    \#*|"") continue;;
  esac
  # split on first ":"
  _key="${_line%%:*}"
  _val="${_line#*:}"
  # trim
  _key="$(echo "$_key" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
  _val="$(echo "$_val" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
  # strip surrounding quotes
  _val="${_val%\"}"; _val="${_val#\"}"
  _val="${_val%\'}"; _val="${_val#\'}"
  # uppercase + dots->underscores for env var name
  _var="$(echo "$_key" | tr '[:lower:].' '[:upper:]_' )"
  if [ -n "$_key" ]; then
    export "EP_${_var}"="$_val"
  fi
done < "$_endpoints_file"
