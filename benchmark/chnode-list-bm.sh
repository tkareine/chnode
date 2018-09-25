# -*- sh-shell: bash; -*-

echo "(${r:-1}/$RUNS) chnode"

source chnode.sh

time (
    for ((i=0; i < N; i+=1)); do
        # shellcheck disable=SC2119
        chnode >/dev/null
    done
)
