#!/usr/bin/env bash
# Copyright (C) 2019 Jason Wu <wuhanghai@gmail.com>
#
# This file is part of k8sAdmin

function _checkService() {
    return 0
}

function _getId() {
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


function _validateId() {
    return 0;
}

function _deleteDeployment() {
    local label=$1
    if _runApi delete $label; then
        rm -f "${DEPLOY_DIR}/isuncloud-${label}.yaml"
        echo "isuncloud service is deleted"
    fi
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
apiVersion: apps/v1beta1
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
apiVersion: extensions/v1beta1
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
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: isuncloud-ingress-${id}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  labels:
    app: isuncloud-${id}
spec:
  rules:
  - host: ${id}.isuncloud.com
    http:
      paths:
      - backend:
          serviceName: isuncloud-${id}
          servicePort: 80
endl

    _runApi create ${id}
}

function _runApi() {
    local exec_func="${METHOD}_$1"
    if declare -F "${exec_func}" > /dev/null; then
        ${exec_func} $2;
    fi
}

function _getPort() {
    local label=isuncloud-$1
    local port=$(_runApi getport $label)
    if [ $? -eq 0 ]; then
        echo ${port}
    fi
}

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

function log() {
    message=$2;
    logfile="${LOGDIR}/run.log"
    echo "$(date '+%Y-%m-%dT%H:%M:%S.%3N%z'): $message" >> ${logfile};
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
        local id=$(_getId $1)
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
    return 0
}

function disable() {
    local id=$(_getId $1)
    _validateId ${id}
    _deleteDeployment ${id}
    if _checkService ${id}; then
        echo "delete isuncloud service successful. userid=${id}"
        return 0
    fi
}

function enable() {
    local id=$(_getId $1);
    _validateId $id;
    _createDeployment $id;
    local port=$(_getPort $id);
    if _checkService $id; then
        echo "create isuncloud service successful. userid=${id} port=${port} url=http://${id}.isuncloud.com"
        return 0;
    fi
}

function start() {
    local id=$(_getId $1)

    return 0;
}

function stop() {
    return 0;
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
            "enable" ) shift
                enable $@
                exit $?
                ;;
            "disable" ) shift
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
            "start" ) shift
                start $@
                exit $?
                ;;
            "stop" ) shift
                stop $@
                exit $?
                ;;
            * )
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
    export PATH="/opt/kubernetes/bin:$PATH"

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