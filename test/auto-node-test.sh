source test/setup-shunit2.sh
source test/setup-default-chnode.sh

function setUp()
{
	chnode_reset
	unset NODE_AUTO_VERSION
}

function test_chnode_auto_loaded_in_zsh()
{
	[[ -n "$ZSH_VERSION" ]] || return

  # shellcheck disable=SC2154
	assertEquals "did not add chnode_auto to preexec_functions" \
		     "chnode_auto" \
		     "$preexec_functions"
}

function test_chnode_auto_loaded_in_bash()
{
	[[ -n "$BASH_VERSION" ]] || return

	local command=". $PWD/auto.sh && trap -p DEBUG"
	local output
  # shellcheck disable=SC2034
  output="$("bash" -c "$command")"

  # shellcheck disable=SC2016
	assertTrue "did not add a trap hook for chnode_auto" \
		   '[[ "$output" == *chnode_auto* ]]'
}

function test_chnode_auto_loaded_twice_in_zsh()
{
	[[ -n "$ZSH_VERSION" ]] || return

	. ./auto.sh

	assertNotEquals "should not add chruby_auto twice" \
		        "$preexec_functions" \
			"chnode_auto chnode_auto"
}

function test_chnode_auto_loaded_twice()
{
	NODE_AUTO_VERSION="dirty"
	PROMPT_COMMAND="chruby_auto"

	. ./auto.sh

	assertNull "NODE_AUTO_VERSION was not unset" "$NODE_AUTO_VERSION"
}

function test_chnode_auto_enter_project_dir()
{
  cd "$CHNODE_NODES_AUTO_DIR" && echo "node-8.1.0" > .node-version
	cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto


	assertEquals "did not switch Node when entering a versioned directory" \
		     "$test_node_root" "$CHNODE_ROOT"
}

function test_chnode_auto_enter_subdir_directly()
{
  cd "$CHNODE_NODES_AUTO_DIR" && echo "node-8.1.0" > .node-version
  cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto
	cd "$CHNODE_NODES_AUTO_DIR/sub_dir" && chnode_auto


	assertEquals "did not switch Node when directly entering a sub-directory of a versioned directory" \
		     "$test_node_root" "$CHNODE_ROOT"
}

function test_chnode_auto_enter_subdir()
{
  cd "$CHNODE_NODES_AUTO_DIR" && echo "node-8.1.0" > .node-version
	cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto
	cd sub_dir                  && chnode_auto

	assertEquals "did not keep the current Node when entering a sub-dir" \
		     "$test_node_root" "$CHNODE_ROOT"
}

function test_chnode_auto_modified_node_version()
{
  cd "$CHNODE_NODES_AUTO_DIR/modified_version" && echo "node-11.5.0" > .node-version
	cd "$CHNODE_NODES_AUTO_DIR/modified_version" && chnode_auto
	echo "node-8.1.0" > .node-version            && chnode_auto

	assertEquals "did not detect the modified .node-version file" \
		     "$test_node_root" "$CHNODE_ROOT"
}

function test_chnode_auto_no_override_manual()
{
  cd "$CHNODE_NODES_AUTO_DIR" && echo "node-8.1.0" > .node-version
	cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto
	chnode node-10          && chnode_auto

	assertEquals "did not override the Node set in .node-version"\
        "$CHNODE_NODES_DIR/node-10.11.0" "$CHNODE_ROOT"
}

function test_chnode_auto_leave_project_dir()
{
  cd "$CHNODE_NODES_AUTO_DIR" && echo "node-8.1.0" > .node-version
	cd "$CHNODE_NODES_AUTO_DIR"    && chnode_auto
	cd "$CHNODE_NODES_AUTO_DIR/.." && chnode_auto

	assertNull "did not reset the Node when leaving a versioned directory" \
		   "$CHNODE_ROOT"
}

function test_chnode_auto_invalid_ruby_version()
{
  cd "$CHNODE_NODES_AUTO_DIR" && echo "node-8.1.0" > .node-version
  cd "$CHNODE_NODES_AUTO_DIR/bad" && echo "foo" > .node-version
	local expected_auto_version
  expected_auto_version="$(cat "$CHNODE_NODES_AUTO_DIR"/bad/.node-version)"

	cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto
	cd bad/                     && chnode_auto 2>/dev/null

	assertEquals "did not keep the current Node when loading an unknown version" \
		     "$test_node_root" "$CHNODE_ROOT"
	assertEquals "did not set NODE_AUTO_VERSION" \
		     "$expected_auto_version" "$NODE_AUTO_VERSION"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
