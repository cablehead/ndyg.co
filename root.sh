#!/usr/bin/env bash

set -eu

# you can export a ROUTE_PATH to place this service under a url prefix
ROUTE_PATH=${1:-"/"}
export ROUTE_PATH=${ROUTE_PATH%/}

BASE="$(dirname "$0")"
cd "$BASE"

meta_out() {
    jo "$@" >&4
    exec 4>&-
}

META="$(cat <&3)"

METHOD="$(jq -r .method <<<"$META")"

P="$(jq -r .path <<<"$META")"
P=${P%/}

if [[ "$METHOD" == "GET" && "$P" == "${ROUTE_PATH}" ]]; then
    meta_out headers="$(jo "content-type"="text/html")"
    exec ./render.nu
fi

meta_out status=404 headers="$(jo "content-type"="text/html")"
echo "Not Found:" $METHOD $P
