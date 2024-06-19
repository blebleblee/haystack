#!/bin/bash

# Create bridges br-rancher, br-mgmt and br-public
nmcli con add type bridge ifname br-rancher con-name br-rancher ipv4.addresses 192.168.143.1/24 ipv4.method manual
nmcli con up br-rancher
nmcli con add type bridge ifname br-mgmt con-name br-mgmt ipv4.addresses 192.168.144.1/24 ipv4.method manual
nmcli con up br-mgmt
nmcli con add type bridge ifname br-public con-name br-public ipv4.addresses 192.168.146.1/24 ipv4.method manual
nmcli con up br-public
echo "Bridges configured successfully"

# Create VLAN and dummy interface to get br-public up
nmcli con add type vlan con-name vlan145 ifname vlan145 dev br-public id 145 ipv4.addresses 192.168.145.1/24 ipv4.method manual
nmcli connection add type dummy ifname dummy0 con-name dummy0
nmcli connection modify dummy0 master br-public
nmcli con up vlan145
echo "VLAN configured successfully."

# Create a bridge 
nmcli connection add type bridge ifname br0 con-name br0

# Modify eth0 to be a slave of br0
nmcli connection modify eth0 master br0 slave-type bridge

# Bring up the bridge and eth0
nmcli connection up br0
nmcli connection up eth0

# Disable stp
nmcli connection modify br0 bridge.stp no
brctl stp br0 off

# Restart the NetworkManager to apply changes
systemctl restart NetworkManager

echo "Bridge br0 configured successfully and enslaved eth0."