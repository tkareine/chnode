#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}" || exit 1

source ./bm-fixture.sh

NODE_VERSION=node-8
RUNS=${RUNS:-3}
N=${N:-1000}

echo "Run \`chnode $NODE_VERSION\` $N times sequentally in subshell, with $RUNS separate runs…"

for ((r=0; r < RUNS; r+=1)); do
    env -i \
        HOME="$HOME" \
        CHNODE_NODES_DIR="$CHNODE_NODES_DIR" \
        NODE_VERSION="$NODE_VERSION" \
        r="$r" \
        N="$N" \
        bash <<END
echo "Run #$r"

source "../chnode.sh"

time (
    for ((i=0; i < N; i+=1)); do
        chnode "$NODE_VERSION"
    done
)
END
done
