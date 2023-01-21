# -*- sh-shell: bash; -*-

source test/support/setup-shunit2.sh
source test/support/setup-default-chnode.sh

test_populate_nodes_var() {
    local expected_paths=(
        "$CHNODE_NODES_DIR/iojs-3.3.1" \
        "$CHNODE_NODES_DIR/node-10.11.0" \
        "$CHNODE_NODES_DIR/node-8.1.0" \
        "$CHNODE_NODES_DIR/node-9.11.2" \
        "$CHNODE_NODES_DIR/node-9.11.2-rc1"
    )
    assertEquals "${expected_paths[*]}" "${CHNODE_NODES[*]}"
}

test_nodes_root_var_is_null() {
    assertNull "\$CHNODE_ROOT must be null" "$CHNODE_ROOT"
}

test_chnode_list() {
    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
   node-8.1.0
   node-9.11.2
   node-9.11.2-rc1
END
)

    local actual_output
    # shellcheck disable=SC2119
    actual_output=$(chnode)

    assertEquals 0 $?
    assertEquals "$expected_output" "$actual_output"
}

test_chnode_show_version() {
    local actual_output
    actual_output=$(chnode --version)

    assertEquals 0 $?
    assertEquals "chnode: $CHNODE_VERSION" "$actual_output"
}

test_chnode_show_help() {
    local actual_output
    actual_output=$(chnode --help)

    assertEquals 0 $?
    assertEquals "Usage: chnode [-h|-r|-R|-V|NODE_VERSION]" "$actual_output"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
