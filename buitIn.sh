#!/bin/bash


function scop() {
	echo ${scop_local};
	local scop_local="abc";
	echo ${scop_local};
}

scop;
echo ${scop_local};
