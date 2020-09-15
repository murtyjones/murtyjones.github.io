#!/bin/sh
# brew install optipng
find . -name "*.png" -exec optipng -o7 {} \;
