#!/bin/sh
#
# genwikilinks.sh
# part of makedown, a build system for making markdown websites.
# https://github.com/somasis/makedown
#
# generates a list of links to each page, based on directory structure, as well 
# as each header in each page. idea being that you can then insert them into the 
# end of markdown, before rendering to HTML, and thus get a sort of wiki-style 
# functionality of easy page linking.
#
# example output:
#     [Alternatives]: /alternatives.html
#     [Alternatives#Alternatives]: /alternatives.html#Alternatives
#     [Alternatives#Alternative Libraries and Programs]: /alternatives.html#Alternative-Libraries-and-Programs
#     [Alternatives#Compression/Decompression]: /alternatives.html#Compression/Decompression
#

set -e

gen() {
    pwd_escaped=$(printf '%s' "${PWD}" | sed 's/[\/&]/\\&/g')
    for f in "$@";do
        if [ $(sed '1!d' "${f}" | grep -c '^# ') -eq 1 ];then
            title=$(sed '1!d;s/^# //' "${f}")
            title_esc=$(printf '%s' "${title}" | sed 's/\//\\\//g')
            f_full=$(readlink -f "${f}" | sed "s/${pwd_escaped}//;s/\.md$/\.html/")
            f_esc=$(printf '%s' "${f_full}" | sed 's/\//\\\//g')
            printf "[%s]: %s\n" "${title}" "${f_full}"
            markdown -f toc,html,html5anchor -T "${f}" | \
                sed -r \
                    -e "/<a name=(.*)\n/N" \
                    -e "/^(<h[1-6]>|<a name=)/!d" \
                    -e "N; s/\n//" \
                    -e "s/<a name=\"(.*)\"><\/a><h[1-6]>(.*)<\/h[1-6]>/[${title_esc}#\2]: ${f_esc}#\1/"
        fi
    done
}

if [ "${1}" = --gen ];then
    shift
    # redirect to file because else the directory cutting in find.sh eats gen's output
    gen "$@" >> "${work}"/.genwikilinks_tmp
    exit $?
fi

self=$(readlink -f "${0}")
export srcdir="${1}"
export makedown="${2}"
export work="${3}"
export output="${4}"

cd "${srcdir}"

rm -f "${work}"/.genwikilinks_tmp
"${makedown}"/find.sh pages "${srcdir}" "${makedown}" "${work}" -exec "${self}" --gen {} \;
grep '^\[' "${work}"/.genwikilinks_tmp > "${output}"
rm -f "${work}"/.genwikilinks_tmp
