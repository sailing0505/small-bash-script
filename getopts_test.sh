#!/bin/bash
NO_ARGS=0
E_OPTERROR=85

if [ $# -eq "$NO_ARGS" ]
then
    echo "Usage: `basename $0` options (-mnopqrs)"
    exit $E_OPTERROR
fi

while getopts ":a:b:" opt; do
    case ${opt} in
        a)
            echo ${OPTARG}
            ;;
        b)
            echo ${OPTARG}
            ;;

        *)
            echo "invalid option"
            ;;
    esac
done

shift $(($OPTIND - 1))
exit $?
