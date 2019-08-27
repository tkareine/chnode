# -*- sh-shell: bash; -*-

source test/setup-shunit2.sh
source test/setup-default-chnode.sh

setUp() {
    CHNODE_NODES=("${__ORG_CHNODE_NODES[@]}")
    chnode -r
}

test_chnode_use_and_reset() {
    chnode node-8

    assertEquals 0 $?
    assertEquals "$CHNODE_NODES_DIR/node-8.1.0/bin" "$(__get_first_path_component)"
    assertEquals "$CHNODE_NODES_DIR/node-8.1.0" "$CHNODE_ROOT"
    assertEquals "use: node-8.1.0" "$(node)"

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

    chnode -r

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

    actual_output=$(chnode)

    assertEquals 0 $?
    assertEquals "$expected_output" "$actual_output"
    assertNull "\$CHNODE_ROOT must be null" "$CHNODE_ROOT"
}

test_use_selects_last_match_when_many_candidates() {
    chnode 11

    assertEquals 0 $?
    assertEquals "$CHNODE_NODES_DIR/node-9.11.2-rc1" "$CHNODE_ROOT"
}

test_use_prefers_exact_match() {
    chnode node-9.11.2

    assertEquals 0 $?
    assertEquals "$CHNODE_NODES_DIR/node-9.11.2" "$CHNODE_ROOT"
}

test_error_when_selecting_unknown_node() {
    local message
    message=$(chnode nosuch 2>&1)

    assertEquals 1 $?
    assertEquals "chnode: unknown Node.js: nosuch" "$message"
}

test_error_when_selecting_node_without_executable() {
    CHNODE_NODES+=("$CHNODE_NODES_DIR/nosuchdir")

    local message
    message=$(chnode nosuchdir 2>&1)

    assertEquals 1 $?
    assertEquals "chnode: $CHNODE_NODES_DIR/nosuchdir/bin/node not executable" "$message"
}

test_use_exports_chnode_root_and_path_vars() {
    chnode node-8

    assertEquals 0 $?
    assertEquals "$CHNODE_NODES_DIR/node-8.1.0" "$(printenv CHNODE_ROOT)"
    [[ $(printenv PATH) == *node-8* ]] || fail "\$PATH should contain node-8"
}

test_reset_clears_hash() {
    chnode node-8

    assertEquals 0 $?

    __populate_hash

    chnode -r

    assertEquals 0 $?

    local expected_output
    if [[ -n ${ZSH_VERSION:-} ]]; then
        expected_output=
    else
        expected_output='hash: hash table empty'
    fi

    assertEquals "$expected_output" "$(hash)"
}

test_use_clears_hash() {
    __populate_hash

    chnode node-8

    assertEquals 0 $?

    local expected_output
    if [[ -n ${ZSH_VERSION:-} ]]; then
        expected_output=
    else
        expected_output='hash: hash table empty'
    fi

    assertEquals "$expected_output" "$(hash)"
}

__get_first_path_component() {
    local path_comp
    read -r -d : path_comp <<<"$PATH"
    echo "$path_comp"
}

__populate_hash() {
    uname >/dev/null
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
