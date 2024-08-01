#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")/.."

LOGPFX=$(basename "$0"):

source utils/_common.sh

# ensure have sudo access
sudo echo "" > /dev/null

mkdir -p tmp

SHASUMS_URL="https://fnet.algorand.green/static/SHA256SUMS"
ALGOD_URL="https://fnet.algorand.green/static/algod"

TMPFILE_SHA=$(realpath $(mktemp -p tmp -t SHA256SUMS-XXXXX))
TMPFILE_ALGOD=$(realpath $(mktemp -p tmp -t algod-XXXXX))
trap 'rm "$TMPFILE_SHA" "$TMPFILE_ALGOD"' EXIT

echo "$LOGPFX downloading SHA256SUMS"

curl -sf "$SHASUMS_URL" -o "$TMPFILE_SHA"

LATEST_ALGOD_SHA=$(grep algod "$TMPFILE_SHA" | cut -d\  -f1)

echo "$LOGPFX Latest algod $LATEST_ALGOD_SHA"

ALGOD_PATH="$(which algod)"

CURRENT_ALGOD_SHA=$(sha256sum "$ALGOD_PATH" | cut -d\  -f1)

echo "$LOGPFX Installed algod $CURRENT_ALGOD_SHA"

if [[ "$CURRENT_ALGOD_SHA" = "$LATEST_ALGOD_SHA" ]]; then
    echo "$LOGPFX No update"
else
    echo "$LOGPFX algod has changed, updating"
    echo "$LOGPFX Downloading algod"
    curl -sf "$ALGOD_URL" -o "$TMPFILE_ALGOD"
    DOWNLOADED_ALGOD_SHA=$(sha256sum "$TMPFILE_ALGOD" | cut -d\  -f1)
    if [[ "$DOWNLOADED_ALGOD_SHA" = "$LATEST_ALGOD_SHA" ]]; then
        echo "SHA256 hash matches. Installing"
        sudo cp "$TMPFILE_ALGOD" "$ALGOD_PATH"
        sudo chown "$USER:$USERGRP" "$ALGOD_PATH"
        sudo chmod 755 "$ALGOD_PATH"
    else
        echo -e "$LOGPFX FATAL ERROR: Incorrect algod hash.\nExpected: $LATEST_ALGOD_SHA\nFound: $DOWNLOADED_ALGOD_SHA"
        echo "Files left in tmp"
        trap - EXIT
        echo "$LOGPFX ERROR"
        exit 1
    fi
fi

echo "$LOGPFX OK"
