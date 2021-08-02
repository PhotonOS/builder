#!/bin/sh -e

# 
# USAGE (example):
#       ./configure.sh \
#               ${{ env.GITHUB_REPOSITORY }} \                          (Required) GitHub URI of the Repository to clone into /root
#               ${{ secrets.GITHUB_TOKEN }} \                           (Required) GitHub Token [Default Secret set in GitHub Actions CI]
#               $(mktemp /tmp/configure-script.XXXXXX)                  (Optional) If assiged the created files will be ONLY created inside the
#                                                                                  Defined Directory.
#

TMP=$3 # (optional) Write files to defined Directory instead of RootFS
CACHE=/cache

# REPOSITORY SETTINGS
GITHUB_REPOSITORY=$1
GITHUB_TOKEN=$2

# DEFAULT
HOSTNAME=node
STATUS=UNASSIGNED
NS_CHECK_URL=google.com
NS_PRIMARY=8.8.8.8
NS_SECONDARY=8.8.4.4

# WARNING: Configured to run on AlpineOS Extended x86_64
# @website: https://alpinelinux.org/downloads/

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

step() {
	printf '\n\033[1;36m--- %s ---\033[0m\n' "$@" >&2  # bold cyan
}

makefile() {
	OWNER="$1"
	PERMS="$2"
	FILENAME="$3"
	cat > "$FILENAME"
	chown "$OWNER" "$FILENAME"
	chmod "$PERMS" "$FILENAME"
}

rc_add() {
	mkdir -p "$TMP"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$TMP"/etc/runlevels/"$2"/"$1"
}

if [[ -f "$CACHE"/environment ]]; then
    source "$CACHE"/environment
    STATUS=READY
fi

echo "======= CONFIG $PWD ======="
echo "TMP=${TMP}"
echo "CACHE=${CACHE}"
echo "GITHUB_REPOSITORY=${GITHUB_REPOSITORY}"
echo "GITHUB_TOKEN=${GITHUB_TOKEN}"
echo "GITHUB_BRANCH=${GITHUB_BRANCH}"
echo "HOSTNAME=${HOSTNAME}"
echo "STATUS=${STATUS}"
echo "NS_CHECK_URL=${NS_CHECK_URL}"
echo "NS_PRIMARY=${NS_PRIMARY}"
echo "NS_SECONDARY=${NS_SECONDARY}"
echo "============================"

step "Setup Hostname"
mkdir -p "$TMP"/etc
makefile root:root 0644 "$TMP"/etc/hostname <<EOF
$HOSTNAME ($STATUS)
EOF

step "Configure conf.d"
mkdir -p "$TMP"/etc/conf.d
makefile root:root 0644 "$TMP"/etc/conf.d/local <<EOF
rc_verbose=yes
EOF

mkdir -p "$TMP"/etc/conf.d
makefile root:root 0644 "$TMP"/etc/conf.d/initialize <<EOF
rc_need="!net net.eth0"
EOF

# TODO: May want to change Port / etc. in /etc/ssh/sshd_config
# @source: https://wiki.alpinelinux.org/wiki/Setting_up_a_ssh-server

step "Add Copyright & Warning"

makefile root:root 0644 "$TMP"/etc/issue <<EOF

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

EOF

makefile root:root 0644 "$TMP"/etc/motd <<EOF

#############################################################################
#                       BACKBONE INTERNET SERVICES                          # 
#                All connections are monitored and recorded                 #
#         Disconnect IMMEDIATELY if you are not an authorized user!         #
#############################################################################

EOF

step "Clone Repository"
mkdir -p "$TMP"/root
git clone https://token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git \
    "$TMP"/root

step "Setup .profile"
mkdir -p "$TMP"/root
makefile root:root 0644 "$TMP"/root/.profile <<EOF
PS1='\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Execute Setup
/bin/sh -c /root/scripts/setup.sh
EOF

# - Configure Registries -
# @source: https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management

mkdir -p "$TMP"/etc/apk/
makefile root:root 0644 "$TMP"/etc/apk/repositories <<EOF
http://nl.alpinelinux.org/alpine/v3.7/main
http://nl.alpinelinux.org/alpine/v3.7/community
@edge http://nl.alpinelinux.org/alpine/edge/main
@edgecommunity http://nl.alpinelinux.org/alpine/edge/community
@testing http://nl.alpinelinux.org/alpine/edge/testing
EOF

