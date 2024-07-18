#!/usr/bin/env bash

set -e

REAL_LOCATION=$(realpath "$0")
cd $(dirname "$REAL_LOCATION")

source common.sh

# ensure have sudo access
sudo echo "" > /dev/null

genesis_tmp=$(mktemp)
get_genesis > "$genesis_tmp"

remote_md5=$(md5 "$genesis_tmp")
local_md5=$(md5 "$DATA_DIR/genesis.json")

if [ "$remote_md5" = "$local_md5" ]; then
    echo "Local genesis is up to date $local_md5 = $remote_md5"
else
    echo "Local genesis was $local_md5, remote was $remote_md5"
    echo "New genesis, nuke + restart"
    sudo systemctl stop algorand
    ./configure.sh
    sudo systemctl start algorand
    echo "Restarted"
fi
