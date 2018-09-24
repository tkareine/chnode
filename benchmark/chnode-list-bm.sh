#!/usr/bin/env bash

set -euo pipefail

cd "${0%/*}" || exit 1

source ./bm-fixture.sh

RUNS=${RUNS:-3}
N=${N:-1000}

echo "Run \`chnode\` $N times sequentally in subshell, with $RUNS separate runs…"

for ((r=0; r < RUNS; r+=1)); do
    env -i \
        HOME="$HOME" \
        CHNODE_NODES_DIR="$CHNODE_NODES_DIR" \
        r="$r" \
        N="$N" \
        bash <<END
echo "Run #$r"

source "../chnode.sh"

time (
    for ((i=0; i < N; i+=1)); do
        chnode >/dev/null
    done
)
END
done
