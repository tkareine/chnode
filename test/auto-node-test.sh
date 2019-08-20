# -*- sh-shell: bash; -*-

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

	assertEquals "did not add chnode_auto to preexec_functions" \
		     "chnode_auto" \
		     "$preexec_functions"
}

function test_chnode_auto_loaded_in_bash()
{
	[[ -n "$BASH_VERSION" ]] || return

	local command=". $PWD/share/chnode/auto.sh && trap -p DEBUG"
	local output="$("$SHELL" -c "$command")"

	assertTrue "did not add a trap hook for chnode_auto" \
		   '[[ "$output" == *chnode_auto* ]]'
}

function test_chnode_auto_loaded_twice_in_zsh()
{
	[[ -n "$ZSH_VERSION" ]] || return
	. ./auto.sh
	assertNotEquals "should not add chnode_auto twice" \
		        "$preexec_functions" \
			"chnode_auto chnode_auto"
}

function test_chnode_auto_loaded_twice()
{
	NODE_AUTO_VERSION="dirty"
	PROMPT_COMMAND="chnode_auto"

	. ./auto.sh

	assertNull "NODE_AUTO_VERSION was not unset" "$NODE_AUTO_VERSION"
}

function test_chnode_auto_enter_project_dir()
{
	cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto

	assertEquals "did not switch node when entering a versioned directory" \
		     "$test_node_root" "$NODE_ROOT"
}

function test_chnode_auto_enter_subdir_directly()
{
	cd "$CHNODE_NODES_AUTO_DIR/sub_dir" && chnode_auto

	assertEquals "did not switch node when directly entering a sub-directory of a versioned directory" \
		     "$test_node_root" "$NODE_ROOT"
}

function test_chnode_auto_enter_subdir()
{
	cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto
	cd sub_dir             && chnode_auto

	assertEquals "did not keep the current node when entering a sub-dir" \
		     "$test_node_root" "$NODE_ROOT"
}

function test_chnode_auto_enter_subdir_with_node_version()
{
	cd "$CHNODE_NODES_AUTO_DIR"    && chnode_auto
	cd sub_versioned/         && chnode_auto

	assertNull "did not switch the node when leaving a sub-versioned directory" \
		   "$NODE_ROOT"
}

function test_chnode_auto_modified_node_version()
{
	cd "$CHNODE_NODES_AUTO_DIR/modified_version" && chnode_auto
	echo "node-8.1.0" > .node-version              && chnode_auto

	assertEquals "did not detect the modified .node-version file" \
		     "$test_node_root" "$NODE_ROOT"
}

function test_chnode_auto_overriding_node_version()
{
	cd "$CHNODE_NODES_AUTO_DIR" && chnode_auto
	chnode node-8         && chnode_auto

	assertNull "did not override the node set in .node-version" "$NODE_ROOT"
}

function test_chnode_auto_leave_project_dir()
{
	cd "$CHNODE_NODES_AUTO_DIR"    && chnode_auto
	cd "$CHNODE_NODES_AUTO_DIR/.." && chnode_auto

	assertNull "did not reset the node when leaving a versioned directory" \
		   "$NODE_ROOT"
}

function test_chnode_auto_invalid_node_version()
{


	cd "$CHNODE_NODES_AUTO_DIR/bad/" && chnode_auto
  touch .node-version  && chnode_auto


	cd "$CHNODE_NODES_AUTO_DIR/bad/" && chnode_auto 2>/dev/null

  local expected_auto_version="$(cat "$CHNODE_NODES_AUTO_DIR"/bad/.node-version)"

	assertEquals "did not keep the current node when loading an unknown version" \
		     "$test_node_root" "$NODE_ROOT"
	assertEquals "did not set NODE_AUTO_VERSION" \
		     "$expected_auto_version" "$NODE_AUTO_VERSION"
}

SHUNIT_PARENT=$0 source "$SHUNIT2"
