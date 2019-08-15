#!/usr/bin/env bash

TUNNEL='/tmp/ssh_tunnel'
SSHD='/etc/ssh/sshd_config'
SUDO='sudo /home/j30wu/software/myscript/sudo.sh'
DMGR_NODE='node14'
ABS=$(readlink -f $0)
DIRNAME=$(dirname ${ABS})
realLabName=''
set +x

function start() {
    local id=${1};
    if [ ${2} == "--monitor" ]; then
        prepareEnv ${id} "node05"
        createMonitorTunnel "clab${id}node05"
    elif [ $2 == "--ntcapp" ]; then
        prepareEnv ${id} "node05" "node06"
        createNtcappLTunnel "clab${id}node05"
        createNtcappRTunnel "clab${id}node06"
    else
        usage
        exit 1
    fi
}

function isAutoLoginEnable() {
    local hostName=${1};
    grep "${hostName}" ~/.ssh/known_clab.txt 2>&1 > /dev/null;
    return $?;
}

function prepareEnv() {
    mkdir -p ${TUNNEL};
    echo "close all exiting tunnel";
    closeAllTunnel;
    local id=${1}
    shift
    for node in $@; do
        if ! isAutoLoginEnable clab"${id}"${node}; then
            copySshKey root@clab"${id}"${node}.netact.nsn-rdnet.net;
            getRealLabName clab"${id}"${node};
        fi
        configServer clab"${id}"${node};
        getRealLabName clab"${id}"${node};
    done
    configLocal ${realLabName}
}

function copySshKey() {
    local login=${1}
    if [ ! -e "$HOME/.ssh/id_rsa.pub" ]; then
            echo "[2clab] ssh key file not found, try to generate"
            ssh-keygen -t rsa;
            if [[ $? -eq 0 ]]; then
                echo "[2clab] generate ssh-key successful";
            else
                echo "[2clab] generate ssh-key failed";
                exit 1;
            fi
        fi
        #ssh-copy-id -o StrictHostKeyChecking=no -oCheckHostIP=no -i ~/.ssh/id_rsa.pub $LOGIN_ADDR
        copyKey ${login}
        if [ $? -ne 0 ]; then
            ssh-copy-id -o StrictHostKeyChecking=no -oCheckHostIP=no -i ~/.ssh/id_rsa.pub ${login}
        fi
        echo ${login} >> ~/.ssh/known_clab.txt
}

function copyKey() {
    (${DIRNAME}/copykey_expect.sh $1)
    return $?
}

function configLocal() {
    local name=${1}
    cleanHostFile
    addHosts "${name}"
}

function cleanHostFile() {
    echo "clean up /etc/hosts file"
    ${SUDO} "sed '/127.0.0.1 *clab/'d -i /etc/hosts"
}

function addHosts() {
    addHostToLocal "${name}lbwas.netact.nsn-rdnet.net"
    addHostToLocal "${name}lbjbi.netact.nsn-rdnet.net"
    addHostToLocal "${name}${DMGR_NODE}.netact.nsn-rdnet.net"
    addHostToLocal "${name}node15.netact.nsn-rdnet.net"
}

function addHostToLocal() {
    local host=$1
    local line="127.0.0.1 ${host} ${host%%.*}"
    ${SUDO} "echo ${line} >> /etc/hosts"
    echo "add /etc/hosts: ${line}"
}

function getRealLabName() {
    local lab=`ssh -q -oStrictHostKeyChecking=no -o CheckHostIP=no root@"${1}".netact.nsn-rdnet.net "hostname"`;
    if [[ -z ${lab} ]]; then
        echo "this lab is not accessbal";
        exit 1;
    fi
    realLabName=${lab%node*};
}

function configServer() {
    echo "config ssh server for ${1}, enabel AllowTcpForwarding";
    ssh -q -oStrictHostKeyChecking=no -o CheckHostIP=no root@"${1}".netact.nsn-rdnet.net "sed -i -e '/AllowTcpForwarding/d'  -e '/AllowAgentForwarding/i AllowTcpForwarding yes' ${SSHD} && systemctl restart sshd;"
}

function createNtcappLTunnel() {
    createLTunnel 17443 "${realLabName}lbwas.netact.nsn-rdnet.net:17443" "${1}.netact.nsn-rdnet.net" #NTACAPP public port for CBAM
    createLTunnel 10448 "${realLabName}lbwas.netact.nsn-rdnet.net:10448" "${1}.netact.nsn-rdnet.net" #keyclock public port for OAUTH2.0
    createLTunnel 17001 "${realLabName}lbjbi.netact.nsn-rdnet.net:17001" "${1}.netact.nsn-rdnet.net"
    createLTunnel 17002 "${realLabName}lbjbi.netact.nsn-rdnet.net:17002" "${1}.netact.nsn-rdnet.net"
    createLTunnel 17003 "${realLabName}lbjbi.netact.nsn-rdnet.net:17003" "${1}.netact.nsn-rdnet.net"
    createLTunnelSudo 443 "${realLabName}lbwas.netact.nsn-rdnet.net:443" "${1}.netact.nsn-rdnet.net" #LB HTTPS
    createLTunnelSudo 80 "${realLabName}lbwas.netact.nsn-rdnet.net:80" "${1}.netact.nsn-rdnet.net" #LB HTTPS
}

