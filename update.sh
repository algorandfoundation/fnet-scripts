#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")"

LOGPFX=$(basename "$0"):

source utils/_common.sh

# ensure have sudo access
sudo echo "" > /dev/null

genesis_tmp=$(mktemp -p tmp -t genesis-XXXXX.json)
get_genesis > "$genesis_tmp"

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

    # IF NOT USING SYSTEMD: change this to your "stop node" command
    sudo ./stop.sh

    echo "$LOGPFX Reconfiguring"
    ./configure.sh

    echo "$LOGPFX Checking for updated binary"
    ./utils/update-binary.sh

    echo "$LOGPFX Starting algod"

    # IF NOT USING SYSTEMD: change this to your "start node" command
    sudo ./start.sh

    echo "$LOGPFX Restarted"

    sleep 2
fi
