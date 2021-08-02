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

# @source: https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/apk/repositories <<EOF
http://nl.alpinelinux.org/alpine/v3.7/main
http://nl.alpinelinux.org/alpine/v3.7/community
@edge http://nl.alpinelinux.org/alpine/edge/main
@edgecommunity http://nl.alpinelinux.org/alpine/edge/community
@testing http://nl.alpinelinux.org/alpine/edge/testing
EOF

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/apk/world
cat "$SCRIPTPATH"/packages >> "$TMP"/etc/apk/world

