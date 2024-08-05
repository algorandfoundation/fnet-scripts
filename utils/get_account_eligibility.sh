#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

if [[ "$($GOAL_CMD account dump -a "$1" | jq -r '.ie // 0')" == "true" ]]; then
    echo "$LOGPFX Account $1 is eligible"
    exit 0
else
    echo "$LOGPFX Account $1 is not eligible"
    exit 1
fi
