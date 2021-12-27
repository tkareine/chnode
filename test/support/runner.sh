# -*- sh-shell: bash; -*-

set -euo pipefail

source support/shell-info.sh

__run_tests() {
    local test_file
    local exit_status=0

    for test_file in "$@"; do
        printf '\n# %s\n' "$test_file"
        env -i \
            TERM="$TERM" \
            HOME="$HOME" \
            SHELL="$SHELL" \
            "$SHELL" "$test_file" \
            || ((exit_status += 1))
    done

    return "$exit_status"
}

echo "Using $(shell_info)"

__run_tests "$@"
