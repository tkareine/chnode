# -*- sh-shell: bash; -*-

set -euo pipefail

source support/shell-info.sh

echo "Using $(print_shell_info)"

source support/fixture.sh

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
