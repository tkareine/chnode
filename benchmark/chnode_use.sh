#!/usr/bin/env bash

ROOT=${0%/*}/..
RUNS=3
N=1000
NODE_VERSION=node-8

source "$ROOT/chnode.sh"

echo "Run \`chnode $NODE_VERSION\` $N times sequentally in subshell, with $RUNS separate runs…"

for ((r=0; r < RUNS; r+=1)); do
    env -i r="$r" N="$N" ROOT="$ROOT" HOME="$HOME" NODE_VERSION="$NODE_VERSION" bash <<END
echo "Run #$r"

source "$ROOT/chnode.sh"

time (
    for ((i=0; i<N; i+=1)); do
        chnode "$NODE_VERSION"
    done
)
END
done
