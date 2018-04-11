#!/usr/bin/expect

set timeout 20

set ip [lindex $argv 0]

set user [lindex $argv 1]

set password [lindex $argv 2]

set prompt ":|#|\\\$"

spawn ssh -oStrictHostKeyChecking=no -oCheckHostIP=no "$user\@$ip"
expect "password:"
send "$password\r";
interact -o -nobuffer -re $prompt return
send "exit\r";
interact

