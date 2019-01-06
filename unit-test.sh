#!/bin/bash
set +x

function initOutPutColor
{
	red='\e[0;31m'
	nc='\e[0m'
	green='\e[0;32m'
	gray='\e[0;36m'
}
function getNode
{
	isPrefixzero=false;
	charNum=`echo -n $1|wc -m`
	echo $1|grep -E "^0[0-9]+$" 2>&1 > /dev/null
	RET=$?
	if [[ $RET -eq 0 ]]; then
		isPrefixzero=true;
		if [[ $charNum -gt 2 ]]; then
			echo "large than 9"
			node="node"`echo -n $1|sed 's/^0//'`
		else
			echo "between 0 - 9"
			node="node$1"
		fi
	else
		isPrefixzero=false;
		if [[ $charNum -gt 1 ]]; then
			echo "large than 9"
			node="node$1"
		else
			echo "bwteen 0 - 9"
			node="node0$1"
		fi
	fi
	echo "isPrefixzero = $isPrefixzero"
	echo "$node"
}

function checkResult
{
	if [[ $1 -ne 0 ]]; then
		echo  -e "${gray}Result	${red}:FAILD${nc}"
	else
		echo  -e "${gray}Result	${green}:PASS${nc}"
	fi
}

function testcase1
{
	echo -e "${green}*****${gray}executing testcase1${green}*****${nc}"
	getNode 09
	test $node = "node09"
	checkResult $?
}

function testcase2
{
	echo -e "${green}*****${gray}executing testcase2${green}*****${nc}"
	getNode 9
	test $node = "node09"
	checkResult $?
}

function testcase3
{
	echo -e "${green}*****${gray}executing testcase3${green}*****${nc}"
	getNode 090
	test $node = "node90"
	checkResult $?
}

function testcase4
{
	echo -e "${green}*****${gray}executing testcase4${green}*****${nc}"
	getNode 91110
	test $node = "node91110"
	checkResult $?
}

function testcase5
{
	echo -e "${green}*****${gray}executing testcase5${green}*****${nc}"
	echo "node111" >> know_clab.txt
	echo "node222" >> know_clab.txt
	echo "node333" >> know_clab.txt
	delnode="node222"
	sed "/$delnode/"d know_clab.txt >> know_clab.new
	mv know_clab.new know_clab.txt
	cat know_clab.txt
	test !`grep node222 know_clab.txt`
	checkResult $?
}

function runTest
{
	initOutPutColor;
	testcase1;
	testcase2;
	testcase3;
	testcase4;
	testcase5;
}

function Main
{
	while [[ -n "$1" ]]; do
		case $1 in
			-test|-t )shift
				runTest
				exit 0
				;;
			*)
				getNode $@
				for (( i = 0; i < $#; i++ )); do
					shift
				done
				;;
		esac
	done
}

Main $@
