#!/bin/sh
#
# devd.sh
# part of makedown, a build system for making markdown websites.
# https://gitlab.com/somasis/makedown
#
# starts up an instance of the devd server, then gets the address and PID of it,
# so that it can be killed once it is no longer needed.
#

[ -n "${WORK}" ] || exit 127

set -x
nohup devd "${@}" "${WORK}" > "${WORK}"/devd.log &
echo $! > "${WORK}"/devd.pid
sleep 1
sed -r '/Listening/!d;s/Listening on (.+) .*/\1/' "${WORK}"/devd.log > "${WORK}"/devd.address
