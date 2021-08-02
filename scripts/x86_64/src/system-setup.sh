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

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/hostname <<EOF
$HOSTNAME ($STATUS)
EOF

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/conf.d/local <<EOF
rc_verbose=yes
EOF

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/conf.d/initialize <<EOF
rc_need="!net net.eth0"
EOF

step "Copy /etc/inittab & /etc/passwd from Host"
echo $(cp /etc/inittab "$TMP/etc/inittab" 2>&1 > /dev/null ) \
    | ( read stdout; if [ -n "$stdout" ]; then warning "$stdout"; fi )
echo $(cp /etc/passwd "$TMP/etc/passwd" 2>&1 > /dev/null ) \
    | ( read stdout; if [ -n "$stdout" ]; then warning "$stdout"; fi )

