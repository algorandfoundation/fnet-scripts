#!/usr/bin/env bash

# LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

i=0
while ! ./utils/is_node_running.sh && [ "$i" -lt 10 ]; do
    echo -n "."
    sleep 1;
    i=$(( i + 1 ))
done
