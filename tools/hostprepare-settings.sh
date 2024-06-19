#!/bin/bash

# Enable IPv4 forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Configure libvirt
echo 'user = "root"' >> /etc/libvirt/qemu.conf
echo 'group = "root"' >> /etc/libvirt/qemu.conf
systemctl enable libvirtd
systemctl start libvirtd

# Configure nginx
systemctl enable nginx
systemctl start nginx

# Create passwordless SSH key
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

