#!/usr/bin/env bash

LOGPFX=$(basename "$0"):
cd "$(dirname "$(realpath "$0")")/.."

set -e

source utils/_common.sh

$GOAL_CMD account dump -a "$1" | jq -r '.algo // 0'
