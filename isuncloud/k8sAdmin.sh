#!/usr/bin/env bash
# Copyright (C) 2019 Jason Wu <wuhanghai@gmail.com>
#
# This file is part of k8sAdmin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



function usage() {
    cat << endl
This tool is used to enable and disable the isuncloud service for user in k8s cluster

Syntax:
$(basename $0)
    [enable] <userId> : create a isuncloud service for specific userId
    [disable]  <userId> : delete a isuncloud service for specific userId
    [list] <userId>: list all or specific active user information
    [update] <image>: update the isuncloud image version
Example:
    [root@k8s-master ~]# $(basename $0) enable userid001
    creat isuncloud service successful. userid=userid001 port=10034


endl
}

function checkService() {
    return 0
}

function getId() {
    if [ -z "${1}" ]; then
        return 1;
    fi
    if [ ${SECURITY} == "TRUE" ]; then
        echo "$1"|md5sum -b|awk -F" " {'print $1'}
    else
        echo $1
    fi
    return 0
}


function validateId() {
    return 0;
}

function deleteDeployment() {
    local label=$1
    if execute_backend_function delete $label; then
        rm -f "${DEPLOY_DIR}/isuncloud-${label}.yaml"
        echo "isuncloud service is deleted"
    fi
}

function queryDeployment() {
    echo "query deployment"
}

function log() {
    message=$2;
    logfile="${LOGDIR}/run.log"
    echo "$(date '+%Y-%m-%dT%H:%M:%S.%3N%z'): $message" >> ${logfile};
}

function _createDeployment() {
    local id=$1;
    local deployment="${DEPLOY_DIR}/isuncloud-${id}.yaml"
    if [[ -e ${deployment} ]]; then
        echo "service already created for user: ${id}"
        exit 1;
    fi
    log "create deployment for user: ${id}"
    cat << endl >> ${DEPLOY_DIR}/isuncloud-${id}.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: isuncloud-${id}
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: isuncloud-${id}
  template:
    metadata:
      labels:
        app: isuncloud-${id}
    spec:
      containers:
      - image: ${IMAGE}
        imagePullPolicy: Always
        name: isuncloud
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: isuncloud-${id}
  namespace: default
  labels:
    app: isuncloud-${id}
spec:
  selector:
    app: isuncloud-${id}
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 9000
endl
    execute_backend_function create ${id}
}

function execute_backend_function() {
    local exec_func="${METHOD}_$1"
    if declare -F "${exec_func}" > /dev/null; then
        ${exec_func} $2;
    fi
}

function _getPort() {
    local label=isuncloud-$1
    local port=$(execute_backend_function getport $label)
    if [ $? -eq 0 ]; then
        echo ${port}
    fi
}

function list() {
    # set -x
    if [ $# -lt 1 ]; then
        echo list all the deployments:

        echo -e "USER    PORT"
        for i in $(ls ${DEPLOY_DIR} 2>> /dev/null); do 
            local label=${i%.yaml}
            local id=${label#isuncloud-}
            local port=$(_getPort $id)
            echo -e "${id}    ${port}"
        done
    else
        local id=$(getId $1)
        local label="isuncloud-${id}"
        if ls ${DEPLOY_DIR}/${label}.yaml ; then
            #the user is exist
            local port=$(_getPort ${id})
            echo -e "${id}\t\t\t${port}"
        else
            echo "given user: $1 is not exit"
            exit 1
        fi
    fi
}

function disable() {
    local id=$(getId $1)
    validateId ${id}
    deleteDeployment ${id}
    if checkService ${id}; then
        echo "delete isuncloud service successful. userid=${id}"
    fi
}

function enable() {
    local id=$(getId $1);
    validateId $id;
    _createDeployment $id;
    local port=$(_getPort $id);
    if checkService $id; then
        echo "create isuncloud service successful. userid=${id} port=${port}"
    fi
}

function parseArg() {
    # set -x
    if [[ $# == 0 ]]; then
        usage
        exit 1
    fi
    while [[ -n ${1} ]]; do
        case ${1} in
            "-h" | "--help" )
                usage
                exit 0
                ;;
            enable ) shift
                enable $@
                exit $?
                ;;
            disable ) shift
                disable $@
                exit $?
                ;;
            "list" ) shift
                list $@
                exit $?
                ;;
            "update" ) shift
                update $@
                exit $?
                ;;
            "*" )
                usage
                exit 1
                ;;
        esac
    done
}

function load_config() {
    if [ -e ${ROOT}/tool.cfg ]; then
        while read LINE ;do
            LINE=$(echo $LINE|sed 's/^[\t[:space:]]*#.*$//g');
            if [ ! -z "${LINE}" ]; then
                local SAV=${IFS}
                local IFS="=";
                local content=(${LINE})
                local k=${content[0]}
                local v=${content[1]}
                local IFS=${SAV}
                export ${k}=${v}
            fi
        done < ${ROOT}/tool.cfg
    else
        echo "Error: config file ${ROOT}/tool.cfg doesn't exist "
        exit 1
    fi
}

function init() {
    ABS=$(readlink -f $0)
    ROOT=$(dirname ${ABS})
    DEPLOY_DIR="${ROOT}/deployments"
    LOGDIR="${ROOT}/log"
    mkdir -p ${DEPLOY_DIR};
    mkdir -p ${LOGDIR};

    load_config
    # METHOD=kubectl
    # IMAGE="192.168.1.58:5000/isuncloud:master"
    # SECURITY=false


    . ${ROOT}/api.sh
    return 0;
}


function main() {
    init ;
    parseArg $@;
}

main $@