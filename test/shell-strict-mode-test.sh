# -*- sh-shell: bash; -*-

source test/support/setup-shunit2.sh
source test/support/setup-default-chnode.sh

setUp() {
    fixture_make_auto_dir
}

tearDown() {
    fixture_delete_auto_dir
}

test_list_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode
END
    assertEquals 0 $?
}

test_use_in_shell_strict_mode() {
    # First use node-8, followed by using node-10; this checks
    # first-time use and then changing selected node
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode node-8
chnode node-10
chnode
END
    assertEquals 0 $?
}

test_reset_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode --reset
END
    assertEquals 0 $?
}

test_reload_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode node-8
chnode --reload
END
    assertEquals 0 $?
}

test_version_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode --version
END
    assertEquals 0 $?
}

test_help_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
chnode --help
END
    assertEquals 0 $?
}

test_auto_in_shell_strict_mode() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
source auto.sh
chnode_auto
END
    assertEquals 0 $?
}

test_auto_in_shell_strict_mode_when_missing_newline_in_version_file() {
    __with_shell >/dev/null <<END
set -euo pipefail
source chnode.sh
source auto.sh
cd "$__FIXTURE_AUTO_DIR" || exit
printf 'node-8.1.0' >.node-version
chnode_auto
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
