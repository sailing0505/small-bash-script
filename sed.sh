#!/bin/bash
files=$(find . -name "Makefile"|grep -v test);
vfile=''
for i in ${files}; do
    if [[ `grep -E "PUBELEMS[ |\t]*=" ${i}` ]]; then
        if [ -z "${vfile}" ]; then
            vfile=${i};
        else
            vfile="${i} ${vfile}";
        fi
    fi
done

for i in ${vfile}; do
    echo "modify ${i}";
    sed -i -e '/PUBELEMS/ i PUBHDRS = $(patsubst %.h, $(LOCAL_STAGE)/include/%.h, $(HDRS))\n' "${i}";
done

