# -*- sh-shell: bash; -*-

source test/helper.sh

test_chnode_list() {
    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
   node-6.0.0
   node-8.1.0
   node-9.11.2
END
)

    local actual_output
    actual_output=$(chnode)

    assertEquals "$expected_output" "$actual_output"
}

test_chnode_use_and_reset() {
    chnode node-8

    local path_comp
    read -r -d : path_comp <<<"$PATH"

    assertEquals "$CHNODE_NODES_DIR/node-8.1.0/bin" "$path_comp"

    local expected_output
    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
   node-6.0.0
 * node-8.1.0
   node-9.11.2
END
)

    assertEquals "$expected_output" "$(chnode)"

    chnode reset

    [[ "$PATH" != *node-8* ]] || fail "\$PATH shouldn't contain node-8"

    expected_output=$(cat <<END
   iojs-3.3.1
   node-10.11.0
   node-6.0.0
   node-8.1.0
   node-9.11.2
END
)

    assertEquals "$expected_output" "$(chnode)"
}

source "$SHUNIT2"
