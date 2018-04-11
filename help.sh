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
	value=$(test) || error;
	echo $value;
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