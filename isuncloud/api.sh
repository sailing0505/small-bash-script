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
    local out=$(kubectl delete deployment,pod,service -l "app=${label}" 2>&1)
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
    echo "curl_create successful"
}

function curl_delete() {
    echo "curl_delete successful"
}

function curl_update() {
    echo "curl_update successful"
}

function curl_list() {
    echo "curl_list successful"
}