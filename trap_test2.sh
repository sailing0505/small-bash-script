#!/bin/bash
trap callback EXIT
function callback {
	echo "callback2";
}
