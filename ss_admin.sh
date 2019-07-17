#!/bin/bash

function start() {
    if [ -z $1 ]; then
        usage
        return 1
    fi
    local name=$1
    if isvalidServer ${name}; then
        newSSconfig ${name}
        sudo /home/j30wu/software/myscript/sudo.sh /home/j30wu/.pyenv/shims/sslocal -c /tmp/${name}.json -d start
        sudo /home/j30wu/software/myscript/sudo.sh systemctl start polipo
        echo "start ss ${name} successful!"
    else
        echo "The server ${name} not support!"
        echo -e "Avalaiable server list:\n${servers[@]}"
    fi
}

function isvalidServer() {
    local server=$1
    for i in ${servers[@]}; do
        if [ "${server}" = "${i}" ] ; then
            return 0;
        fi
    done
    return 1
}

function getHostByName() {
    local name=$1
    local simple_group=(d0 d1 d2 d3 d4 g0)
    if echo ${simple_group[@]}|grep ${name} 1>&2>/dev/null; then
        echo ${hosts[0]}
    else
        echo ${hosts[1]}
    fi
}

function newSSconfig() {
    local name=$1
    local host=$(getHostByName ${name})
    cat >> /tmp/${name}.json << endl
{
    "server":"${name}.${host}",
    "server_port":"39934",
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"6340655754",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}
endl
}

function status() {
    local pinfo=($(ps -ef|grep sslocal|grep -v grep))
    local row=$((${#pinfo[@]}/13))
    echo "PID    PPID    status  server"
    for((i = 0; i < ${row}; i++)); do
        offset=$((${i}*12))
        server=$(basename ${pinfo[$((10+${offset}))]})
        echo "${pinfo[$((1+${offset}))]}    ${pinfo[$((2+${offset}))]}     ${pinfo[$((12+${offset}))]}   ${server%%.json}"
    done
}

function stop() {
    local serverlist=($(cd /tmp && ls *.json 2>>/dev/null))
    serverlist=(${serverlist[@]%%.json})

    for i in ${serverlist}; do
        sudo /home/j30wu/software/myscript/sudo.sh /home/j30wu/.pyenv/shims/sslocal -c /tmp/${i}.json -d stop
        rm -f /tmp/${i}.json
        echo "stop ss server ${i} successful"
    done
    sudo /home/j30wu/software/myscript/sudo.sh systemctl stop polipo
    echo "stop http proxy(polipo) successful"
}

function usage() {
    cat << endl
Syntax:
    ss_admin.sh start [ss_server]
    ss_admin.sh stop [ss_server]
    ss_admin.sh status
Avaliable server list:
    echo ${servers[*]}
endl
}

function main() {
    servers=(d0 d1 d2 d3 g0 g1 g2 g3 n0 n1 n2 n3 v0 v1 v2 v3)
    hosts=(2simple.dev gyteng.com)
    while [[ -n ${1} ]] ;do
        case $1 in
            "start" ) shift
                start $@
                exit $?
                ;;
            "stop" ) shift
                stop $@
                exit $?
                ;;
            "status" ) shift
                status $@
                exit $?
                ;;
            * )
                usage
                exit 1
                ;;

        esac
    done

}

main $@
