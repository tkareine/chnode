#!/usr/bin/env bash

ROOT=${0%/*}/..
RUNS=3
N=1000

echo "Run \`chnode\` $N times sequentally in subshell, with $RUNS separate runs…"

for ((r=0; r < RUNS; r+=1)); do
    env -i r="$r" N="$N" ROOT="$ROOT" HOME="$HOME" bash <<END
echo "Run #$r"

source "$ROOT/chnode.sh"

time (
    for ((i=0; i<N; i+=1)); do
        chnode >/dev/null
    done
)
END
done
