#!/bin/bash
function initOutPutColor
{
    red='\e[0;31m'
    nc='\e[0m'
    green='\e[0;32m'
    gray='\e[0;36m'
}

function fun1() {
    echo "123"
}

function main() {
    initOutPutColor;
    local abc=$(fun1);
    echo ${abc};
#    ls /abc 2>/dev/null; 
    return $?
}

function checkResult() {
    local ret=$1;
    if [ $ret -ne 0 ]; then
        echo -e "${red}failed${nc}";
        exit 1;
    else
        echo -e "${green}success${nc}";
    fi
}

main;
checkResult $?
