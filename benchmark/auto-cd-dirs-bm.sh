# -*- sh-shell: bash; -*-

echo "(${r:-1}/$RUNS) chnode_auto selecting and deselecting node version by cd dirs"

source chnode.sh
source auto.sh

mkdir -p "$__FIXTURE_AUTO_DIR"/node-10
echo node-10.11.0 >"$__FIXTURE_AUTO_DIR"/node-10/.node-version

time (
    for (( i=0; i < N; i+=1 )); do
        # shellcheck disable=SC2164
        cd "$__FIXTURE_AUTO_DIR"/node-10
        chnode_auto
        # shellcheck disable=SC2103
        cd ..
        chnode_auto
    done
)
