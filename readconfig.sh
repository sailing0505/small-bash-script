function run() {
    while read LINE ;do
        LINE=$(echo $LINE|sed 's/^[\t[:space:]]*#.*$//g');
        if [ ! -z "${LINE}" ]; then
            local SAV=${IFS}
            local IFS="=";
            local content=(${LINE})
            local k=${content[0]}
            local v=${content[1]}
            echo ${k}=${v}
            local IFS=${SAV}
            export ${k}=${v}

        fi
    done < isuncloud/tool.cfg
}



