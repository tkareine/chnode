# -*- sh-shell: bash; -*-

set -euo pipefail

source support/shell-info.sh

echo "Using $(shell_info)"

source support/fixture.sh

fixture_make_nodes_dir
fixture_make_auto_dir
trap '{ fixture_delete_nodes_dir; fixture_delete_auto_dir; } || true' EXIT
CHNODE_NODES_DIR=$__FIXTURE_NODES_DIR
fixture_make_default_nodes "$CHNODE_NODES_DIR"

: "${RUNS:=3}"
: "${N:=1000}"

for bm_file in "$@"; do
    for (( r=1; r <= RUNS; r+=1 )); do
        echo
        env -i \
            TIMEFORMAT=$'real: %3R sec(s)\nuser: %3U sec(s)\nsys:  %3S sec(s)' \
            HOME="$HOME" \
            CHNODE_NODES_DIR="$CHNODE_NODES_DIR" \
            __FIXTURE_AUTO_DIR="$__FIXTURE_AUTO_DIR" \
            r="$r" \
            RUNS="$RUNS" \
            N="$N" \
            "$SHELL" "$bm_file"
    done
done
