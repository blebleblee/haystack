#!/bin/bash

# Install DHCP server
zypper install -y dhcp-server

# Configure DHCP server
sed -i 's/^DHCPD_INTERFACE.*/DHCPD_INTERFACE="vlan145 br-public"/' /etc/sysconfig/dhcpd

cat <<EOL > /etc/dhcpd.conf
option domain-name "2464.cz";
option domain-name-servers 192.168.200.2, 192.168.200.167;
default-lease-time 3600;
max-lease-time 7200;
ddns-update-style none;
authoritative;
log-facility local7;
option routers 192.168.145.1;
option broadcast-address 192.168.145.255;
option subnet-mask 255.255.255.0;
subnet 192.168.145.0 netmask 255.255.255.0 {
  range 192.168.145.10 192.168.145.100;
  option routers 192.168.145.1;
  option broadcast-address 192.168.145.255;
  option subnet-mask 255.255.255.0;
}
subnet 192.168.146.0 netmask 255.255.255.0 {
  range 192.168.146.10 192.168.146.100;
  option routers 192.168.146.1;
  option broadcast-address 192.168.146.255;
  option subnet-mask 255.255.255.0;
}
EOL