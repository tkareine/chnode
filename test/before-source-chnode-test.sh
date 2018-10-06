# -*- sh-shell: bash; -*-

source test/setup-shunit2.sh
source support/fixture.sh

setUp() {
    fixture_make_default_dir
    CHNODE_NODES_DIR=$__FIXTURE_DEFAULT_DIR
}

tearDown() {
    fixture_delete_default_dir
}

test_empty_nodes_var_when_empty_nodes_dir() {
    local num_nodes
    num_nodes=$(
        source chnode.sh
        echo "${#CHNODE_NODES[@]}"
    )
    assertEquals 0 "$num_nodes"
}

test_empty_nodes_var_when_null_nodes_dir() {
    local num_nodes
    num_nodes=$(
        CHNODE_NODES_DIR=
        source chnode.sh
        echo "${#CHNODE_NODES[@]}"
    )
    assertEquals 0 "$num_nodes"
}

test_empty_nodes_var_when_nonexisting_nodes_dir() {
    local num_nodes
    num_nodes=$(
        # shellcheck disable=SC2034
        CHNODE_NODES_DIR=/tmp/chnode-nosuch-dir
        source chnode.sh
        echo "${#CHNODE_NODES[@]}"
    )
    assertEquals 0 "$num_nodes"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
