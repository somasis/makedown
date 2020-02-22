#!/bin/sh
#
# makedown.sh
# part of makedown, a build system for making markdown websites.
# https://github.com/somasis/makedown
#
# create nice HTML with `markdown` and add some templating functionality.
#

set -e

stderr() {
    printf '%s: %s\n' "${0##*/}" "$*" >&2
}

edo() {
    stderr "$*"
    "$@"
}

die() {
    stderr "$1"
    exit $2
}

help() {
    printf '%s\n\n' \
        "usage: ${0##*/} [--help] [--flags <flags>] [--name <site name>] [--append <file>] [--print-template] [--print-title] [--print-description] <input>"
    printf '    %-10s %s\n' \
        "--flags <flag1,flag2>" "This argument is passed to \`markdown\`. Comma separated." \
        "--print-template"      "Print the template that would be used for generating <input>'s HTML." \
        "--print-title"         "Print <input>'s title." \
        "--print-description"   "Print <input>'s description." \
        "--append <file>"       "Markdown formatted file to append to the input before converting to HTML." \
        "--name <site name>"    "Set the site name. Used for setting the page titles." \
        "--help"                "This."
}

template_only=false
title_only=false
description_only=false

if [ "${1}" = "--help" ] || [ $# -lt 1 ];then
    help
    exit 255
fi

while [ $# -ne 1 ];do
    case "${1}" in
        --flags)
            flags="${2}"
            shift
        ;;
        --append)
            append="${2}"
            shift
        ;;
        --name)
            site_name="${2}"
            shift
        ;;
        --print-template)
            template_only=true
        ;;
        --print-title)
            title_only=true
        ;;
        --print-description)
            description_only=true
        ;;
    esac
    shift
done

input="${1}"

if [ -z "${input}" ];then
    help
    exit 255
elif ! [ -r "${input}" ];then
    die "Can't read \"${input}\"." 13
fi

markdown_flags="-f toc,html5anchor${flags:+,${flags}}"

temp_recurse() {
    # recurse to find parent templates
    base=$(basename "${input}" .md)
    old_pwd="${PWD}"
    cd "${dir}"
    until [ "${PWD}" = / ];do
        for f in "${PWD}"/${base}.template "${PWD}"/page.template;do
            [ -e "${f}" ] && printf '%s' "${f}" && return 0
        done
        cd ..
    done
    cd "${old_pwd}"
    stderr "couldn't find a template to use for \"${input}\"."
    return 1
}

finish() {
    rm -f "${body}" "${bodymd}" "${html}" "${html2}" "${toc}" "${temp}" "${temp2}"
}

trap finish EXIT

