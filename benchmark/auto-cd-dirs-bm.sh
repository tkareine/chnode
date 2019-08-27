# -*- sh-shell: bash; -*-

NODE_VERSION='node-8.1.0'

echo "(${r:-1}/$RUNS) chnode_auto selecting and deselecting $NODE_VERSION by cd dirs"

source chnode.sh
source auto.sh

mkdir -p "$__FIXTURE_AUTO_DIR"/project
echo "$NODE_VERSION" >"$__FIXTURE_AUTO_DIR"/project/.node-version

time (
    for (( i=0; i < N; i+=1 )); do
        # shellcheck disable=SC2164
        cd "$__FIXTURE_AUTO_DIR"/project
        chnode_auto
        # shellcheck disable=SC2103
        cd ..
        chnode_auto
    done
)
