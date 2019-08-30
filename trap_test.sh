#!/bin/bash
trap post EXIT

echo "do some business logic"

function post() {
    echo "enter post function"
	echo "do something";
    echo "out post function"
}




