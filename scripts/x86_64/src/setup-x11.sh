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

step "Configuring X11"
X -configure

step "Copy /root/xorg.conf.new to /etc/X11/xorg.conf from Host"
makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/X11/xorg.conf
echo $(cat /root/xorg.conf.new >> "$TMP/etc/X11/xorg.conf" 2>&1 > /dev/null ) \
    | ( read stdout; if [ -n "$stdout" ]; then warning "$stdout"; fi )
