#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")/.."

LOGPFX=$(basename "$0"):

source utils/_common.sh

# ensure have sudo access
sudo echo "" > /dev/null

mkdir -p tmp

SHASUMS_URL="https://fnet.algorand.green/static/SHA256SUMS"
DOWNLOAD_URL_PREFIX="https://fnet.algorand.green/static"

TMPDIR=$(realpath $(mktemp -p tmp -d -t update_binary-XXXXXX))
trap 'rm -rf "$TMPDIR"' EXIT

echo "$LOGPFX downloading SHA256SUMS"

UPDATED=0
UPDATED_NAMES=()

TMPFILE_SHA="$TMPDIR/SHA256SUMS"
curl -sf "$SHASUMS_URL" -o "$TMPFILE_SHA"

for file in algod goal; do
    LATEST_SHA=$(grep $file "$TMPFILE_SHA" | cut -d\  -f1)
    echo "$LOGPFX Latest $file: $LATEST_SHA"

    BINARY_PATH=$(sudo which "$file")

    CURRENT_SHA=$(sha256 "$BINARY_PATH")
    echo "$LOGPFX Installed $file: $CURRENT_SHA"

    if [[ "$CURRENT_SHA" = "$LATEST_SHA" ]]; then
        echo "$LOGPFX $file: no update"
    else
        TMPFILE_BINARY="$TMPDIR/$file"
        echo "$LOGPFX $file: update available"

        echo "$LOGPFX Downloading $file"
        curl -sf "$DOWNLOAD_URL_PREFIX/$file" -o "$TMPFILE_BINARY"

        DOWNLOADED_SHA=$(sha256 "$TMPFILE_BINARY")
        if [[ "$DOWNLOADED_SHA" = "$LATEST_SHA" ]]; then
            echo "$LOGPFX SHA256 hash verified."
            UPDATED_NAMES+=("$file")
            UPDATED=$(( UPDATED + 1 ))
        else
            echo -e "$LOGPFX ERROR: Incorrect $file hash.\nExpected: $LATEST_SHA\nFound: $DOWNLOADED_SHA"
            echo "$LOGPFX Files left in $TMPDIR"
            trap - EXIT
            echo "$LOGPFX ERROR"
            exit 1
        fi
    fi
done

if [ $UPDATED -gt 0 ]; then
    echo "$LOGPFX Updates available, stopping node"
    sudo ./stop.sh
    for file in "${UPDATED_NAMES[@]}"; do
        TMPFILE_BINARY="$TMPDIR/$file"
        BINARY_PATH=$(sudo which "$file")
        echo "$LOGPFX Installing $file to $BINARY_PATH"
        sudo cp "$TMPFILE_BINARY" "$BINARY_PATH"
        sudo chown "$USER:$USERGRP" "$BINARY_PATH"
        sudo chmod 755 "$BINARY_PATH"
    done
    echo "$LOGPFX Updated OK"
    exit 0
fi

echo "$LOGPFX OK, No updates"
exit 2
