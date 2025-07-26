#!/bin/bash

ftp -in ftpupload.net <<EOT
  user if0_34643740 oxZAyRupoV
  cd htdocs
  mput *.html
  bye
EOT
