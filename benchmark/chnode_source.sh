#!/usr/bin/env bash

ROOT=${0%/*}/..
RUNS=3
N=1000

echo "Source chnode $N times sequentally in subshell, with $RUNS separate runs…"

for ((r=0; r < RUNS; r+=1)); do
    env -i r="$r" N="$N" ROOT="$ROOT" HOME="$HOME" bash <<END
echo "Run #$r"

time (
    for ((i=0; i<N; i+=1)); do
        source "$ROOT/chnode.sh"
    done
)
END
done
