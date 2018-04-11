#!/bin/bash

. /opt/cpf/bin/cpf_logging_helper.sh

cpf_note "This is note message";
cpf_debug "This is debug message";
cpf_warning "This is warning message";
cpf_error "This is error message";

echo "disable log dump";
cpf_disable_dump;
cpf_dump_log;
echo "enable log dump"
cpf_enable_dump;
cpf_dump_log;