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

makedirectory $(whoami):$(id -g -n) 0751 "${TMP}/root/"

step "Clone Repository"
if [ ! -z "${GITHUB_TOKEN}" ]; then TOKEN="token:${GITHUB_TOKEN}@"; fi
echo $(git clone https://${TOKEN}github.com/$GITHUB_REPOSITORY.git "$TMP"/root 2>&1 > /dev/null) \
    | ( read stdout; if [[ "$stdout" == *"fatal"* ]]; then error $stdout; else warning $stdout; fi )

step "Initializing Submodules"
gawk -i inplace -v INPLACE_SUFFIX=.bak -v TOKEN="$GITHUB_TOKEN" '{ gsub("github.com", "token:"TOKEN"@github.com")}; { print }' "$TMP"/root/.gitmodules
echo $(cd "$TMP"/root && git submodule update --init --recursive 2>&1 > /dev/null) \
    | ( read stdout; if [[ "$stdout" == *"fatal"* ]]; then error $stdout; else warning $stdout; fi )
rm -rf "$TMP"/root/.gitmodules && mv "$TMP"/root/.gitmodules.bak "$TMP"/root/.gitmodules
