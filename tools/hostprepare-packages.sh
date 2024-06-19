#!/bin/bash

# Install required packages
zypper install -y git mkisofs virt-install guestfs-tools qemu libvirt libvirt-client wget libosinfo nginx yq kubernetes-client bridge-utils

# Install pattern kvm_server
zypper install -y -t pattern kvm_server