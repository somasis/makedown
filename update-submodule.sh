#!/bin/sh

set -xe
git submodule update --checkout --remote --force makedown
git add -v makedown
git commit -o makedown -m 'Update makedown'

