#!/bin/bash
COMMANDPATH=`readlink -f $0`;
DIR=`dirname $COMMANDPATH`;
echo $DIR;
