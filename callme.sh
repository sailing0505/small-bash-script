#!/usr/bin/env bash

FEATURE_ID=".file_permision_monitor";

function firstDo() {
    echo "this is my first called";
}

function do() {
    echo "Let's get to work";
}

function isFirst() {
    # set -x
    if [ -f ${FEATURE_ID} ]; then
        return 1;
    else
        touch ${FEATURE_ID};
        return 0;
    fi
}

function _main() {
    local func;
    if isFirst; then
        func=firstDo;
    else
        func=do;
    fi
    #run the function
    if declare -F "${func}" > /dev/null; then
        ${func};
    fi
}

_main $@;
