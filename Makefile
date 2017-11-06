#!/bin/make -f
#
# makedown - a build system for making markdown websites.
# https://github.com/somasis/makedown
#
# requirements:
#     discount `markdown` (http://www.pell.portland.or.us/~orc/Code/discount/)
#
# `lint` requirements:
#     markdownlint (https://github.com/markdownlint/markdownlint)
#
# `check-links` requirements:
#     devd (https://github.com/cortesi/devd)
#     linkchecker (https://wummel.github.io/linkchecker)
#
# `deploy` requirements:
#     rsync (https://rsync.samba.org/)
#
# `watch` requirements:
#     devd (https://github.com/cortesi/devd)
#     entr (http://entrproject.org/)
#

MAKEDOWN        := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))/makedown
SRCDIR          := $(abspath $(MAKEDOWN)/..)
IMAGE           ?= $(SRCDIR)/image
WORK            ?= $(SRCDIR)/work

ifneq "$(wildcard $(MAKEDOWN)/find.sh)" "$(MAKEDOWN)/find.sh"
    $(error Please don't try to run makedown from the directory of makedown's files)
endif

PAGES           = $(addprefix $(WORK)/,$(addsuffix .html,$(basename $(shell $(MAKEDOWN)/find.sh pages $(SRCDIR) $(MAKEDOWN) $(WORK)))))
STYLE           = $(addprefix $(WORK)/,$(shell $(MAKEDOWN)/find.sh style $(SRCDIR) $(MAKEDOWN) $(WORK)))
SCRIPT          = $(addprefix $(WORK)/,$(shell $(MAKEDOWN)/find.sh script $(SRCDIR) $(MAKEDOWN) $(WORK)))
AUX             = $(addprefix $(WORK)/,$(shell $(MAKEDOWN)/find.sh aux $(SRCDIR) $(MAKEDOWN) $(WORK)))

MARKDOWN_FLAGS  := alphalist,autolink,divquote,definitionlist,dldiscount,dlextra,emphasis,ext,fencedcode,footnotes,githubtags,html,image,latex,links,smarty,strict,strikethrough,style,superscript,tables,tabstop,urlencodedanchor

include $(SRCDIR)/makedown.conf

ifndef IMAGE
    $(error IMAGE should be set to a directory)
endif

ifndef WORK 
    $(error WORK should be set to a directory)
endif

ifndef WIKI_LINKS
    $(error WIKI_LINKS should be set to true or false)
endif

ifeq ($(WIKI_LINKS),true)
    WIKI_LINKS = $(WORK)/makedown_wiki_links.tmp
    WIKI_LINKS_ARG = --append $(WIKI_LINKS)
else
    ifeq ($(WIKI_LINKS),false)
        WIKI_LINKS =
    endif
endif

ifdef SITE_NAME
    SITE_NAME_ARG = --name "$(SITE_NAME)"
endif

all: $(PAGES) $(STYLE) $(SCRIPT) $(AUX)
clean:
	rm -f $(PAGES)
	rm -f $(STYLE)
	rm -f $(SCRIPT)
	rm -f $(AUX)
	rm -f $(WORK)/makedown_wiki_links.tmp
	rm -f $(WORK)/devd.log $(WORK)/devd.pid $(WORK)/devd.address
	-find $(WORK) -type d -empty -print -delete

check: lint check-links

lint: all
	mdl -s $(MAKEDOWN)/mdlstyle.rb $(PAGES)

check-links: all
	$(MAKEDOWN)/devd.sh $(WORK)
	$(MAKEDOWN)/linkchecker.sh $(WORK) "$$(cat $(WORK)/devd.address)"

$(WIKI_LINKS):
	@mkdir -p $(dir $@)
	$(MAKEDOWN)/genwikilinks.sh $(SRCDIR) $(MAKEDOWN) $(WORK) $(WIKI_LINKS) > "$@"

$(WORK)/%.html: $(SRCDIR)/%.md $($(MAKEDOWN)/makedown.sh --print-template "$<") $(WIKI_LINKS)
	@mkdir -p $(dir $@)
	$(MAKEDOWN)/makedown.sh $(SITE_NAME_ARG) $(WIKI_LINKS_ARG) "$<" "$@"

$(WORK)/%: $(SRCDIR)/%
	@mkdir -p $(dir $@)
	cp "$<" "$@"

deploy: all
	rsync -v -rl --delete-after $(WORK)/ $(IMAGE)

watch: all
	$(MAKEDOWN)/devd.sh "$(WORK)"
	while true; do \
	    (for type in pages style script aux;do \
	        $(MAKEDOWN)/find.sh --absolute $${type} $(SRCDIR) $(MAKEDOWN) $(WORK) || exit 2; \
	    done) | entr -c sh -c '$(MAKE) WORK=$(WORK) check && $(MAKE) WORK=$(WORK)'; \
	done
	kill $$(cat $(WORK)/devd.pid)

.PHONY: all clean check lint check-links deploy watch
