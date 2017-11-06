#!/bin/sh
#
# linkchecker.sh
# part of makedown, a build system for making markdown websites.
# https://github.com/somasis/makedown
#
# runs linkchecker on the devd server started prior to running
# the script.
#

set -x
linkchecker --check-extern --no-robots "$2" &
linkchecker_pid=$!
trap 'kill $linkchecker_pid' SIGINT
wait
linkchecker_exit=$?
trap - SIGINT

kill $(cat "$1"/devd.pid)
rm "$1"/devd.pid "$1"/devd.address
if [ $linkchecker_exit -ne 0 ];then
    exit 1
fi
