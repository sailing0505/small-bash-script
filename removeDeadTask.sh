#!/bin/bash


function releaseCheck() {
	case $1 in
		trunk )
			;;
		17-2 ) shift;
			;;
		* )
			echo "not support this release: $1"
			return 1
			;;
	esac
}

function removeDeadJobByRelease() {
	local 
}

files=`find /opt/mpp/logs/nass/components/nass/T2-module-icf -name "nass-T2*.xml"|grep -v 465`;
problemF='';


for i in $files; do
        if [[ ! `grep -E "name='Build'.*end=" $i` ]]; then
                if [[ $problemF == '' ]]; then
                        problemF=$i;
                else
                        problemF="$problemF $i";
                fi
        fi
done

echo $problemF;

time=`date +%Y-%m-%dT%H:%M:%S%:z`;
endStr="end='$time'";

for i in $problemF; do
        echo "handle file $i";
        sed -i "s/\(stats name='Build'.*start=.*\)/\1 $endStr/g" $i; 
done