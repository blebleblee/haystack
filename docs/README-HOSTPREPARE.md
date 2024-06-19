## Overview of hostprepare.sh

Directory /tools contains a series of Bash scripts to configure a server with various networking and virtualization components. The scripts perform tasks like installing and configuring a DHCP server, setting up network bridges and VLANs, installing necessary packages, enabling IPv4 forwarding, and configuring services like libvirt and nginx.

## Scripts

### 1. Script `hostprepare-packages.sh`

This script installs necessary packages for virtualization and other utilities.

#### Steps:
- Installs packages like git, mkisofs, virt-install, guestfs-tools, qemu, libvirt, nginx, yq, and kubernetes-client.
- Installs the `kvm_server` pattern.

### 2. Script `hostprepare-settings.sh`

This script configures system settings for IP forwarding and service configurations.

#### Steps:
- Enables IPv4 forwarding.
- Configures libvirt to run as root.
- Enables and starts the libvirtd and nginx services.
- Creates a passwordless SSH key.

### 3. `hostprepare-net.sh`

This script configures network bridges, VLANs, and dummy interfaces. Dummy interface is required to keep br-public up as vlan interface is on this bridge and dhcp from `hostprepare-dhcp.sh` will listen on that interface.
If you do not plan to use DHCP, you can skip dummy interface configuration.

#### Steps:
- Creates three network bridges: `br-rancher`, `br-mgmt`, and `br-public`.
- Sets up a VLAN and a dummy interface to bring up `br-public`.
- Creates another bridge `br0` and assigns `eth0` as its slave.
- Restarts the NetworkManager to apply changes.

#### Customizing Subnets

You can customize the subnets in the network configuration using the `sed` command. For example, to change the subnet range or other options, you can modify the `hostprepare-net.sh` script as follows:

```bash
sed -i 's/192.168.143.1\/24/192.168.150.1\/24/' hostprepare-net.sh
sed -i 's/192.168.144.1\/24/192.168.151.1\/24/' hostprepare-net.sh
sed -i 's/192.168.146.1\/24/192.168.152.1\/24/' hostprepare-net.sh
```

### 4. Script `hostprepare-dhcp.sh`

This script installs and configures a DHCP server. Adjust the values according to your setup.
In case you don't plan to use Harvester or don't want to configure VLAN based VM network, you don't need to run DHCP and you can use existing one on management network.

#### Steps:
- Installs the DHCP server package.
- Configures the DHCP server to use the `vlan145` interface.
- Sets up the DHCP server configuration file with necessary options.

### 5. Script `hostprepare.sh`

This script orchestrates the execution of other scripts to prepare the host. You can either execute just this script or execute each partial script separately for configuration you require.

#### Steps:
- Executes `hostprepare-packages.sh`, `hostprepare-settings.sh`, and `hostprepare-net.sh`.
- Optionally executes `hostprepare-dhcp.sh` (commented out by default).
- Prompts the user to reboot the system after setup.

## Notes

- Ensure you have the necessary permissions to execute these scripts. It should be executed under user "root"
- Modify the scripts as needed to fit your specific environment and requirements.
