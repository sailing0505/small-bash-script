#!/bin/bash

function isMatch
{
	echo $@|grep -E '^[a-zA-Z0-9_/][a-zA-Z0-9_-/]{0,}$' > /dev/null;
	if [[ $? -ne 0 ]]; then
		echo "Not match";
		echo "Expect regular expression is : '^[a-zA-Z0-9_/][a-zA-Z0-9_-/]{0,}$'";
	else
		echo "Match";
	fi
}

isMatch $@;