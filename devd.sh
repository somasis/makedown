#!/bin/sh
#
# devd.sh
# part of makedown, a build system for making markdown websites.
# https://github.com/somasis/makedown
#
# starts up an instance of the devd server, then gets the address and PID of it,
# so that it can be killed once it is no longer needed.
#
 
set -x
nohup devd -t "$1" > "$1"/devd.log &
echo $! > "$1"/devd.pid
sleep 1
sed -r '/Listening/!d;s/Listening on (.+) .*/\1/' "$1"/devd.log > "$1"/devd.address
