#!/bin/bash

while [ 1 ]; do
  if [ -f micro.html ]; then
    ./ftp.sh
    rm index.html
    rm micro.html
  fi
  sleep 30
done
