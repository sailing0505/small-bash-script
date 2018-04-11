#!/bin/bash

MYDATE=`date +%d/%m/%Y`;
HOST=`hostname -s`;
USER=`whoami`

#loop forever
while :
do
	clear
	cat <<endl
-------------------------------------------------------------------------------------
User: $USER                   Host:$HOST                 Date:$MYDATE
-------------------------------------------------------------------------------------
		1 : List files in current directory
		2 : Use the vi editor
		3 : See who is on the system
		H : Help screen
		Q : Exit Menu
-------------------------------------------------------------------------------------
endl
	echo -e -n "Your Choice [1,2,3,H,Q] >"
	read CHOICE
		case $CHOICE in
			1) ls
				;;
			2) vi
				;;
			3) who
				;;
			h|H) cat <<endl
This is the help screen, nothing here yet to help you!
endl
				;;
			q|Q) exit 0
				;;
			*) echo -e "\t\007invalid input"
				;;
		esac
	echo -e -n "Hit the return key to continue"
	read DUMMY
done
