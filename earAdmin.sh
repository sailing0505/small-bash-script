#!/bin/bash

function envSetup() {
    CPFPYLIBDIR="/opt/cpf/pylib/bin/";
    GETMODULES_DEPENDENCY=${GETMODULES_DEPENDENCY:-${CPFPYLIBDIR}/getMapModulesToServer.sh}
    WSADMIN_CMD="/opt/WebSphere/AppServer/bin/wsadmin.sh -lang jython"
}

function fail() {
    echo "`date` [ERROR] : $1";
    exit 1;
}

function log() {
    echo "`date` [LOG] : $1";
}

function deployEar() {
    local earPath="$1";
    local appName="$2";
    local clusterName="$3";
    
    local modulesMap="$(${GETMODULES_DEPENDENCY} ${clusterName})" || fail "can not compute modules to server map for cluster ${clusterName}: ${modulesMap}";
    log "deploy ${earPath} : ${appName} to ${clusterName} start";
    ${WSADMIN_CMD} -c "AdminApp.install('${earPath}', '[ -nopreCompileJSPs -distributeApp -nouseMetaDataFromBinary -nodeployejb -appname ${appName} -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema -MapModulesToServers [[.* .*,.* ${modulesMap} ]] -MapWebModToVH [[.* .*,.* default_host ]]]' )" || fail "install ${earPath}:${appName} failed";
}

function syncWas() {
    log "sync was node";
    ${WSADMIN_CMD} -c "AdminConfig.save()" -c "AdminControl.invoke('WebSphere:name=DeploymentManager,process=dmgr,platform=common,node=dmgr,diagnosticProvider=true,version=8.5.5.10,type=DeploymentManager,mbeanIdentifier=DeploymentManager,cell=SOL,spec=1.0', 'multiSync', '[false]', '[java.lang.Boolean]')" || fail "sync operation failed";
}

function undeployEar() {
    local appName="$1";
    log "undeploy $appName by wsadmin script";
    ${WSADMIN_CMD} -c "AdminApp.uninstall('${appName}')" -c "AdminApp.list()" || fail "undeployEar $appName failed";
}

function usage() {
    cat << endl
This script is used to deploy and undeply WAS application, it is only used by test driver
Syntax:
$0
    [-h|--help] print help message
    [-i|-deploy] <path of ear file> <application name> <cluster name>
    [-r|--undeploy] <application name>
    [-s|--sync]
Example:
    1. deploy SampleSWMCallBackApp.ear to IntgCluster
    ./earAdmin.sh -i /var/tmp/SampleSWMCallBackApp.ear AP_Sample_SWM_CB_APP IntgCluster
    2. undeploy SampleSWMCallBackApp.ear
    ./earAdmin.sh -r AP_Sample_SWM_CB_APP
    3. sync was cluster
    ./earAdmin.sh -s
endl
}

function Main() {
    while [[ -n "$1" ]]; do
        case $1 in
            -h|--help)
                usage;
                exit 0;
                ;;
            -i|-deploy) shift
                envSetup;
                deployEar $@;
                shift;
                shift;
                shift;
                ;;
            -r|--undeploy) shift
                envSetup;
                undeployEar $@;
                shift;
                ;;
            -s|--sync) shift
                envSetup;
                syncWas;
                ;;
            *)
                echo "invalid input";
                exit 1;
        esac
    done
}

Main $@;