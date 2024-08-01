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

if [ "$remote_md5" = "$local_md5" ]; then
    echo "$LOGPFX Local genesis is up to date $local_md5 = $remote_md5"
    echo "$LOGPFX Nothing to do"
else
    echo "$LOGPFX Local genesis was $local_md5, remote was $remote_md5"
    echo "$LOGPFX New genesis, nuke + restart"

    echo "$LOGPFX Stopping algod"

    # IF NOT USING SYSTEMD: edit stop.sh
    sudo ./stop.sh

    echo "$LOGPFX Reconfiguring"
    ./configure.sh

    echo "$LOGPFX Checking for updated binary"
    ./utils/update_binary.sh

    echo -n "$LOGPFX Starting algod."

    # IF NOT USING SYSTEMD: edit start.sh
    sudo ./start.sh

    wait_node_start

    if ! ./utils/is_node_running.sh; then
        echo -e "\n$LOGPFX ERROR algod failed to start"
        exit 1
    else
        echo "OK"
    fi

    # Wait to sync normally, then start fast catchup
    echo "$LOGPFX Waiting 90 seconds for sync. Ctrl+C to skip"
    # jumping through hoops to make ctrl+c propagate to the timeout cmd
    trap 'kill -INT -$pid' INT
    set +e
    timeout 90 ./utils/wait_sync.sh &
    pid=$!
    wait $pid
    set -e
    # Undo ctrl+c trap
    trap - INT

    if ./utils/is_node_syncing.sh; then
        echo "$LOGPFX Not synced yet, starting fast catchup"
        ./utils/catchup.sh
    fi

    if [ -e "on-automatic-reset.sh" ]; then
        echo "$LOGPFX Running user bootstrap script on-automatic-reset.sh"
        exec on-automatic-reset.sh
    fi
fi
