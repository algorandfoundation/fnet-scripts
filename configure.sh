#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")"

LOGPFX=$(basename "$0"):

source utils/_common.sh

if ./utils/is_node_running.sh; then
    echo "$LOGPFX Looks like algod is running. Stop it first"
    exit 1
fi

if ./utils/update_binary.sh; then
    echo "$LOGPFX Updated binary"
fi

sudo algocfg -d "$DATA_DIR" set -p "DNSBootstrapID" -v "<network>.algorand.green"

sudo rm -rf $DB_DIR
echo "$LOGPFX Deleted $DB_DIR"

genesis_tmp=$(mktemp) # TODO
if ./utils/get_genesis.sh > "$genesis_tmp"; then
    DEST="$DATA_DIR/genesis.json"
    sudo mv "$genesis_tmp" "$DEST"
    sudo chown $USER:$USERGRP $DEST
    sudo chmod 644 $DEST
    echo "$LOGPFX Wrote $DEST"
else
    echo "$LOGPFX Failed to get genesis file. Exiting"
    rm "$genesis_tmp"
    exit 1
fi

echo "$LOGPFX OK"
