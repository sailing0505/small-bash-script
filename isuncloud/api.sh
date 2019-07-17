#!/usr/bin/env bash

function kubectl_create() {
    local file="${DEPLOY_DIR}/isuncloud-${1}.yaml"
    local out=$(kubectl create -f ${file} 2>&1)
    if [ $? -ne 0 ]; then
        echo "creaete service failed: $out"
        # log ${out}
        exit 1
    fi
    echo "kubectl_create successful"
}

function kubectl_delete() {
    local label="isuncloud-$1"
    local out=$(kubectl delete deployment,pod,service,ingress -l "app=${label}" 2>&1)
    if [ $? -ne 0 ]; then
        echo "delete service failed: $out"
        # log ${out}
        exit 1
    fi
    echo "kubectl_delete successful"
}

function kubectl_update() {
    echo "kubectl_update successful"
}

function kubectl_list() {
    local label="isuncloud-$1"
    local out=$(kubectl get deployment,pod,service -l "app=${label}" 2>&1)
    if [ $? -ne 0 ]; then
        echo "list service failed: $out"
        # log ${out}
        exit 1
    fi
    echo "kubectl list successful"
}

function kubectl_getport() {
    local label=$1
    local port=$(kubectl get service -l app=$label -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}')
    local ret=$?
    echo $port
    return $ret
}

function curl_create() {
    local file="${DEPLOY_DIR}/isuncloud-${1}.yaml"
    local dep=$(_getDeploymentPart ${file})
    local service=$(_getServicePart ${file})
    local ingress=$(_getIngressPart ${file})
    
    _curl_post $dep ${DEPURL}
    _curl_post $service ${SVCURL}
    _curl_post $ingress ${INGURL}

    # clean the part file
    rm -f ${dep} ${service} ${ingress}
    echo "curl_create successful"
}

function curl_delete() {
    local label="isuncloud-$1"
    local ingressLable="isuncloud-ingress-$1"
    local out=""
    out=$(_curl_delete "deployments" $label)
    out=$(_curl_delete "services" $label)
    out=$(_curl_delete "ingresses" $ingressLable)
    echo "curl_delete successful"
}

function curl_update() {
    echo "curl_update successful"
}

function curl_list() {
    echo "curl_list successful"
}

function curl_getport() {
    local label=$1
    local out=$(_curl_get ${label} SVCUR|grep NodePort|awk -F":" '{print $2}'|tr -d [:space:])
    local rt=$?
    echo ${out}
    return $rt;
}

function _getDeploymentPart() {
    local part=$(_getDepPartByName $1 "part00")
    if [ $? -eq 0 ]; then
        echo ${part};
        return 0;
    else
        echo "Error: get deployment content from file ${1} failed!"
        exit 1
    fi
}

function _getServicePart() {
    local part=$(_getDepPartByName $1 "part01")
    if [ $? -eq 0 ]; then
        echo ${part};
        return 0;
    else
        echo "Error: get service content  from file ${1} failed!"
        exit 1
    fi
}

function _getIngressPart() {
    local part=$(_getDepPartByName $1 "part02")
    if [ $? -eq 0 ]; then
        echo ${part};
        return 0;
    else
        echo "Error: get ingress content from file ${1} failed!"
        exit 1
    fi
}

function _getDepPartByName() {
    local name=$(basename ${1})
    local dir=$(dirname ${1})
    local part="${2}"
    local file="${dir}/${name%.yaml}-${part}.yaml"

    if [ ! -e ${file} ]; then
        $(csplit -s -f "${dir}/${name%.yaml}-part" "${1}" '/^---/' {*})
        local ret=$?
        echo "${file}"
        return $?
    else
        echo "${file}"
        return 0
    fi

}

# Description : send http post request to create the resource
# para1: deployment file
# para2: rest api url
# return: 0 (success)
#         1 (failed)
function _curl_post() {
    local file="${1}"
    local url=${2}
    curl -X POST \
        -H 'content-Type: application/yaml' \
        --data-binary @${file} \
        ${url}
    return $?
}

# Description : send http delete request to delete the resource
# para1: the name of resource
# para2: rest api url
# return: 0 (success)
#         1 (failed)
function _curl_delete() {
    local id=${1}
    local url=${2}
    curl -X DELETE \
        -H 'content-Type: application/yaml' \
        ${url}/${id}

    return $?
}

# Description : send http get request to query the resource
# para1: deployment file
# para2: rest api url
# return: 0 (success)
#         1 (failed)
function _curl_get() {
    local id=${1}
    local url=${2}
    curl -sX GET \
        ${url}/${id}
    return $?
}

