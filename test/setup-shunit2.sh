# -*- sh-shell: bash; -*-

: "${SHUNIT2:=test/shunit2/shunit2}"

[[ -n ${ZSH_VERSION:-} ]] && setopt shwordsplit
