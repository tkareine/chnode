# -*- sh-shell: bash; -*-

NODE_VERSION='node-8'

echo "(${r:-1}/$RUNS) chnode $NODE_VERSION"

source chnode.sh

time (
    for ((i = 0; i < N; i += 1)); do
        chnode "$NODE_VERSION"
    done
)
