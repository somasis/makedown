#!/bin/sh
#
# find.sh
# part of makedown, a build system for making markdown websites.
# https://github.com/somasis/makedown
#
# uses `find` to get a list of files matching <type>, with some exclusions.
# also, gets a relative pathname.
#

if [ "${1}" = --absolute ];then
    absolute=true
    srcdir_count=0
    shift
else
    absolute=false
fi
 
type="${1}"; shift
[ -n "${SRCDIR}" ] || exit 127
[ -n "${MAKEDOWN}" ] || exit 127
[ -n "${WORK}" ] || exit 127

[ "${absolute}" = true ] || srcdir_count=$(( $(printf '%s' "${SRCDIR}"/ | tr -cd '/' | wc -c) + 1 ))

cd "${SRCDIR}"

_find() {
    path="$1"; shift
    if [ "${absolute}" = true ];then
        find "$path" \
            \! \( -name ".*" \) \
            \! \( -path "${SRCDIR}/*.*/*" -prune \) \
            \! \( -path "${MAKEDOWN}/*" -prune \) \
            \! \( -path "${WORK}/*" -prune \) \
            "$@"
    else
        find "$path" \
            \! \( -name ".*" \) \
            \! \( -path "${SRCDIR}/*.*/*" -prune \) \
            \! \( -path "${MAKEDOWN}/*" -prune \) \
            \! \( -path "${WORK}/*" -prune \) \
            "$@" | cut -d'/' -f${srcdir_count}-
    fi
}

case "${type}" in
    pages)
        _find "${SRCDIR}" \
            \( -type f -o -type l -a -xtype f \) \
            -name '*.md' \
            "$@"
    ;;
    script)
        _find "${SRCDIR}" \
            \( -type f -o -type l -a -xtype f \) \
            -name '*.js' \
            "$@"
    ;;
    style)
        _find "${SRCDIR}" \
            \( -type f -o -type l -a -xtype f \) \
            -name '*.css' \
            "$@"
    ;;
    aux)
        _find "${SRCDIR}" \
            \( -type f -o -type l -a -xtype f \) \
            \! \( \
                -name '*.md' \
                -o -name '*.js' \
                -o -name '*.css' \
                -o -name '*.template' \
                -o -name 'makedown.conf' \
                -o -name 'Makefile' \
            \) \
            "$@"
    ;;
esac


