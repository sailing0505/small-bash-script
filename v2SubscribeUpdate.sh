#!/bin/bash

DAWANG="https://dawangidc.net/modules/servers/V2raySocks/osubscribe.php?sid=17257&token=SlZ583zS9q2I"
store="raw.json"
set -x
function checkResult() {
    if [ $1 -ne 0 ];then
        echo "$2"
        exit $1
    fi
}

function download() {
    local enc=$(curl -s --noproxy -L "${DAWANG}")
    echo $enc|base64 -d 2>/dev/null > vmess.tmp
    checkResult $? "download servers config from IDC failed"
    rm -f ${store}
    while read s;do
        s=$(echo ${s#vmess://}|base64 -d)
        echo ${s}>>${store}
    done < vmess.tmp
    echo ${store}
}

function configServer() {
    local host=$1
    local id=$2
    local port=$3
    local ps=$4
    local level=$5
    cat << endl
    {
      "protocol": "vmess",
      "config": {
        "inbounds": [
          {
            "port": 1082,
            "listen": "127.0.0.1",
            "protocol": "socks",
            "settings": { "auth": "noauth", "udp": false, "accounts": [] },
            "streamSettings": {},
            "sniffing": { "enabled": true, "destOverride": ["http", "tls"] }
          },
          {
            "port": 1081,
            "listen": "127.0.0.1",
            "protocol": "http",
            "settings": {"userLevel": 8},
            "tag": "http"
          }
        ],
        "outbounds": [
          {
            "sendThrough": "0.0.0.0",
            "protocol": "vmess",
            "settings": {
              "vnext": [
                {
                  "address": "${host}",
                  "port": ${port},
                  "users": [
                    {
                      "id": "${id}",
                      "alterId": 0,
                      "security": "none",
                      "level": ${level}
                    }
                  ]
                }
              ]
          },
          "streamSettings": {
            "network": "ws",
            "security": "tls",
            "tlssettings": { "allowInsecure": true, "serverName": "" },
            "wssettings": {
              "connectionReuse": true,
              "headers": { "Host": "" },
              "path": ""
            }
          },
          "tag": "proxy"
          }
        ]
      },
      "ps": "${ps}",
      "host": "${host}"
    }
endl
}

function getHost() {
    echo $1|awk -F',' '{print $1}'|awk -F':' '{print $2}'|xargs echo
}

function getId() {
    echo $1|awk -F',' '{print $3}'|awk -F':' '{print $2}'|xargs echo
}

function getPort() {
    echo $1|awk -F',' '{print $6}'|awk -F':' '{print $2}'|xargs echo
}

function getPs() {
    echo $1|awk -F',' '{print $7}'|awk -F':' '{print $2}'|xargs echo
}

function getLevel() {
    echo $1|awk -F',' '{print $9}'|awk -F':' '{print $2}'|xargs echo
}

function writeHead() {
    cat <<endl
{
  "servers_subscribe": [
endl
}

function writeTail() {
    cat <<endl
  ],
  "servers_original": []
}
endl
}

function parse() {
    local file=${store}
    writeHead
    local lines=$(wc -l ${file}|awk '{print $1}')
    local Lines=0
    while read line; do
        (( Lines++ ))
        local host=$(getHost $line)
        local id=$(getId $line)
        local port=$(getPort $line)
        local ps=$(getPs $line)
        local level=$(getLevel $line)
        configServer $host $id $port $ps $level
        if [[ $Lines -lt $lines ]]; then
            echo "    ,"
        fi
        # echo  ${server}
    done < ${file}
    writeTail
}

function main() {
    download
    parse > servers.json
}



main