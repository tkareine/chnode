# -*- sh-shell: bash; -*-

source test/helper.sh

setUp() {
    CHNODE_NODES=("${__ORG_CHNODE_NODES[@]}")
    __test_nodes_dir=$(mktemp -d /tmp/chnode-add-node.XXXXXX)
}

tearDown() {
    rm -fr "$__test_nodes_dir"
}

test_use_node_added_to_nodes_var() {
    fixture_make_nodes_dir "$__test_nodes_dir" node-6.0.0
    CHNODE_NODES+=("$__test_nodes_dir/node-6.0.0")

    chnode node-6

    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
   node-8.1.0
   node-9.11.2
   node-9.11.2-rc1
 * node-6.0.0
END
)

    assertEquals "$expected_output" "$(chnode)"
    assertEquals "$__test_nodes_dir/node-6.0.0" "$CHNODE_ROOT"
    assertEquals "use: node-6.0.0" "$(node)"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
