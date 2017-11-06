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
srcdir=$(readlink -f "${1}"); shift
makedown=$(readlink -f "${1}"); shift
work=$(readlink -f "${1}"); shift

[ "${absolute}" = true ] || srcdir_count=$(( $(printf '%s' "${srcdir}"/ | tr -cd '/' | wc -c) + 1 ))

cd "${srcdir}"

_find() {
    path="$1"; shift
    if [ "${absolute}" = true ];then
        find "$path" \
            \! \( -name ".*" \) \
            \! \( -path "${srcdir}/*.*/*" -prune \) \
            \! \( -path "${makedown}/*" -prune \) \
            \! \( -path "${work}/*" -prune \) \
            "$@"
    else
        find "$path" \
            \! \( -name ".*" \) \
            \! \( -path "${srcdir}/*.*/*" -prune \) \
            \! \( -path "${makedown}/*" -prune \) \
            \! \( -path "${work}/*" -prune \) \
            "$@" | cut -d'/' -f${srcdir_count}-
    fi
}

case "${type}" in
    pages)
        _find "${srcdir}" \
            \( -type f -o -type l -a -xtype f \) \
            -name '*.md' \
            "$@"
    ;;
    script)
        _find "${srcdir}" \
            \( -type f -o -type l -a -xtype f \) \
            -name '*.js' \
            "$@"
    ;;
    style)
        _find "${srcdir}" \
            \( -type f -o -type l -a -xtype f \) \
            -name '*.css' \
            "$@"
    ;;
    aux)
        _find "${srcdir}" \
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


