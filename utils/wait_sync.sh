#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

source utils/_common.sh

if ! ./utils/is_node_running.sh; then
    echo "$LOGPFX Node is not running"
    exit 1
fi

echo -n "$LOGPFX Waiting"

while ./utils/is_node_syncing.sh; do
    echo -n "."
    sleep 3
done

echo ""
echo "$LOGPFX Synced"
