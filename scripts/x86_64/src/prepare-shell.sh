#!/bin/sh -e

#
#   BACKBONE INTERNET SERVICES
#   __________________________
#
#   [2020] - [2021] Backbone Internet Services
#   All Rights Reserved.
# 
#   NOTICE:  All information contained herein is, and remains
#   the property of Backbone Internet Services and its suppliers,
#   if any.  The intellectual and technical concepts contained
#   herein are proprietary to Backbone Internet Services
#   and its suppliers and may be covered by EU and Foreign Patents,
#   patents in process, and are protected by trade secret or copyright law.
#   Dissemination of this information or reproduction of this material
#   is strictly forbidden unless prior written permission is obtained
#   from Backbone Internet Services.
#

makefile $(whoami):$(id -g -n) 0644 "$TMP"/root/.profile <<EOF
PS1='\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Execute Setup
FILE=/root/scripts/setup.sh
if [[ -f "\$FILE" ]]; then
    sh -c \$FILE
fi
EOF
