# -*- sh-shell: bash; -*-

echo "(${r:-1}/$RUNS) source chnode.sh"

time (
    for ((i = 0; i < N; i += 1)); do
        source chnode.sh
    done
)
