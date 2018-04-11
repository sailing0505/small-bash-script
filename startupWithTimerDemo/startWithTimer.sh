#!/bin/bash

#register timeout callback
function expire 
{
	echo "timer expire happen!";
	echo "kill expired process : $child_pids";
	`kill -SIGKILL $child_pids 2>&1 >> /dev/null`;
}

trap expire SIGUSR2;

#lauch script
scripts="
script/cmd_120s.sh
script/cmd_60s.sh
"
child_pids="";
for script in $scripts; do
	rm -f "$script.log"
	nohup $script 2>&1 >> "$script.log" &
	# echo "$script pid : $!"
	child_pids="$child_pids $!";
done

echo "child_pids : $child_pids";
echo "PID is $$"

#timer job
pid=$$;
timeout=60
count=0;
while sleep 1; do
	count=`expr $count + 1`
	if [[ $count -gt $timeout ]]; then
		break;
	fi
done
kill -SIGUSR2 $pid;