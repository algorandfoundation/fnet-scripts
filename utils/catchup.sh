#!/usr/bin/env bash

# Starts fast catchup
# Relies on nodely, trusting the catchpoint

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

if ! ./utils/is_node_syncing.sh; then
    echo "$LOGPFX Node seems in sync, aborting catchup"
    exit 0
fi

LAST_CP=$(curl -s https://fnet-api.4160.nodely.io/v2/status | jq -r '.["last-catchpoint"] // ""')

if [[ "$LAST_CP" != "" ]]; then
    echo "$LOGPFX Catching up using $LAST_CP"
    $GOAL_CMD node catchup "$LAST_CP"
    echo "$LOGPFX Waiting for sync"
    ./utils/wait_sync.sh
else
    echo "$LOGPFX Catchpoint not available. Syncing should be reasonably quick"
fi
