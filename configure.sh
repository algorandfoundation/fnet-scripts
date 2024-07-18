#!/usr/bin/env bash

set -e

REAL_LOCATION=$(realpath "$0")
cd $(dirname "$REAL_LOCATION")

source common.sh

PID="$DATA_DIR/algod.pid"
if [ -f "$PID" ]; then
    echo "Looks like algod is running. Stop it first"
    exit 1
fi

sudo algocfg -d "$DATA_DIR" set -p "DNSBootstrapID" -v "<network>.algorand.green"

sudo rm -rf $DB_DIR
echo "Deleted $DB_DIR"

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

echo "Success. Start algod with"
echo "sudo systemctl start algorand"
