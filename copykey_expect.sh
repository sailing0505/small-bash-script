#!/usr/bin/expect

set timeout 20

set login [lindex $argv 0]

set key [lindex $argv 1]

set prompt ":|#|\\\$"

spawn ssh-copy-id -oStrictHostKeyChecking=no -oCheckHostIP=no -i "${key}" "$login"

expect "password:"

send "arthur\r";

interact

