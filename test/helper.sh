# -*- sh-shell: bash; -*-

: "${SHUNIT2:=test/shunit2/shunit2}"

source test/fixture.sh

source chnode.sh

# shellcheck disable=SC2034
__ORG_CHNODE_NODES=("${CHNODE_NODES[@]}")

oneTimeTearDown() {
    fixture_delete_default_dir
}
