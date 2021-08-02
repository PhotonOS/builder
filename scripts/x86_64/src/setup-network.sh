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

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/network/interfaces <<EOD
auto lo
iface lo inet loopback

# INTERNET
auto eth0
iface eth0 inet dhcp
    hostname ${HOSTNAME}

# USER-TRUNK
#auto eth1
#iface eth1 inet manual
  
# BRIDGE (VIRTUALIZED)
#auto br0
#iface br0 inet manual
#    bridge_stp on
#    bridge_pvid 1
#    bridge_vids 10 11 12
#    bridge_vlan_aware yes
#    # Commented out, because handled by bridge command on vpn-startup
#    # bridge_ports tap0 tap1 tap2 tap3

#auto br0.10 # Management Sub-Interface
#iface br0.10 inet static
#    address 10.0.0.3
#    netmask 255.0.0.0

#auto br0.14 # User-Trunk Sub-Interface
#iface br0.14 inet static
#    address 10.0.0.4
#    netmask 255.0.0.0

# MANAGEMENT
#auto eth2
#iface eth2 inet static
#    address 10.0.0.7
#    netmask 255.255.0.0
#    gateway 10.0.0.1
EOD

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/resolv.conf <<EOD
search ${NS_CHECK_URL}
nameserver ${NS_PRIMARY}
nameserver ${NS_SECONDARY} # FALLBACK
EOD

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/NetworkManager/NetworkManager.conf <<EOD
[main]
plugins=ifupdown,keyfile
dhcp=dhcpcd
[ifupdown]
managed=false
EOD
