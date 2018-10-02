# -*- sh-shell: bash; -*-

source test/setup-shunit2.sh
source test/setup-default-chnode.sh

test_list_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode
END
    assertEquals 0 $?
}

test_use_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode node-8
chnode
END
    assertEquals 0 $?
}

test_reset_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode reset
END
    assertEquals 0 $?
}

__with_shell() {
    env -i \
        TERM="$TERM" \
        HOME="$HOME" \
        CHNODE_NODES_DIR="$CHNODE_NODES_DIR" \
        SHELL="$SHELL" \
        "$SHELL"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"