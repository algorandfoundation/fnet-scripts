#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")"

source common.sh

# ensure have sudo access
sudo echo "" > /dev/null

genesis_tmp=$(mktemp)
get_genesis > "$genesis_tmp"

remote_md5=$(md5 "$genesis_tmp")
local_md5=$(md5 "$DATA_DIR/genesis.json")

trap "rm \"$genesis_tmp\"" EXIT

if [ "$remote_md5" = "$local_md5" ]; then
    echo "Local genesis is up to date $local_md5 = $remote_md5"
    echo "Nothing to do"
else
    echo "Local genesis was $local_md5, remote was $remote_md5"
    echo "New genesis, nuke + restart"

    echo "Stopping algod"

    # IF NOT USING SYSTEMD: change this to your "stop node" command
    sudo systemctl stop algorand

    echo "Reconfiguring"
    ./configure.sh

    echo "Starting algod"

    # IF NOT USING SYSTEMD: change this to your "start node" command
    sudo systemctl start algorand

    echo "Restarted"

    sleep 2
fi
