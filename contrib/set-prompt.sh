#!/usr/bin/env bash

set_prompt() {
    local user_and_host='\u@\h '
    local cwd='\w '

    local end
    if [[ $UID == "0" ]]; then
        end="# "
    else
        end="$ "
    fi

    local node_version=''
    [[ -n $CHNODE_ROOT ]] && node_version="($(echo "${CHNODE_ROOT##*/}" | tr - :))"

    PS1="${user_and_host}${cwd}${node_version}\\n${end}"
}

PROMPT_COMMAND=set_prompt
