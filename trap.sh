#!/bin/bash

#register timeout callback

trap "echo capture SIGKILL" SIGKILL;
trap "echo capture SIGINT" SIGINT;
trap "echo capture SIGHUP" SIGHUP;
trap "echo capture SIGTERM" SIGTERM;


while [[ 1 ]]; do
	sleep 1;
done
