# -*- sh-shell: bash; -*-

source test/support/setup-shunit2.sh
source support/fixture.sh

setUp() {
    fixture_make_nodes_dir
    CHNODE_NODES_DIR=$__FIXTURE_NODES_DIR
    fixture_make_default_nodes "$CHNODE_NODES_DIR"
    source chnode.sh
}

tearDown() {
    fixture_delete_nodes_dir
}

test_reload_changed_nodes() {
    fixture_make_nodes "$CHNODE_NODES_DIR" node-6.0.0
    rm -rf "$CHNODE_NODES_DIR/node-10.11.0"

    chnode -R

    assertEquals 0 $?

    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
   node-6.0.0
   node-8.1.0
   node-9.11.2
   node-9.11.2-rc1
END
)

    local actual_output
    actual_output=$(chnode)

    assertEquals 0 $?
    assertEquals "$expected_output" "$actual_output"
}

test_reloading_keeps_selected_node() {
    chnode node-8

    assertEquals 0 $?

    rm -rf "$CHNODE_NODES_DIR/node-10.11.0"

    chnode -R

    assertEquals 0 $?

    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
 * node-8.1.0
   node-9.11.2
   node-9.11.2-rc1
END
)

    local actual_output
    actual_output=$(chnode)

    assertEquals 0 $?
    assertEquals "$expected_output" "$actual_output"
    assertEquals "$CHNODE_NODES_DIR/node-8.1.0" "$CHNODE_ROOT"
}

test_reloading_forgets_selection_for_deleted_node() {
    chnode node-8

    assertEquals 0 $?

    rm -rf "$CHNODE_NODES_DIR/node-8.1.0"

    chnode -R

    assertEquals 0 $?

    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
   node-9.11.2
   node-9.11.2-rc1
END
)

    local actual_output
    actual_output=$(chnode)

    assertEquals 0 $?
    assertEquals "$expected_output" "$actual_output"
    assertNull "\$CHNODE_ROOT must be null" "$CHNODE_ROOT"
}

test_error_when_reloading_node_and_selected_node_is_not_executable() {
    chnode node-8

    assertEquals 0 $?

    chmod a-x "$CHNODE_NODES_DIR/node-8.1.0/bin/node"

    local message
    message=$(chnode -R 2>&1)

    assertEquals 1 $?
    assertEquals "chnode: $CHNODE_NODES_DIR/node-8.1.0/bin/node not executable" "$message"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
