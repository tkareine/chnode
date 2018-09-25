# -*- sh-shell: bash; -*-

SHUNIT2=${SHUNIT2:-test/shunit2/shunit2}

source test/fixture.sh

source chnode.sh

oneTimeTearDown() {
    fixture_delete_default_dir
}
