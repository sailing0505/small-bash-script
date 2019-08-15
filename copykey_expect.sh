#!/usr/bin/expect

set timeout 20

set login [lindex $argv 0]

set prompt ":|#|\\\$"

spawn ssh-copy-id -oStrictHostKeyChecking=no -oCheckHostIP=no "$login"

expect "password:"

send "arthur\r";

interact

