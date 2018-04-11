#!/bin/bash


function ftype() {
	FD=$1;
	if [[ -d $FD ]]; then
		echo "$FD is a dir";
	elif [[ -f $FD ]]; then
		echo "$FD is a regular file";
	elif [[ -b $FD ]]; then
		echo "$FD is block device. e.g cd-rom, usb etc.."
	elif [[ -c $FD ]]; then
		echo "$FD is a charactor device. e.g. keybord, mouse etc.."
	elif [[ -p $FD ]]; then
		echo "$FD is a pipe device."
	elif [[ -h $FD ]]; then
		echo "$FD is a symbolic link."
	elif [[ -S $FD ]]; then
		echo "$FD is a socket file."
	elif [[ -t $FD ]]; then
		echo "$FD is a tty device."
	else
		echo "$FD is no recongnized"
	fi	
}
ftype $@