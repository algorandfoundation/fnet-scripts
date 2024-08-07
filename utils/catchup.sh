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

# Check genesis hash
LOCAL_GH=$($GOAL_CMD node status | grep "Genesis hash: " | cut -d\  -f3 | tr -d '\r')
REMOTE_GH=$(curl -s 'https://fnet-api.4160.nodely.io/v2/transactions/params' | jq -r '.["genesis-hash"]')

if [ "$LOCAL_GH" != "$REMOTE_GH" ]; then
    echo "$LOGPFX Genesis hashes do not match"
    echo "$LOGPFX Local $LOCAL_GH"
    echo "$LOGPFX Remote $REMOTE_GH"
    echo "$LOGPFX Aborting"
    exit 1
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
