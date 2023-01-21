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
    if [[ -n $CHNODE_ROOT ]]; then
        node_version=${CHNODE_ROOT##*/}
        node_version=${node_version/-/:}
    fi

    PS1="${user_and_host}${cwd}${node_version}\\n${end}"
}

PROMPT_COMMAND=set_prompt
