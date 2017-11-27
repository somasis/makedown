#!/bin/sh

set -xe
before=$(git -C makedown rev-parse --short HEAD)
git submodule update --checkout --remote --force makedown
PAGER=cat git diff --submodule makedown
after=$(git -C makedown rev-parse --short HEAD)
git add -v makedown
git commit -o makedown -m "Update makedown (${before}..${after})"

