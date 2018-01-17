#!/bin/bash
# bash completion file for symptomcollector commands
#
# This script provides completion of symptom collector command:
# 
#
# To enable the completions either:
#  - place this file in /etc/bash_completion.d
#  or
#  - copy this file to e.g. ~/.symptomcollector-completion.sh and add the line
#    below to your .bashrc after bash completion features are loaded
#    . ~/.symptomcollector-completion.sh
#
#
# --- helper functions -------------------------------------------------------

_sc_collect_flag() {
    if [[ $(echo "${words[*]}"|grep "system-info"|grep "log-level") ]]; then
        echo ""
    elif [[ $(echo "${words[*]}"|grep "system-info") ]]; then
        echo "--log-level"
    elif [[ $(echo "${words[*]}"|grep "log-level") ]]; then
        echo "system-info"
    else
        echo "${collect_flags[*]}"
    fi
}

_symptomcollector_component() {
    local _components=(adaptation-deployment-suite adaptation-manager aom audit-trail backuptool cm common-mediation dynamic-adaptation filedc-fileactivation fm-ard fm-defra fm-gep fm-mofd fm-mond isdk-corba isdk-ftp isdk-snmpfm isdk-snmppm license-manager ltea-snmp-cm-com-mediation ltea-snmp-cm-platform ltea-snmp-fm ltea-snmp-pm ltea-snmp-swm ltea-snmp-um mediation-dispatcher mediation-fns mediation-mml mediation-mus mediation-nwi3 mediation-nx2s mediation-q3 mediation-sam mediation-saucnt mediation-scli mediation-xoh msc-pool-minitor nbi-3gpp-fm nbi-3gpp-pm nbi-bulkcm nbi-inventory nbi-pm-filemerger nbi-snmp ne-integration-wizard notification-dispatcher object-information-browser operating-documentation optimizer pm-alarm-integration pm-deployment-controller pm-frontend pm-load pm-object-history pm-smi-dispatcher pm-topology-replication pm-workingset-synchronizer security-certificates-generate security-certificates-management security-cnum security-neac-provisioning security-ne-certificates-management security-nodemanager-integration security-password-tool security-permission-management security-session-management security-system-credential-access security-tmf615 security-user-management service-cmwas service-database service-dirsrv service-dns service-fmwas service-ftp service-hpsim service-intgwas service-itsmwas service-jacorb service-load-balancing service-nasda service-nfs service-ntp service-omagent service-osi service-pmwas service-preference service-scheduler service-scp-sftp-ssh service-servicemonitor service-socks service-syswas service-vcenterplg service-vcenterselfmon service-vmanager software-asset-monitoring software-manager startpage system-info trace-viewer)        
    case "${prev}" in
        --component|-c )
            if [[ "${cur}" == *,* ]]; then
                #support assign multiple scenario with ','
                local realcur prefix prefix_parts
                realcur=${cur##*,}
                prefix=${cur%,*}
                #remove the duplicate options with remove the existing option from _components array
                #IFS is use to splite the prefix with comma(,) into array
                IFS=","
                prefix_parts=(${prefix})
                unset IFS
                for item in ${prefix_parts[*]}; do
                    _components=(${_components[@]#${item}})
                done
                COMPREPLY=( "${prefix},"$(compgen -W "${_components[*]}" -- ${realcur}))
            else
                COMPREPLY=( $(compgen -W "${_components[*]}" -- ${cur}))
            fi
            ;;
        --log-level )
            COMPREPLY=($(compgen -W "all" -- ${cur})) 
            ;;
        * )
            COMPREPLY=( $(compgen -W "$(_sc_collect_flag)" -- ${cur}))    
            ;;
    esac
}



_symptomcollector_scenario() {
    local _scenarios=(daptation-deployment ulkcm-3gpp-corba-nbi m-3gpp-corba-nbi m-data-flow m-snmp-nbi ml-aom ml-atl ml-backup-restore ml-cm mml-element-management mml-lic mml-slt mml-swm mml-tm ne3s-snmp-fm ne3s-snmp-pm-aom ne3s-ws-atl ne3s-ws-cm ne3s-ws-fm ne3s-ws-pm-aom ne3s-ws-swm ne3s-ws-um nwi3-atl nwi3-certificate-management nwi3-cm nwi3-fm nwi3-lic nwi3-pm-aom nwi3-slt nwi3-swm nwi3-um nx2s-integration-data-management pm-3gpp-xml-nbi pm-data-flow q3-atl q3-certificate-management q3-cm q3-element-management q3-fm q3-lic q3-network-element-user-managerment q3-pm-aom q3-slt q3-swm q3-tm snmp-bcm snmp-fm snmp-pm was xoh-fm xoh-pm xoh-slt)

    case "${prev}" in
        --scenario )
            if [[ "${cur}" == *,* ]]; then 
                #support assign multiple scenario with ','
                local realcur prefix prefix_parts
                realcur=${cur##*,}
                prefix=${cur%,*}
                #in order to remove the duplicate left option
                IFS=","
                prefix_parts=(${prefix})
                unset IFS
                for item in ${prefix_parts[*]}; do
                    _components=(${_scenarios[@]#${item}})
                done
                COMPREPLY=( "${prefix},"$(compgen -W "${_scenarios[*]}" -- ${realcur}))
            else
                COMPREPLY=( $(compgen -W "${_scenarios[*]}" -- ${cur}))
            fi
            ;;
        --log-level )
            COMPREPLY=($(compgen -W "all" -- ${cur})) 
            ;;
        * )
            COMPREPLY=( $(compgen -W "$(_sc_collect_flag)" -- ${cur}))    
            ;;
    esac
}

_symptomcollector_list() {
    case ${prev} in
        --print-description )
            COMPREPLY=()
            ;;
        --* )
            COMPREPLY=( $(compgen -W "${list_flags[*]}" ${cur}))
            ;;
    esac
}

_symptomcollector_symptomcollector() {
    if [[ "${top_flag[*]}" =~ ${prev} ]]; then
        COMPREPLY=()
    else
        COMPREPLY=($(compgen -W "${top_flag[*]} ${commands[*]}" -- "${cur}"))
    fi
}

_symptomcollector () {
    COMPREPLY=()
    local collect_flags=(--log-level --system-info)
    local list_flags=(--print-description)
    local top_flag=(-h --help --list-components --list-scenarios -m --man)
    local commands=(-c --component --list-components --list-scenarios --scenario)

    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword
    local i
    local command="symptomcollector" #the default command is "symptom-collector"

    for (( i=1; i < ${cword}; ++i )); do
        local word=${words[i]}
        case ${word} in
            -c | --component )
                command="component"
                ;;
            --scenario )
                command="scenario"
                ;;
            --list* )
                command="list"
                ;;
        esac
    done

    local completion_func=_symptomcollector_"${command//-/_}"
    if declare -F "${completion_func}" > /dev/null; then
        ${completion_func}
    fi

    return 0
}

complete -F _symptomcollector symptomcollector