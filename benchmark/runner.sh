#!/usr/bin/env bash

echo "Using SHELL=$SHELL"

set -euo pipefail

source test/fixture.sh

: "${RUNS:=3}"
: "${N:=1000}"

for bm_file in "$@"; do
    for ((r=1; r <= RUNS; r+=1)); do
        echo
        env -i \
            HOME="$HOME" \
            CHNODE_NODES_DIR="$CHNODE_NODES_DIR" \
            r="$r" \
            RUNS="$RUNS" \
            N="$N" \
            "$SHELL" "$bm_file"
    done
done
