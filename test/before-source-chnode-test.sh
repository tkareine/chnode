# -*- sh-shell: bash; -*-

source test/support/setup-shunit2.sh
source support/fixture.sh

setUp() {
    fixture_make_nodes_dir
    CHNODE_NODES_DIR=$__FIXTURE_NODES_DIR
    __test_out_dir=$(mktemp -d /tmp/chnode-before-source-chnode.XXXXXX)
}

tearDown() {
    rm -rf "$__test_out_dir"
    fixture_delete_nodes_dir
}

test_empty_nodes_var_when_empty_nodes_dir() {
    local num_nodes
    num_nodes=$(
        source chnode.sh
        echo "$?,${#CHNODE_NODES[@]}"
    )
    assertEquals "0,0" "$num_nodes"
}

test_empty_nodes_var_when_null_nodes_dir() {
    local num_nodes
    num_nodes=$(
        CHNODE_NODES_DIR=
        source chnode.sh
        echo "$?,${#CHNODE_NODES[@]}"
    )
    assertEquals "0,0" "$num_nodes"
}

test_empty_nodes_var_when_nonexisting_nodes_dir() {
    local num_nodes
    num_nodes=$(
        # shellcheck disable=SC2030
        CHNODE_NODES_DIR=/tmp/chnode-nosuch-dir
        source chnode.sh
        echo "$?,${#CHNODE_NODES[@]}"
    )
    assertEquals "0,0" "$num_nodes"
}

test_empty_nodes_var_when_nonempty_nodes_dir_with_just_dotfiles() {
    # shellcheck disable=SC2031
    touch "$CHNODE_NODES_DIR"/.node-empty
    local num_nodes
    num_nodes=$(
        source chnode.sh
        echo "$?,${#CHNODE_NODES[@]}"
    )
    assertEquals "0,0" "$num_nodes"
}

test_no_dotfiles_in_nodes_var() {
    # shellcheck disable=SC2031
    touch "$CHNODE_NODES_DIR"/.node-empty
    # shellcheck disable=SC2031
    fixture_make_nodes "$CHNODE_NODES_DIR" .node-dotfile
    # shellcheck disable=SC2031
    fixture_make_nodes "$CHNODE_NODES_DIR" node-regular

    local expected_output
    expected_output=$(cat <<END
0,1
   node-regular
END
)

    local actual_output
    actual_output=$(
        source chnode.sh
        echo "$?,${#CHNODE_NODES[@]}"
        # shellcheck disable=SC2119
        chnode
    )

    assertEquals 0 $?
    assertEquals "$expected_output" "$actual_output"
}

test_use_ls_external_utility_to_check_nodes_dir() {
    local ls_fun_out=$__test_out_dir/.ls_fun
    local num_nodes
    num_nodes=$(
        ls() {
            echo "should not see me" >"$ls_fun_out"
            command ls "$@"
        }
        source chnode.sh
        echo "$?,${#CHNODE_NODES[@]}"
    )
    assertEquals "0,0" "$num_nodes"
    # shellcheck disable=SC2016
    assertFalse "expected not to exist: $ls_fun_out" '[[ -e $ls_fun_out ]]'
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
