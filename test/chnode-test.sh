# -*- sh-shell: bash; -*-

source test/helper.sh

setUp() {
    CHNODE_NODES=("${__ORG_CHNODE_NODES[@]}")
    chnode reset
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
    actual_output=$(chnode)

    assertEquals 0 $?
    assertEquals "$expected_output" "$actual_output"
    assertNull "\$CHNODE_ROOT must be null" "$CHNODE_ROOT"
}

test_chnode_use_and_reset() {
    chnode node-8

    assertEquals 0 $?
    assertEquals "$CHNODE_NODES_DIR/node-8.1.0/bin" "$(get_first_path_component)"
    assertEquals "$CHNODE_NODES_DIR/node-8.1.0" "$CHNODE_ROOT"

    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
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

    chnode reset

    assertEquals 0 $?

    [[ "$PATH" != *node-8* ]] || fail "\$PATH shouldn't contain node-8"

    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
   node-8.1.0
   node-9.11.2
   node-9.11.2-rc1
END
)

    assertEquals "$expected_output" "$(chnode)"
    assertNull "\$CHNODE_ROOT must be null" "$CHNODE_ROOT"
}

test_use_selects_last_match_when_many_candidates() {
    chnode 11
    assertEquals "$CHNODE_NODES_DIR/node-9.11.2-rc1" "$CHNODE_ROOT"
}

test_use_prefers_exact_match() {
    chnode node-9.11.2
    assertEquals "$CHNODE_NODES_DIR/node-9.11.2" "$CHNODE_ROOT"
}

test_error_when_selecting_unknown_node() {
    local message
    message=$(chnode nosuch 2>&1)

    assertEquals 1 $?
    assertEquals "chnode: unknown Node.js: nosuch" "$message"
    assertNull "\$CHNODE_ROOT must be null" "$CHNODE_ROOT"
}

test_error_when_selecting_node_without_executable() {
    CHNODE_NODES+=("$CHNODE_NODES_DIR/nosuchdir")

    local message
    message=$(chnode nosuchdir 2>&1)

    assertEquals 1 $?
    assertEquals "chnode: $CHNODE_NODES_DIR/nosuchdir/bin/node not executable" "$message"
    assertNull "\$CHNODE_ROOT must be null" "$CHNODE_ROOT"
}

test_reset_clears_hash() {
    chnode node-8
    populate_hash
    chnode reset

    assertEquals "hash: hash table empty" "$(hash)"
}

test_use_clears_hash() {
    populate_hash
    chnode node-8

    assertEquals "hash: hash table empty" "$(hash)"
}

get_first_path_component() {
    local path_comp
    read -r -d : path_comp <<<"$PATH"
    echo "$path_comp"
}

populate_hash() {
    uname >/dev/null
}

source "$SHUNIT2"