function createNtcappRTunnel() {
    createRTunnel 9010 "localhost:9010" "${1}.netact.nsn-rdnet.net"
    createRTunnel 9020 "localhost:9020" "${1}.netact.nsn-rdnet.net"
    createRTunnel 8081 "localhost:8081" "${1}.netact.nsn-rdnet.net"
}

function createMonitorTunnel() {
    createLTunnelSudo 443 "${realLabName}lbwas.netact.nsn-rdnet.net:443" "${1}.netact.nsn-rdnet.net" #LB HTTPS
    createLTunnelSudo 80 "${realLabName}lbwas.netact.nsn-rdnet.net:80" "${1}.netact.nsn-rdnet.net" #LB HTTPS
    createLTunnel 10443 "${realLabName}lbwas.netact.nsn-rdnet.net:10443" "${1}.netact.nsn-rdnet.net" #LB HTTPS
    createLTunnel 9810 "${realLabName}lbwas.netact.nsn-rdnet.net:9810" "${1}.netact.nsn-rdnet.net"  #LB EJB
    createLTunnel 9416 "${realLabName}${DMGR_NODE}.netact.nsn-rdnet.net:9416" "${1}.netact.nsn-rdnet.net" #WAS EJB
    createLTunnel 9108 "${realLabName}${DMGR_NODE}.netact.nsn-rdnet.net:9108" "${1}.netact.nsn-rdnet.net" #WAS ORB
    createLTunnel 9202 "${realLabName}${DMGR_NODE}.netact.nsn-rdnet.net:9202" "${1}.netact.nsn-rdnet.net" #WAS MUTUALAUTH
    createLTunnel 9413 "${realLabName}${DMGR_NODE}.netact.nsn-rdnet.net:9413" "${1}.netact.nsn-rdnet.net" #WAS MUTUALAUTH
    createLTunnel 9418 "${realLabName}${DMGR_NODE}.netact.nsn-rdnet.net:9418" "${1}.netact.nsn-rdnet.net" #WAS MUTUALAUTH
    createLTunnel 7285 "${realLabName}${DMGR_NODE}.netact.nsn-rdnet.net:7285" "${1}.netact.nsn-rdnet.net" #SIB WAS
    createLTunnel 7280 "${realLabName}${DMGR_NODE}.netact.nsn-rdnet.net:7280" "${1}.netact.nsn-rdnet.net" #SIB WAS
}

function createLTunnel() {
    local entrance=$1
    local exit=$2
    local sshServer=$3
    ssh -S ${TUNNEL}/tunnel-"${entrance}"-"${exit}" -NqfML ${entrance}:${exit} -o StrictHostKeyChecking=no -o CheckHostIP=no root@${sshServer};
    echo "Tunnel: tunnel-${entrance}-${exit} created"
}

function createLTunnelSudo() {
    local entrance=$1
    local exit=$2
    local sshServer=$3

    ${SUDO} ssh -S ${TUNNEL}/tunnel-"${entrance}"-"${exit}" -NqfML ${entrance}:${exit} -o StrictHostKeyChecking=no -o CheckHostIP=no root@${sshServer}
    echo "Tunnel: tunnel-${entrance}-${exit} created"
}

function createRTunnel() {
    local entrance=$1
    local exit=$2
    local sshServer=$3
    ssh -S ${TUNNEL}/tunnel-${entrance}-${exit} -NqfMR ${entrance}:${exit} -o StrictHostKeyChecking=no -o CheckHostIP=no root@${sshServer}
    echo "Tunnel: tunnel-${entrance}-${exit} created"
}

function stop() {
    cleanHostFile;
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
            status=$?;
            if [[ ${status} -ne 0 ]]; then
                closeTunnelSudo "${i}"
            fi
        done
    fi
}

function closeTunnelSudo() {
    local IFS="-"
    local content=($1)
    local host=${content[1]}
    local port=${content[2]}
    IFS=" "
    ${SUDO} "ssh -S ${TUNNEL}/${1} -O exit root@${host}.netact.nsn-rdnet.net" 2>>/dev/null
    local ret=$?
    if [[ ${ret} -eq 0 ]]; then
        echo "Tunnel: tunnel-$host-$port closed"
    fi
    return ${ret}
}

function closeTunnel() {
    local IFS="-";
    local content=($1);
    local host=${content[1]};
    local port=${content[2]};
    ssh -S ${TUNNEL}/"${1}" -O exit root@"${host}".netact.nsn-rdnet.net 2>>/dev/null;
    local ret=$?
    if [[ ${ret} -eq 0 ]]; then
        echo "Tunnel: tunnel-$host-$port closed";
    fi
    return ${ret}
}

function usage() {
    cat << endl
This script is used to setup the ssh tunnel ntcapp swm TA
Syntax:
    $0
        start [lab id] <--monitor|--ntcapp>: start the ssh tunnel between local laptop and clonepool for specific purpose
        stop: clear all existing ssh tunnel
        [-h|--help]: print the help message
Example:
    $0 start 2564: create 3 ssh tunnel for clab2564
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