dir=$(readlink -f "${input}")
dir=${dir%/*}

temp=$(temp_recurse "${input}")

if [ "${template_only}" = true ];then
    printf '%s\n' "${temp}"
    temp=
    exit 0
fi

temp2=$(mktemp)
stderr "cat \"${temp}\" > \"${temp2}\""
cat "${temp}" > "${temp2}"
temp="${temp2}";temp2=$(mktemp)

# Remove top markdown header; just the body is needed
body=$(mktemp)
bodymd=$(mktemp)
html=$(mktemp)
html2=$(mktemp)
toc=$(mktemp)

has_title=false
has_description=false
# # title\n
if [ $(sed -n '1p' "${input}" | grep -Ec '^# ') -eq 1 ] && \
   [ $(sed -n '2p' "${input}" | grep -Ec '^## ') -lt 1 ];then
    title=$(sed '1!d;s/^# //' "${input}")
    description=
    has_title=true
    has_description=false
    stderr "${input} has a title and no description"
elif [ $(sed -n '1p;2p' "${input}" | grep -Ec '^#{1,2} ') -lt 2 ];then
    stderr "error: \"${input}\" should contain a title and description in the format of:"
    stderr "# Title"
    stderr "## Description."
    stderr "as the first two lines of the file."
    exit 5
# # title\n## description\n
else
    title=$(sed '1!d;s/^# //' "${input}")
    description=$(sed '2!d;s/^## //' "${input}")
    has_title=true
    has_description=true
fi

if [ "${title_only}" = true ];then
    "${has_title}" && printf '%s\n' "${title}" && exit
    exit 1
elif [ "${description_only}" = true ];then
    "${has_description}" && printf '%s\n' "${description}" && exit
    exit 1
fi


title_unprefixed="${title}"

# <site name> - <page title>, unless site name isn't set
if [ -n "${site_name}" ] && [ "${title}" != "${site_name}" ];then
    title="${site_name} - ${title}"
fi

case ${has_title}${has_description} in
    truetrue)
        stderr "sed '1d;2d' \"${input}\" > \"${bodymd}\""
        sed '1d;2d' "${input}" > "${bodymd}"
    ;;
    truefalse)
        stderr "sed '1d' \"${input}\" > \"${bodymd}\""
        sed '1d' "${input}" > "${bodymd}"
    ;;
    *)
        exit 6
    ;;
esac

if [ -n "${append}" ];then
    stderr "cat \"${append}\" >> \"${bodymd}\""
    cat "${append}" >> "${bodymd}"
fi

# FIXME: this would be better done in discount itself.
# sed generates two anchors, one with dashes and one with underscores; however, it makes incorrect changes
# with anchors that contain dashes.
# avoids breaking mediawiki style anchor links.
stderr "markdown ${markdown_flags} \"${bodymd}\" | sed -E '/^<a name=\".+\"><\/a>$/ { p; s/-/_/g; }' > \"${body}\""
markdown ${markdown_flags} "${bodymd}" | sed -E '/^<a name=".+"><\/a>$/ { p; s/-/_/g; }' > "${body}"

stderr "markdown ${markdown_flags} -T -n \"${bodymd}\" > \"${toc}\""
markdown ${markdown_flags} -T -n "${bodymd}" > "${toc}"

# get metadata about input file
if git rev-parse HEAD >/dev/null 2>&1 && git ls-files --error-unmatch "${input}" >/dev/null 2>&1;then
    tree_commit=$(git rev-parse HEAD)
    file_commit=$(git log --format='%H' -1 "${input}")
    author=$(git shortlog -ns "${input}" | sed 's/.*\t//;s/$/,/')
    if [ $(printf '%s\n' "${author}" | wc -l) -gt 10 ];then
        author=$(printf '%s\n' "${author}" | head -n 10)
        author=$(printf '%s\n' "${author}" "...")
    fi
    author=$(printf '%s\n' "${author}" | tr '\n' ' ' | sed -E 's/,? $//')
    date=$(git log --date='format:%Y-%m-%d' --format='%ad' -1 "${input}")
fi

markdown_version=$(markdown ${markdown_flags} -VV)

htmlescape() {
    printf '%s' "$@" | sed 's/</\&lt;/g;s/>/\&gt;/g;s/&/\&amp;/g'
}

# we can definitely make this a dynamic thing, it'll have to use eval, though.
tree_commit_escaped=$(htmlescape "$tree_commit")
file_commit_escaped=$(htmlescape "$file_commit")
site_name_escaped=$(htmlescape "$site_name")
title_escaped=$(htmlescape "$title")
title_unprefixed_escaped=$(htmlescape "$title_unprefixed")
description_escaped=$(htmlescape "$description")
author_escaped=$(htmlescape "$author")
date_escaped=$(htmlescape "$date")
markdown_version_escaped=$(htmlescape "${markdown_version}")

edo sed \
    -e "s|<?makedown tree_commit?>|${tree_commit}|g" \
    -e "s|<?makedown file_commit?>|${file_commit}|g" \
    -e "s|<?makedown site_name?>|${site_name}|g" \
    -e "s|<?makedown title?>|${title}|g" \
    -e "s|<?makedown title_unprefixed?>|${title_unprefixed}|g" \
    -e "s|<?makedown description?>|${description}|g" \
    -e "s|<?makedown author?>|${author}|g" \
    -e "s|<?makedown date?>|${date}|g" \
    -e "s|<?makedown version?>|${markdown_version}|g" \
    -e "s|<?makedown tree_commit_escaped?>|${tree_commit_escaped}|g" \
    -e "s|<?makedown file_commit_escaped?>|${file_commit_escaped}|g" \
    -e "s|<?makedown site_name_escaped?>|${site_name_escaped}|g" \
    -e "s|<?makedown title_escaped?>|${title_escaped}|g" \
    -e "s|<?makedown title_unprefixed_escaped?>|${title_unprefixed_escaped}|g" \
    -e "s|<?makedown description_escaped?>|${description_escaped}|g" \
    -e "s|<?makedown author_escaped?>|${author_escaped}|g" \
    -e "s|<?makedown date_escaped?>|${date_escaped}|g" \
    -e "s|<?makedown version_escaped?>|${markdown_version_escaped}|g" \
    "${temp}" > "${temp2}"
edo sed \
    "/<?makedown body?>/{
        r ${body}
        d
    }" "${temp2}" > "${html}"
edo sed \
    "/<?makedown toc?>/{
        r ${toc}
        d
    }" "${html}" > "${temp2}"

cat "${temp2}"
