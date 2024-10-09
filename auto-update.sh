#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")"

LOGPFX=$(basename "$0"):

source utils/_common.sh

# ensure have sudo access
sudo echo "" > /dev/null

genesis_tmp=$(mktemp -p tmp -t genesis-XXXXX.json)
./utils/get_genesis.sh > "$genesis_tmp"

remote_md5=$(md5 "$genesis_tmp")
local_md5=$(md5 "$DATA_DIR/genesis.json")

trap 'rm "$genesis_tmp"' EXIT

RESET=0

if [ "$remote_md5" = "$local_md5" ]; then
    echo "$LOGPFX Local genesis is up to date $local_md5 = $remote_md5"
    if ./utils/update_binary.sh; then
        echo "$LOGPFX Binary updated"
    else
        echo "$LOGPFX Nothing to do"
        exit 0
    fi
else
    RESET=1
    echo "$LOGPFX Local genesis was $local_md5, remote was $remote_md5"
    echo "$LOGPFX New genesis, nuke + restart"

    echo "$LOGPFX Stopping algod"

    # IF NOT USING SYSTEMD: edit stop.sh
    sudo ./stop.sh

    echo "$LOGPFX Reconfiguring"
    # Also updates binary if necessary
    ./configure.sh
fi

echo -n "$LOGPFX Starting algod."

echo "$LOGPFX Starting node in background"
# IF NOT USING SYSTEMD: edit start.sh
sudo ./start.sh

echo -n "$LOGPFX Waiting for node to start "
./utils/wait_node_start.sh

if ! ./utils/is_node_running.sh; then
    echo -e "\n$LOGPFX ERROR algod failed to start"
    exit 1
else
    echo "OK"
fi

# Wait to sync normally, then start fast catchup
echo "$LOGPFX Waiting 90 seconds for sync. Ctrl+C to skip"
if ! ./utils/wait_sync.sh 90; then
    echo "$LOGPFX Not synced after 90 seconds"
    ./utils/catchup.sh
fi

# if genesis was reset, run the user script
if [ $RESET -eq 1 ] && [ -e "on-network-reset.sh" ]; then
    echo "$LOGPFX Running user bootstrap script on-network-reset.sh"
    exec ./on-network-reset.sh
fi

echo "$LOGPFX OK"
