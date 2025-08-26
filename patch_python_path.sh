#!/bin/sh

# When installing python packages via apk add py3-whatever, the packages appear in
# /usr/lib/python3.12/site-packages. But python expects them to be in
# /usr/local/lib/python3.12/site-packages. This script creates symlinks to fix that.

for pkg in /usr/lib/python3.12/site-packages/*; do
  if [ -e "/usr/local/lib/python3.12/site-packages/$(basename "$pkg")" ]; then
    continue
  fi
  ln -s "$pkg" "/usr/local/lib/python3.12/site-packages/$(basename "$pkg")"
done
