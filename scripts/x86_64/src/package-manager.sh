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

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/apk/repositories
cat "$SCRIPTPATH"/repositories >> "$TMP"/etc/apk/repositories

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/apk/world
cat "$SCRIPTPATH"/packages >> "$TMP"/etc/apk/world

