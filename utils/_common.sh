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

export GOAL_CMD="goal"

function md5 {
    md5sum "$1" | cut -d\  -f1
}
export -f md5

function sha256 {
    sha256sum "$1" | cut -d\  -f1
}
export -f sha256
