#!/bin/bash
NO_ARGS=0
E_OPTERROR=85

if [ $# -eq "$NO_ARGS" ]
then
    echo "Usage: `basename $0` options (-mnopqrs)"
    exit $E_OPTERROR
fi

while getopts ":mnopq:rs" Option
do
    case $Option in
        m ) echo "Scenario #1: option -m- [OPTIND=${OPTIND}]";;
        n | o ) echo "Scenario #2: option -$Option- [OPTIND=${OPTIND}]";;
        p ) echo "Scenario #3: option -p- [OPTIND=${OPTIND}]";;
        q ) echo "Scenario #4: option -q- with arguments \"$OPTARG\" [OPTIND=${OPTIND}]";;
        r | s ) echo "Scenario #5: option -$Option- [OPTIND=${OPTIND}]";;
        * ) echo "Unimplemented option chosen";; #Default
    esac
done

shift $(($OPTIND - 1))
exit $?
