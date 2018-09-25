#!/usr/bin/env bash

set -euo pipefail

echo "Using SHELL=$SHELL"

for test_file in "$@"; do
    env -i TERM="$TERM" HOME="$HOME" "$SHELL" "$test_file"
done
