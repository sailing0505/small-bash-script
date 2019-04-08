#!/bin/bash


function usage
{
	cat << EOF
this is help message
EOF
}

# if [[ $1 == "-h" || $1 == "--help" || $# < 1 ]]; then
# 	usage;
# fi

function call() {
	#value=$(test) || error;
	#value=$(test);
	#echo $value;
    if ! test; then
        echo test pass
    fi
}

function test() {
	echo "abc";
	return 1;
	echo "never call";
}

function error() {
	echo "this is error happens";
	exit 1;
}

call;
