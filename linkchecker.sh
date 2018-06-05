#!/bin/sh
#
# linkchecker.sh
# part of makedown, a build system for making markdown websites.
# https://gitlab.com/somasis/makedown
#
# runs linkchecker on the devd server started prior to running
# the script.
#

[ -n "${WORK}" ] || exit 127

set -x
linkchecker --check-extern --no-robots "$@" $(cat "${WORK}"/devd.address) &
linkchecker_pid=$!
trap 'kill $linkchecker_pid' SIGINT
wait
linkchecker_exit=$?
trap - SIGINT

kill $(cat "${WORK}"/devd.pid)
rm "${WORK}"/devd.pid "${WORK}"/devd.address
if [ $linkchecker_exit -ne 0 ];then
    exit 1
fi
