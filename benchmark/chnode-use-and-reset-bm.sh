# -*- sh-shell: bash; -*-

NODE_8_VERSION='node-8'
NODE_10_VERSION='node-10'

echo "(${r:-1}/$RUNS) chnode $NODE_8_VERSION; chnode $NODE_10_VERSION; chnode --reset"

source chnode.sh

time (
    for ((i = 0; i < N; i += 1)); do
        chnode "$NODE_8_VERSION"
        chnode "$NODE_10_VERSION"
        chnode --reset
    done
)
