#!/bin/bash
trap "" INT

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

readonly HARDWARE=/dev/sdb
readonly MOUNT=/media/sdb
readonly DESTINATION=/media
readonly IP=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
readonly UUID=123456789 # TODO

readonly NAME=$(cat package.json \
  | grep name \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g' \
  | tr -d '[[:space:]]')
  
readonly VERSION=$(cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g' \
  | tr -d '[[:space:]]')

dialog_setup() {
  adduser me
  setup-disk
  echo "Installation done. Remove device and reboot."
  exit 0;
}

dialog_try() {
  adduser me
  service sddm start
  exit 0;
}

while :
do

ANSWER=$(dialog --item-help --no-tags --default-item "Settings" --keep-tite --ascii-lines --keep-window --no-ok --no-cancel \
		--title "Photon OS" \
		--menu "\n$NAME-$VERSION" 12 32 4 \
		"setup"     "Setup & Install"     "Setup & Install System" \
		"try"     "Try Demo"     "Do not install System, only live demo" \
    		"shell" "Open Shell" "Open a basic Bash Shell" 3>&1 1>&2 2>&3)

case $ANSWER in
  "setup" ) dialog_setup;;
  "try" ) dialog_try;;
  "shell" ) /bin/bash;;
esac

done
