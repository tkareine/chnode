#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}" || exit 1

source ./bm-fixture.sh

RUNS=${RUNS:-3}
N=${N:-1000}

echo "Source chnode.sh $N times sequentally in subshell, with $RUNS separate runs…"

for ((r=0; r < RUNS; r+=1)); do
    env -i \
        HOME="$HOME" \
        CHNODE_NODES_DIR="$CHNODE_NODES_DIR" \
        r="$r" \
        N="$N" \
        bash <<END
echo "Run #$r"

time (
    for ((i=0; i < N; i+=1)); do
        source "../chnode.sh"
    done
)
END
done
