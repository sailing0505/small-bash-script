#!/bin/bash
while getopts ":abcde:fg" Option
do
    case $Option in
        a )
            echo "-a";;
        b )
            echo "-b";;
        e )
            echo "-e";;
        f )
            shift
            arg=$1
            echo "-f $arg"
            ;;
        g )
            echo "-g"
            ;;
    esac
done
shift $(($OPTIND - 1))
echo "rest arg :$*"
