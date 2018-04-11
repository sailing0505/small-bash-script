#!/bin/bash
count=0
while sleep 1; do
	count=`expr $count + 1`
	echo $count;
	if [[ $count -gt 60 ]]; then
		break;
	fi
done