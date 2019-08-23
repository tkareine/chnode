# -*- sh-shell: bash; -*-

source test/setup-shunit2.sh
source test/setup-default-auto.sh

setUp() {
    chnode_reset
    unset CHNODE_AUTO_VERSION
}

test_chnode_auto_loaded_in_zsh() {
    [[ -n ${ZSH_VERSION:-} ]] || return

    # shellcheck disable=SC2154
    assertEquals "did not add chnode_auto to preexec_functions" \
                 "chnode_auto" \
                 "${preexec_functions[@]}"
}

test_chnode_auto_loaded_in_bash() {
    [[ -n ${BASH_VERSION:-} ]] || return

    local command="source $PWD/auto.sh && trap -p DEBUG"
    local output
    # shellcheck disable=SC2034
    output="$(bash -c "$command")"

    # shellcheck disable=SC2016
    assertTrue "did not add a trap hook for chnode_auto" \
               '[[ $output == *chnode_auto* ]]'
}

test_chnode_auto_loaded_twice_in_zsh() {
    [[ -n ${ZSH_VERSION:-} ]] || return

    source ./auto.sh

    assertNotEquals "should not add chruby_auto twice" \
                    "${preexec_functions[@]}" \
                    "chnode_auto chnode_auto"
}

test_chnode_auto_loaded_twice() {
    CHNODE_AUTO_VERSION="dirty"
    PROMPT_COMMAND="chruby_auto"

    source ./auto.sh

    assertNull "CHNODE_AUTO_VERSION was not unset" "$CHNODE_AUTO_VERSION"
}

test_chnode_auto_enter_project_dir() {
    cd "$__CHNODE_AUTO_DIR" && echo "node-8.1.0" > .node-version
    cd "$__CHNODE_AUTO_DIR" && chnode_auto

    assertEquals "did not switch Node when entering a versioned directory" \
                 "$test_node_root" "$CHNODE_ROOT"
}

test_chnode_auto_enter_subdir_directly() {
    cd "$__CHNODE_AUTO_DIR" && echo "node-8.1.0" > .node-version
    cd "$__CHNODE_AUTO_DIR" && chnode_auto
    cd "$__CHNODE_AUTO_DIR/sub_dir" && chnode_auto

    assertEquals "did not switch Node when directly entering a sub-directory of a versioned directory" \
                 "$test_node_root" "$CHNODE_ROOT"
}

test_chnode_auto_enter_subdir() {
    cd "$__CHNODE_AUTO_DIR" && echo "node-8.1.0" > .node-version
    cd "$__CHNODE_AUTO_DIR" && chnode_auto
    cd sub_dir && chnode_auto

    assertEquals "did not keep the current Node when entering a sub-dir" \
                 "$test_node_root" "$CHNODE_ROOT"
}

test_chnode_auto_modified_node_version() {
  cd "$__CHNODE_AUTO_DIR/modified_version" && echo "node-10.11.0" > .node-version
  cd "$__CHNODE_AUTO_DIR/modified_version" && chnode_auto
  echo "node-8.1.0" > .node-version && chnode_auto

  assertEquals "did not detect the modified .node-version file" \
               "$test_node_root" "$CHNODE_ROOT"
}

test_chnode_auto_no_override_manual() {
  cd "$__CHNODE_AUTO_DIR" && echo "node-8.1.0" > .node-version
  cd "$__CHNODE_AUTO_DIR" && chnode_auto
  chnode node-10 && chnode_auto

  assertEquals "did not override the Node set in .node-version"\
               "$CHNODE_NODES_DIR/node-10.11.0" "$CHNODE_ROOT"
}

test_chnode_auto_leave_project_dir() {
  cd "$__CHNODE_AUTO_DIR" && echo "node-8.1.0" > .node-version
  cd "$__CHNODE_AUTO_DIR" && chnode_auto
  cd "$__CHNODE_AUTO_DIR/.." && chnode_auto

  assertNull "did not reset the Node when leaving a versioned directory" \
             "$CHNODE_ROOT"
}

test_chnode_auto_invalid_ruby_version() {
  cd "$__CHNODE_AUTO_DIR" && echo "node-8.1.0" > .node-version
  cd "$__CHNODE_AUTO_DIR/bad" && echo "foo" > .node-version
  local expected_auto_version

  expected_auto_version="$(cat "$__CHNODE_AUTO_DIR"/bad/.node-version)"

  cd "$__CHNODE_AUTO_DIR" && chnode_auto
  cd bad && chnode_auto 2>/dev/null

  assertEquals "did not keep the current Node when loading an unknown version" \
               "$test_node_root" "$CHNODE_ROOT"
  assertEquals "did not set CHNODE_AUTO_VERSION" \
               "$expected_auto_version" "$CHNODE_AUTO_VERSION"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