mkdir -p "$TMP"/etc/apk
makefile root:root 0644 "$TMP"/etc/apk/world <<EOF
alpine-base
util-linux
bash
bash-completion
vim
docker
openssh
iptables
networkmanager
EOF

# - Setup Network -
step "Setup Network"
mkdir -p "$TMP"/etc/network/
makefile root:root 0644 "$TMP"/etc/network/interfaces <<EOD
auto lo
iface lo inet loopback
# INTERNET
auto eth0
iface eth0 inet dhcp
    hostname ${HOSTNAME}

# TRUNK
auto eth1
iface eth0 inet static
    address 10.0.0.8/16
    netmask 255.255.0.0
    gateway 10.0.0.1
  
# BRIDGE (VIRTUALIZED)
auto br0
iface br0 inet static
    address 10.0.255.2
    netmask 255.255.0.0
    network 10.0.0.0
    broadcast 10.0.255.255
    bridge_ports eth1

# MANAGEMENT
auto eth2
iface eth2 inet static
    address 10.0.0.7
    netmask 255.255.0.0
    gateway 10.0.0.1
EOD

mkdir -p "$TMP"/etc
makefile root:root 0644 "$TMP"/etc/resolv.conf <<EOD
search ${NS_CHECK_URL}
nameserver ${NS_PRIMARY}
nameserver ${NS_SECONDARY} # FALLBACK
EOD

mkdir -p "$TMP"/etc/NetworkManager
makefile root:root 0644 "$TMP"/etc/NetworkManager/NetworkManager.conf <<EOD
[main]
plugins=ifupdown,keyfile
dhcp=dhcpcd
[ifupdown]
managed=false
EOD

mkdir -p "$TMP/root/.ssh"

# - Autostart scripts -
step "Autostart scripts"
mkdir -p "${TMP}/etc/local.d/"
cp /etc/inittab "$TMP/etc/inittab"
cp /etc/passwd "$TMP/etc/passwd"

# Hostname setup script
step "Hostname setup script"
cat > "$TMP/etc/local.d/hostname.start" <<EOF
#!/bin/sh
HOSTNAME=\$(cat /sys/devices/virtual/dmi/id/board_serial)
sed -i -e "s/alpine/\$HOSTNAME/g" /etc/hostname /etc/hosts
hostname \$HOSTNAME
EOF
chmod +x "$TMP/etc/local.d/hostname.start"

# NetworkManager setup script
step "Setup Network Manager"
cat > "$TMP/etc/local.d/initialize.start" <<EOF
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

# Add all packages from /etc/apk/world
# @source: https://stackoverflow.com/questions/62912343/alpine-apk-etc-apk-world-file
apk add

# Restart Hostname Service
rc-service networkmanager start || etc/init.d/networkmanager start
rc-service hostname restart || /etc/init.d/hostname restart

nmcli general permissions

# NOTE: Restarting Network Manager
# @source: https://wiki.alpinelinux.org/wiki/NetworkManager
# @description: To make changes take effect

rc-service networkmanager restart || /etc/init.d/networking restart
EOF
chmod +x "$TMP/etc/local.d/initialize.start"

step "IP Setup"
cat > "$TMP/etc/local.d/ip-eth1.start" <<EOF
#!/bin/sh
ip link set eth1 up
IP=\$(cat /sys/devices/virtual/dmi/id/product_serial)
ip add add \$IP dev eth1
echo "IP eth1: \$IP" >> /etc/motd
EOF
chmod +x "$TMP/etc/local.d/ip-eth1.start"

step "Autoconf setup"
cat > "$TMP/etc/local.d/autoconf.start" <<EOF
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
chmod +x "$TMP/etc/local.d/autoconf.start"

step "Adjust rc.conf"
sed -Ei \
	-e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
	-e 's/^[# ](rc_logger)=.*/\1=YES/' \
	-e 's/^[# ](unicode)=.*/\1=YES/' \
	/etc/rc.conf

rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

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
rc-add sshd boot

rc_add local default
rc_add dropbear default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown
