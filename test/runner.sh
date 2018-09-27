#!/usr/bin/env bash

set -euo pipefail

source support/shell-info.sh

echo "Using $(print_shell_info)"

error=0

for test_file in "$@"; do
    env -i \
        TERM="$TERM" \
        HOME="$HOME" \
        SHELL="$SHELL" \
        "$SHELL" "$test_file" \
        || (( error += 1 ))
done

exit "$error"
