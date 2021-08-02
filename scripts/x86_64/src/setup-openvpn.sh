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

makedirectory $(whoami):$(id -g -n) 0751 "$TMP/openvpn"

makefile $(whoami):$(id -g -n) 0644 "$TMP"/openvpn/startup-backbone-net.sh <<EOD
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

ipforward=$(sysctl net.ipv4.ip_forward)

if [ $USER != "root" ] then
    echo "This must be run as root!"
    exit -1
fi

####################################################

# Create Network Namespace
ip netns add backbone

# Activate IP Routing in the namespace
if [ $ipforward != "net.ipv4.ip_forward = 1"  then
    ip netns exec backbone sysctl -w net.ipv4.ip_forwarding=1
    echo "ip_forward is now temporarily enabled in netns backbone."
fi

####################################################

# Setup Loopback Interface
ip netns exec backbone ip address add 127.0.0.1/8 dev lo
ip netns exec backbone ip link set lo up

####################################################

# Setup bridge Interface
ip netns exec backbone ip link add br0 type bridge
ip netns exec backbone ip link set br0 up

# Setup bridge VLAN-Subinterfaces
ip netns exec backbone ip link add dev br0 name br0.14 type vlan id 14
ip netns exec backbone ip address add 172.20.0.10/16 dev br0.14
ip netns exec backbone ip address add fd8c:2440:4042:0f92:04::a/66
ip netns exec backbone ip link set br0.14 up

####################################################

# Move Layer 2 physical Interfaces to netns backbone
ip link set eth1 netns backbone
ip link set eth2 netns backbone

# Add Layer 2 physical Interfaces to bridge
ip netns exec backbone ip link set eth1 master br0
ip netns exec backbone ip link set eth2 master br0

# Start Layer 2 vpn-client & -server
##systemctl start openvpn@backbone-node-l2-gateway0
##systemctl start openvpn@backbone-node-l2-gateway1

#############################################################
### Move Layer 2 VPN Interfaces to netns backbone           #
##ip link set tap0 netns backbone                           #
##ip link set tap1 netns backbone                           #
##                                                          #
### Add Layer 2 physical Interfaces to bridge               #
##ip netns exec backbone ip link set tap0 master br0        #
##ip netns exec backbone ip link set tap1 master br0        #
#############################################################
# Handled by up-script at /etc/openvpn/client/scripts/up.sh #
#############################################################

####################################################

# Configure VLANs for Layer 2 Interfaces
#Bridge Interface
##bridge -netns backbone vlan add vid 2 dev br0
#Backbone Node VPN 1
##bridge -netns backbone vlan add vid 11-14 dev tap0 --> Handled by up.sh-script
##bridge -netns backbone vlan add vid 100-4095 dev tap0 --> Handled by up.sh-script
#Backbone Node VPN 2
##bridge -netns backbone vlan add vid 11-14 dev tap1 --> Handled by up.sh-script
##bridge -netns backbone vlan add vid 100-4095 dev tap1 --> Handled by up.sh-script

####################################################

# Configure Layer 3 Firewalling ( iptables / ip6tables ) --> Except VPN Interfaces (Handled by up.sh-script)

# Configure Layer 2 Firewalling ( ebtables ) --> Except VPN Interfaces (Handled by up.sh-script)

####################################################

# Reload necessary Daemons/Services
##ip netns exec backbone /usr/sbin/sshd -D

# List Listening Sockets (in the backbone network-namespace)
ss -lpN backbone

# Exit successfully
exit 0
EOD

makefile $(whoami):$(id -g -n) 0644 "$TMP"/openvpn/breakdown-backbone-net <<EOD
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

ipforward=$(sysctl net.ipv4.ip_forward)

if [ $USER != "root" ] then
    echo "This must be run as root!"
    exit -1
fi

####################################################

# Stop Layer 2 vpn-client & -server
##systemctl stop openvpn@backbone-server-l2
##systemctl stop openvpn@backbone-node-l2

#################################################################
## Remove Layer 2 VPN-Interfaces from Bridge                    #
##ip netns exec backbone ip link set tap0 master nomaster       #
##ip netns exec backbone ip link set tap1 master nomaster       #
#################################################################
# Handled by down-script at /etc/openvpn/client/scripts/down.sh #
#################################################################

####################################################

# Remove bridge VLAN-Subinterfaces
ip netns exec backbone ip address del 172.20.0.10/16 dev br0.14
ip netns exec backbone ip address del fd8c:2440:4042:0f92:04::a/66
ip netns exec backbone ip link set br0.14 down
ip netns exec backbone ip link del dev br0.14

# Remove bridge Interface
ip netns exec backbone ip link set br0 down
ip netns exec backbone ip link del br0 type bridge

####################################################

# Remove Loopback Interface
ip netns exec backbone ip address del 127.0.0.1/8 dev lo
ip netns exec backbone ip link set lo down

####################################################

# Configure Layer 3 Firewalling ( iptables / ip6tables ) --> Except VPN Interfaces --> Handled by down.sh-script

# Configure Layer 2 Firewalling ( ebtables ) --> Except VPN Interfaces --> Handled by down.sh-script

####################################################

# Deactivate IP Routing in the namespace
if [ $ipforward != "net.ipv4.ip_forward = 1"  then
    ip netns exec backbone sysctl -w net.ipv4.ip_forwarding=0
    echo "ip_forward is now disabled in netns backbone."
fi

# Remove Network Namespace
ip netns del backbone

####################################################

#Exit successfully
exit 0
EOD


makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/openvpn/client/scripts/up.sh <<EOD
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

#Exit successfully
exit 0
EOD

makefile $(whoami):$(id -g -n) 0644 "$TMP"/etc/openvpn/client/scripts/down.sh <<EOD
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

#Exit successfully
exit 0
EOD
