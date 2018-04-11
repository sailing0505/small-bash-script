#!/bin/bash
#set -x
function log() {
	LEVEL=$1;
	MESSAGE=$2;
	echo "`date '+%Y-%m-%dT%H:%M:%S.%3N%z'` | printLog | $LEVEL | $0 | $MESSAGE";
}

function info() {
	log "INFO" "$1";
}

function severe() {
	log "SEVERE" $1;
}

function warning() {
	log "WARNING" $1;
}

function finer() {
	log "FINER" "$1";
}

function finest() {
	log "FINEST" "$1";
}

#main#################
info "this is test message"