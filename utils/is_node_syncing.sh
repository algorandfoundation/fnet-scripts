#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

./utils/is_node_running.sh

! $GOAL_CMD node status | grep -q 'Sync Time: 0.0s'
