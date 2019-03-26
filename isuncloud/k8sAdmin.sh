#!/usr/bin/env bash

. k8sconfig.sh
function help() {
    cat << endl
This script is used to start and stop the ks8 pod for assigned user
Syntax:
$(basename $0)
    [start] [userId] : start a k8s service for specific userId
    [stop]  [userId] : stop a k8s service for specific userId
    [list] : list mapping for current k8s service and userId
endl
}

function start() {
    echo "k8s service is started"
}

function deleteDeployment() {
    echo "deployment is deleted"
}

function queryDeployment() {
    echo "query deployment"
}

function createDeploymentFile() {
    local appName="test123"
    cat << endl >> deploy.json
{
    "apiVersion": "apps/v1beta1",
    "kind": "Deployment",
    "metadata": {
        "name": "${appName}"
    },
    "spec": {
        "replicas": 3,
        "selector": {
            "matchLabels": {
                "app": "nginx"
            }
        },
        "template": {
            "metadata": {
                "labels": {
                    "app": "nginx"
                }
            },
            "spec": {
                "containers": [
                    {
                        "name": "nginx",
                        "image": "nginx:1.12",
                        "ports": [
                            {
                                "containerPort": 80
                            }
                        ]
                    }
                ]
            }
        }
    }
}
endl
}

function stop() {
    echo "k8s service is stopped"
}

function main() {
    if [[ $# == 0 ]]; then
        help
        exit 1
    fi
    while [[ -n ${1} ]]; do
        case ${1} in
            -h | --help )
                help
                exit 0
                ;;
            start ) shift
                start $@
                exit $?
                ;;
            stop ) shift
                stop $@
                exit $?
                ;;
            * )
                help
                exit 1
                ;;
        esac
    done
}

main $@