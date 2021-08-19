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

makedirectory $(whoami):$(id -g -n) 0751 "${TMP}/etc/local.d/"

makefile $(whoami):$(id -g -n) 0744 "$TMP/etc/local.d/hostname.start" <<EOF
#!/bin/sh
HOSTNAME=\$(cat /sys/devices/virtual/dmi/id/board_serial)
sed -i -e "s/alpine/\$HOSTNAME/g" /etc/hostname /etc/hosts
hostname \$HOSTNAME
EOF

makefile $(whoami):$(id -g -n) 0744 "$TMP/etc/local.d/initialize.start" <<EOF
#!/bin/sh

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

echo "Initializing ..."

apk add --update

# Restart Hostname Service
rc-service hostname restart || /etc/init.d/hostname restart
EOF

makefile $(whoami):$(id -g -n) 0744 "$TMP/etc/local.d/helper.start" <<EOF
#!/bin/sh

echo "Helper Service exists!"

EOF

makefile $(whoami):$(id -g -n) 0744 "$TMP/etc/local.d/ip-eth1.start" <<EOF
#!/bin/sh
ip link set eth1 up
IP=\$(cat /sys/devices/virtual/dmi/id/product_serial)
ip add add \$IP dev eth1
echo "IP eth1: \$IP" >> /etc/motd
EOF

makefile $(whoami):$(id -g -n) 0744 "$TMP/etc/local.d/autoconf.start" <<EOF
#!/bin/sh
URL=\$(cat /sys/devices/virtual/dmi/id/board_asset_tag)
wget -T 2 -O /tmp/autoconf.sh "\$URL"
if [ \$? -eq 0 ]
then
    chmod +x /tmp/autoconf.sh
    /tmp/autoconf.sh 2>&1 > /tmp/autoconf.log
    echo "Autoconf done from \$URL
else
    echo "Failed to fetch \$URL
fi
EOF

makefile $(whoami):$(id -g -n) 0644 "$TMP/etc/rc.conf" <<EOF
rc_info=YES
rc_debug=YES
EOF

step "Update OpenRC Config"
sed -E \
    -e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
    -e 's/^[# ](rc_logger)=.*/\1=YES/' \
    -e 's/^[# ](unicode)=.*/\1=YES/' \
    "$TMP"/etc/rc.conf > /dev/null 2>&1

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit
rc_add udev sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot
rc_add networking boot
rc_add urandom boot
rc_add keymaps boot
rc_add docker boot
rc_add initialize boot
rc_add sshd boot
rc_add helper boot
rc_add dbus boot

rc_add local default
rc_add dropbear default
rc_add udev-postmount default
rc_add sddm default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown
