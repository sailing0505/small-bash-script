#!/bin/bash

SAVEDIFS=$IFS
IFS=:

while read NAME DEP ID; do
	echo -e "$NAME\t $DEP\t $ID\t"
done < sample.txt

IFS=$SAVEDIFS