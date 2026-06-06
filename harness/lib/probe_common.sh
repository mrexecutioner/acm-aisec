#!/usr/bin/env bash
# probe_common.sh - source from each probe to set up env + helpers.
#
# Required env (set by the Makefile when invoking probes):
#   FRAMEWORK, FW_DIR, FW_RUN, ROOT
#
# Fields loaded from frameworks/<fw>/endpoints.yml (uppercased, prefixed EP_):
#   EP_PORT                 - host port the service is published on
#   EP_BIND_DEFAULT         - documented default bind addr
#   EP_INFERENCE            - inference endpoint path (e.g. /api/generate)
#   EP_INFERENCE_PAYLOAD    - JSON body for a minimal inference request
#   EP_INFERENCE_METHOD     - default POST
#   EP_LIST_MODELS          - management: list models
#   EP_PULL                 - management: pull/load a model
#   EP_PULL_PAYLOAD
#   EP_PUSH                 - management: push/export
#   EP_PUSH_PAYLOAD
#   EP_DELETE               - management: delete/mutate
#   EP_DELETE_TARGET
#   EP_CONTAINER_NAME       - docker container name (for inspect-based probes)
#   EP_DATA_DIR_IN_CONTAINER- where the framework writes logs / data
#   EP_TEMPLATE_PAYLOAD     - body that tries to exercise a template/tool surface
#   EP_TRAVERSAL_PATH       - URL fragment for the D5.2 traversal probe
set -eu -o pipefail

: "${FRAMEWORK:?need FRAMEWORK}"
: "${FW_DIR:?need FW_DIR}"
: "${FW_RUN:?need FW_RUN}"
: "${ROOT:?need ROOT}"

mkdir -p "$FW_RUN/probes"

# shellcheck disable=SC1091
source "$ROOT/harness/lib/load_endpoints.sh" "$FW_DIR/endpoints.yml"

# ---- helpers --------------------------------------------------------------

write_stub() {
  local pid="$1" reason="$2"
  printf '# stub transcript for %s\n# reason: %s\n# (no curl ran - harness contract scores UNK)\n' \
    "$pid" "$reason" > "$FW_RUN/probes/${pid}.txt"
}

run_curl() {
  # $1 probe_id, $2 url, $3 method (GET), $4 body (""), $5 note (""), $6 extra-header ("")
  local pid="$1" url="$2" method="${3:-GET}" body="${4:-}" note="${5:-}" extra_h="${6:-}"
  local out="$FW_RUN/probes/${pid}.txt"
  local args=(--method "$method" --url "$url" --note "$note"
              --header 'Content-Type: application/json')
  [ -n "$extra_h" ] && args+=(--header "$extra_h")
  [ -n "$body" ] && args+=(--data "$body")
  TRANSCRIPT="$out" bash "$ROOT/harness/lib/curl_local.sh" "${args[@]}" || true
}

need_var() {
  # need_var PID VARNAME -- returns 0 if var set, else writes stub and returns 1
  local pid="$1" var="$2"
  if [ -z "${!var:-}" ]; then
    write_stub "$pid" "endpoint var $var not set in endpoints.yml"
    return 1
  fi
  return 0
}

local_url() {
  # local_url <path>  ->  http://127.0.0.1:<port><path>
  local path="$1"
  echo "http://127.0.0.1:${EP_PORT}${path}"
}
