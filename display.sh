#!/bin/bash

for (( i = 0; i < 100; i++ )); do
	echo -ne "    Progress: $i%\r";
	sleep 1;
done
