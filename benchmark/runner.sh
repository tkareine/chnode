# -*- sh-shell: bash; -*-

set -euo pipefail

source support/shell-info.sh

echo "Using $(shell_info)"

source support/fixture.sh

fixture_make_default_dir
CHNODE_NODES_DIR=$__FIXTURE_DEFAULT_DIR
fixture_make_default_nodes "$CHNODE_NODES_DIR"

: "${RUNS:=3}"
: "${N:=1000}"

for bm_file in "$@"; do
    for (( r=1; r <= RUNS; r+=1 )); do
        echo
        env -i \
            HOME="$HOME" \
            CHNODE_NODES_DIR="$CHNODE_NODES_DIR" \
            r="$r" \
            RUNS="$RUNS" \
            N="$N" \
            "$SHELL" "$bm_file"
    done
done
