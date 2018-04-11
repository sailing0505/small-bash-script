#!/bin/bash
trap callback EXIT;
. $1;
function callback {
	echo "callback";
}




