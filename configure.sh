#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")"

LOGPFX=$(basename "$0"):

source utils/_common.sh

PID="$DATA_DIR/algod.pid"
if [ -f "$PID" ]; then
    echo "$LOGPFX Looks like algod is running. Stop it first"
    exit 1
fi

sudo algocfg -d "$DATA_DIR" set -p "DNSBootstrapID" -v "<network>.algorand.green"

sudo rm -rf $DB_DIR
echo "$LOGPFX Deleted $DB_DIR"

genesis_tmp=$(mktemp)
if get_genesis > "$genesis_tmp"; then
    DEST="$DATA_DIR/genesis.json"
    sudo mv "$genesis_tmp" "$DEST"
    sudo chown $USER:$USERGRP $DEST
    sudo chmod 644 $DEST
    echo Wrote $DEST
else
    echo Failed to get genesis file. Exiting
    rm $genesis_tmp
    exit 1
fi

echo "$LOGPFX OK"
