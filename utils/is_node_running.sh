#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

PID="$DATA_DIR/algod.pid"
IS_RUNNING=$([ -f "$PID" ])
exit $IS_RUNNING
