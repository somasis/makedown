# mdlstyle.rb - style configuration for markdownlint.
# part of makedown, a build system for making markdown websites.
# https://github.com/somasis/makedown

rule 'MD003', :style => :atx            # atx style headers
rule 'MD004', :style => :dash           # enforce dashes for unordered lists
rule 'MD007', :indent => 4              # four spaces for indentation
rule 'MD013', :code_blocks => false     # don't check line length in code blocks
rule 'MD013', :tables => false          # don't check line length in tables
rule 'MD013', :line_length => 100       # 100 length limit
rule 'MD026', :punctuation => ".,;:"    # allow !? at header end
rule 'MD029', :style => :ordered        # enforce incremental ordered lists

exclude_rule 'MD013' # line length is stupid... disable it now
exclude_rule 'MD022' # don't enforce spaces on both sides of headers. used by makedown.sh, for page title and description. also it looks better.
exclude_rule 'MD025' # allow multiple top level, because we want to be in-depth in our doc
exclude_rule 'MD036' # allow emphasis "used instead of a header" because we're using emphasis without desire for a header
exclude_rule 'MD039' # currently there's a bug with this: https://github.com/markdownlint/markdownlint/issues/182
