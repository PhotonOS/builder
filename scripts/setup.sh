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
  
# TODO: Run *only* if not setup yet
readonly SETUP=$(dialog --keep-tite --ascii-lines --ok-label "Finish" --no-cancel \
                --title "Factory Setup" \
                --backtitle "Initial Setup of Node System. You can change these settings later." \
                --insecure "$@" \
                --mixedform "\n$NAME-$VERSION" \
                20 50 0 \
                "UUID            :" 1 1 "$UUID" 1 20 30 0 2 \
                "IP-Address      :" 1 1 "$IP" 1 20 20 0 2 \
                "Hostname        :" 2 1 "n1"  2 20  10 0 0 \
                3>&1 1>&2 2>&3)

HOSTNAME=$((SETUP | awk '{ print $2 }'))
# TODO: Apply & Save Settings

dialog_settings() {
  SETTINGS=$(dialog --keep-tite --ascii-lines --ok-label "Save" \
                  --title "Settings" \
                  --insecure "$@" \
                  --mixedform "\n$NAME-$VERSION" \
                  20 50 0 \
                  "UUID            :" 1 1 "$UUID" 1 20 30 0 2 \
                  "IP-Address      :" 1 1 "$IP" 1 20 20 0 2 \
                  "Hostname        :" 2 1 "n1"  2 20  10 0 0 \
                  3>&1 1>&2 2>&3)

  # TODO: Apply & Save Settings
}

dialog_telemetrics() {
  ANSWER=$(dialog --keep-tite --ascii-lines \
            --msgbox "Feature not available. Coming soon!" 11 30 \
            3>&1 1>&2 2>&3)
}
dialog_reset() {
  ANSWER=$(dialog --keep-tite --ascii-lines \
            --msgbox "Feature not available. Coming soon!" 11 30 \
            3>&1 1>&2 2>&3)
}

while :
do

ANSWER=$(dialog --item-help --no-tags --default-item "Settings" --keep-tite --ascii-lines --keep-window --no-ok --no-cancel \
		--title "BACKBONE INTERNET SERVICES" \
		--menu "\n$NAME-$VERSION" 12 32 4 \
		"settings"     "Settings"     "Edit System Settings" \
		"telemetrics" "Telemetrics" "See System Telemetrics" \
    "shell" "Open Shell" "Open a basic Bash Shell" \
		"reset" "[!] Factory Reset" "Reset device to default. All data will be lost." 3>&1 1>&2 2>&3)

case $ANSWER in
  "settings" ) dialog_settings;;
  "telemetrics" ) dialog_telemetrics;;
  "reset" ) dialog_reset;; # TODO
  "shell" ) /bin/bash;;
esac

done
