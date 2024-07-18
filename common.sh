#!/usr/bin/env bash

# Base data directory, uses ALGORAND_DATA if set, otherwise default to /var/lib/..
export DATA_DIR=${ALGORAND_DATA:-/var/lib/algorand}

# network data dir under $DATA_DIR
export NETWORK=fnet-v1

# DB dir to nuke when reseting
export DB_DIR="$DATA_DIR/$NETWORK"

# User owner of files. Should resolve automatically
export USER=$(stat -c '%U' "$DATA_DIR/genesis.json")

# Group owner of files. Should resolve automatically
export USERGRP=$(stat -c '%G' "$DATA_DIR/genesis.json")

echo Using data dir: "$DATA_DIR" >&2

function get_genesis() {
    bootstrap=_algobootstrap._tcp.fnet.algorand.green
    port=8184

    resps=$(dig +short srv $bootstrap | cut -d\  -f4 | sed 's/\.$//' | shuf)

    echo "Resolved $(echo -e "$resps" | wc -l) relays" >&2

    for relayHostname in $resps; do
        if genesis=$(curl -s "http://$relayHostname:$port/genesis"); then
            echo "Got genesis, $(echo -e "$genesis" | wc -l) lines" >&2
            echo -e "$genesis"
            return 0
        fi
    done

    echo Failed to get genesis

    return 1
}

function md5 {
    md5sum "$1" | cut -d\  -f1
}

export -f get_genesis
export -f md5

get_genesis
