#!/usr/bin/env bash

function read_args() {
    while [ ! -z $1 ]; do
        echo get para: $1;
        shift;
    done
}

read_args $@