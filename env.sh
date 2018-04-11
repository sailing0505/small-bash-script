#!/bin/bash
function envtest
{
	if [[ ! $TEST ]]; then
		echo "don't have this env variable $TEST, creat it"
		export TEST="~/.m2"
	else
		echo "env variable \$TEST = $TEST"
	fi
}

echo "First call"
envtest;
echo "Second cal"
envtest;