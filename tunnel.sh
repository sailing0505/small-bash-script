#!/usr/bin/env bash

TUNNEL='/tmp/ssh_tunnel'
SSHD='/etc/ssh/sshd_config'
set +x

function start() {
    prepareEnv "${1}";
    createRTunnel "clab${1}node06";
    createLTunnel "clab${1}node05";
}

function prepareEnv() {
    mkdir -p ${TUNNEL};
    echo "close all exiting tunnel";
    closeAllTunnel;
    configServer clab"${1}"node06;
    configServer clab"${1}"node05;
}

function configServer() {
    echo "config ssh server for ${1}, enabel AllowTcpForwarding";
    ssh -q -oStrictHostKeyChecking=no -o CheckHostIP=no root@"${1}".netact.nsn-rdnet.net "sed -i -e '/AllowTcpForwarding/d'  -e '/AllowAgentForwarding/i AllowTcpForwarding yes' ${SSHD} && systemctl restart sshd;"
}

function createRTunnel() {
    #CBAM V3 simulator
    ssh -S ${TUNNEL}/tunnel-"${1}"-9010 -NqfMR 9010:localhost:9010 -oStrictHostKeyChecking=no -o CheckHostIP=no root@"$1".netact.nsn-rdnet.net;
    echo "Tunnel: tunnel-${1}-9010 created"
    #CBAM V4 simulator
    ssh -S ${TUNNEL}/tunnel-"${1}"-9020 -NqfMR 9020:localhost:9020 -oStrictHostKeyChecking=no -o CheckHostIP=no root@"$1".netact.nsn-rdnet.net;
    echo "Tunnel: tunnel-${1}-9020 created"
    #this is swm simulator
    ssh -S ${TUNNEL}/tunnel-"${1}"-8081 -NqfMR 8081:localhost:8081 -oStrictHostKeyChecking=no -o CheckHostIP=no root@"$1".netact.nsn-rdnet.net;
    echo "Tunnel: tunnel-${1}-8081 created"
}

function createLTunnel() {
    ssh -S ${TUNNEL}/tunnel-"${1}"-17443 -NqfML 17443:clab700lbwas.netact.nsn-rdnet.net:17443 -o StrictHostKeyChecking=no -o CheckHostIP=no root@"${1}".netact.nsn-rdnet.net;
    echo "Tunnel: tunnel-${1}-17443 created"
    ssh -S ${TUNNEL}/tunnel-"${1}"-17001 -NqfML 17001:clab700lbjbi.netact.nsn-rdnet.net:17001 -o StrictHostKeyChecking=no -o CheckHostIP=no root@"${1}".netact.nsn-rdnet.net;
    echo "Tunnel: tunnel-${1}-17001 created"
    ssh -S ${TUNNEL}/tunnel-"${1}"-17002 -NqfML 17002:clab700lbjbi.netact.nsn-rdnet.net:17002 -o StrictHostKeyChecking=no -o CheckHostIP=no root@"${1}".netact.nsn-rdnet.net;
    echo "Tunnel: tunnel-${1}-17002 created"
}

function stop() {
    closeAllTunnel;
}

function closeAllTunnel() {
    cd ${TUNNEL} || echo "folder ${TUNNEL} not exist";
    tunnels=$(echo *);
    cd - 1>&2 >> /dev/null || echo "folder ${TUNNEL} not exist";
    if [[ ${tunnels} != "*" ]]; then 
        #the folder is not empty
        for i in ${tunnels}; do
            closeTunnel "${i}";
        done
    fi
}

function closeTunnel() {
    local IFS="-";
    local content=($1);
    local host=${content[1]};
    local port=${content[2]};
    ssh -S ${TUNNEL}/"${1}" -O exit root@"${host}".netact.nsn-rdnet.net 2>>/dev/null;
    echo "Tunnel: tunnel-$host-$port closed";
}

function usage() {
    cat << endl
This script is used to setup the ssh tunnel ntcapp swm TA
Syntax:
    $0
        start [lab id]: start the ssh tunnel between local laptop and clonepool
        stop: clear all existing ssh tunnel
        [-h|--help]: print the help message
Example:
    $0 start 2564 : create 3 ssh tunnel for clab2564
    $0 stop

endl
}

function main() {
    while [[ -n "$1" ]]; do
        case $1 in
            -h| --help )
                usage;
                exit 0;
                ;;
            start ) shift
                if [[ -z $1 ]]; then
                    echo "invalid command, need assign lab id"
                    usage;
                    exit 1;
                fi
                start $@;
                exit $?;
                ;;
            stop ) shift
                stop $@;
                exit $?;
                ;;
            * ) shift
                echo "unknow command";
                usage;
                exit 1;
        esac
    done
}

main $@
