## kvm-install-harv

An evolution of a bash wrapper around virt-install to build virtual machines 
running Harvester HCI on a local KVM hypervisor.

For lab purposes I recommend to configure /etc/libvirt/qemu.conf as following (done automatically
by hostprepare script):

```
user = "root" 
group = "root" 
```

If you want to run the VMs within Harvester you need to enable nested virtualiztion. On OpenSUSE 15.5
it is on by default when kvm-server pattern gets installed:
```
# cat /etc/modprobe.d/kvm-nested.conf
options kvm_intel nested=1
options kvm_intel enable_shadow_vmcs=1
options kvm_intel enable_apicv=1
options kvm_intel ept=1
```

Also, I recommend to configure additional bridges. I am using "br-rancher" for VMs running
Rancher and "br-mgmt" for Harvester management network. Additionally, if you want to enable
extra network for VMs, configure bridge "br-public" and run dhcp server listening on that
bridge. It is also configured automatically by `hostprepare.sh` script, just make sure to run it
with your subnet configuration in case they are different from the defined ones.

It is possible to use DHCP for the nodes (not VMs in Harvester) but I recommend static networking.
DHCP service for VMs in Harvester should be running on vlan interface. Again this is automatically configured by `hostprepare.sh`.

Example configuration:
```
# cat /etc/dhcpd.conf
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
}
subnet 192.168.146.0 netmask 255.255.255.0 {
  range 192.168.146.10 192.168.146.100;
}
```
```
# cat /etc/sysconfig/dhcpd
...
DHCPD_INTERFACE="vlan145"
...
```
```
# ip a
...
7: br-public: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether 62:83:a7:75:71:90 brd ff:ff:ff:ff:ff:ff
    inet 192.168.146.1/24 brd 192.168.146.255 scope global br-public
       valid_lft forever preferred_lft forever
    inet6 fe80::6083:a7ff:fe75:7190/64 scope link
       valid_lft forever preferred_lft forever
8: vlan145@br-public: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 62:83:a7:75:71:90 brd ff:ff:ff:ff:ff:ff
    inet 192.168.145.1/24 brd 192.168.145.255 scope global vlan145
       valid_lft forever preferred_lft forever
    inet6 fe80::6083:a7ff:fe75:7190/64 scope link
       valid_lft forever preferred_lft forever
...
```

Make sure your host has packet forwarding enabled.
```
net.ipv4.ip_forward = 1 
```

### Usage

```
# ./kvm-install-harv help
NAME
    kvm-install-harv - Install virtual Harvester on a local KVM hypervisor.

SYNOPSIS
    kvm-install-harv COMMAND [OPTIONS]

DESCRIPTION
    A bash wrapper around virt-install to build virtual machines running Harvester
    on a local KVM hypervisor. You can run it as a normal user which will use
    qemu:///session to connect locally to your KVM domains.

COMMANDS
    create      - create a new Harvester node
    remove      - delete a Harvester node
    attach-disk - create and attach disk device to a Harvester node
    detach-disk - detach disk device from a Harvester node
    attach-nvme - create and attach nvme device to a Harvester node (VM reboot required)
    attach-nic  - create and attach network interface to a Harvester node
    list        - list all nodes, running and stopped
    help        - show this help or help for a subcommand
```

#### Creating Harvester nodes

```
# ./kvm-install-harv help create
NAME
    kvm-install-harv create [COMMANDS] [OPTIONS] VMNAME

DESCRIPTION
    Create a new Harvester node.

COMMANDS
    help - show this help

OPTIONS
    -a          Autostart             (default: false)
    -b          Bridge                (default: br0)
    -B          Use bonded NICs       (default: false)
    -c          Number of vCPUs       (default: 4)
    -C          SSL CA Certificate    (default: none)
    -d          Disk Size (GB)        (default: 250)
    -D          DNS Domain            (default: example.local)
    -f          CPU Model / Feature   (default: host-passthrough)
    -g          Graphics type         (default: spice)
    -G          Default Gateway       (default: dhcp)
    -h          Display help
    -H          NTP Server            (default: 192.168.200.1)
    -i          Management IP Address (default: 192.168.200.200)
    -I          IP Address/Netmask    (default: dhcp)
    -j          Join server FQDN      (default: none)
    -J          Cluster Join Mode     (default: false)
    -k          SSH Public Key        (default: /root/.ssh/id_rsa.pub)
    -l          Location of Images    (default: /root/virt/images)
    -L          Location of VMs       (default: /root/virt/vms)
    -m          Memory Size (MB)      (default: 16384)
    -M          Mac Address           (default: auto-assigned)
    -N          NVMe Devices (1 or 2) (default: 0)
    -o          NVMe Disk Size (GB)   (default: 100)
    -p          Console port          (default: auto)
    -P          Proxy Config          (default: none)
    -r          Install role (v1.3)   (default: default)
    -R          Resolver              (default: dhcp)
    -s          SSL Public Cert       (default: none)
    -S          SSL Private Key       (default: none)
    -t          Harvester Version     (default: harv121)
    -T          Token                 (default: foo)
    -x          Skip checks           (default: false)
    -z          Zone Topology Label   (default: zone1)
    -y          Assume yes to prompts (default: false)
    -n          Assume no to prompts  (default: false)
    -v          Be verbose

DISTRIBUTIONS
    NAME            DESCRIPTION                         LOGIN
    harv111         Harvester 1.1.1                     rancher
    harv112         Harvester 1.1.2                     rancher
    harv113         Harvester 1.1.3                     rancher
    harv120         Harvester 1.2.0                     rancher
    harv121         Harvester 1.2.1                     rancher
    harv122         Harvester 1.2.2                     rancher
    harv130         Harvester 1.3.0                     rancher
    harvmaster      Harvester Master Branch             rancher

EXAMPLES
    kvm-install-harv create foo
        Create VM with the default parameters: Harvester 1.2.1, 4 vCPU, 16GB RAM, 250GB
        disk capacity.

    kvm-install-harv create -c 8 -m 32768 -d 400 foo
        Create VM with custom parameters: 8 vCPUs, 32GB RAM, and 400GB disk capacity.

    kvm-install-harv create -I 192.168.200.202/23 -R 192.168.200.2 -G 192.168.200.1 foo
        Create VM with static network settings: IP address 192.168.200.202/23, DNS server 192.168.200.2
        and default gateway 192.168.200.1. All three parameters are required.

    kvm-install-harv create -J -B -i 192.168.201.201 -T topsecret foo
        Create VM with default settings and 2 NICs configured as a bond. Join the new node into an
        existing cluster using the token topsecret and management ip address 192.168.201.201
```

#### Deleting Harvester node

```
# ./kvm-install-harv help remove
NAME
    kvm-install-harv remove [COMMANDS] VMNAME

DESCRIPTION
    Destroys (stops) and undefines a Harvester node.  This also removes the
    associated storage pool.

COMMANDS
    help - show this help

OPTIONS
    -l          Location of Images  (default: /root/virt/images)
    -L          Location of VMs     (default: /root/virt/vms)
    -v          Be verbose

EXAMPLE
    kvm-install-harv remove foo
        Remove (destroy and undefine) a Harvester node.  WARNING: This will
        delete the Harvester node and any changes made inside it!
```

#### Attaching a new disk

```
# ./kvm-install-harv help attach-disk
NAME
    kvm-install-harv attach-disk [OPTIONS] [COMMANDS] VMNAME

DESCRIPTION
    Attaches new disk to a Harvester node.

COMMANDS
    help - show this help

OPTIONS
    -d SIZE     Disk size (GB)
    -f FORMAT   Disk image format       (default: qcow2)
    -s IMAGE    Source of disk device
    -t TARGET   Disk device target

EXAMPLE
    kvm-install-harv attach-disk -d 10 -s example-5g.qcow2 -t vdb foo
        Attach a 10GB disk device named example-5g.qcow2 to the foo node.
```

#### Attaching a new nvme disk (experimental)

```
# ./kvm-install-harv help attach-nvme
NAME
    kvm-install-harv attach-nvme [OPTIONS] [COMMANDS] VMNAME

DESCRIPTION
    Attaches a new NVMe disk to a Harvester node. VM will be restarted.

COMMANDS
    help - show this help

OPTIONS
    -d SIZE     Disk size (GB)
    -f FORMAT   Disk image format       (default: qcow2)

EXAMPLE
    kvm-install-harv attach-nvme -d 20 -f qcow2 foo
        Attach 20GB NVMe device to the foo guest domain.
```


#### Attaching a new network interface

```
# ./kvm-install-harv help attach-nic
NAME
    kvm-install-harv detach-nic [OPTIONS] [COMMANDS] VMNAME

DESCRIPTION
    Attaches new network interface to a Harvester node.

COMMANDS
    help - show this help

OPTIONS
    -m MODEL   Model of new network interface     (default: virtio)
    -b BRIDGE  Bridge                             (default: br0)

EXAMPLE
    kvm-install-harv attach-nic -t e1000 -b br-rancher foo
        Attach a new network interface of type e1000. Target bridge is br-rancher
        and Harvester node is foo.
```

### Setting Custom Defaults

Copy the `.kivrc` file to your $HOME directory to set custom defaults.  This is
convenient if you find yourself repeatedly setting the same options on the
command line, like the distribution or the number of vCPUs.

Options are evaluated in the following order:

- Default options set in the script
- Custom options set in `.kivrc`
- Option flags set on the command line

### Notes

1. This script will download a Harvester artifacts from the respective
   download site. See script for URLs. Make sure you have sufficient disk
   space available.

2. Harvester requires a beefy host if you want to run multi-node setup.
   It requires fast storage like ssd or nvme and lot of memory/cpu cores.
   Nested virtualization is not as fast as bare-metal node, keep that in mind
   when you start guest clusters with multiple pools and nodes.

3. There are many options available for Harvester deployment. While many are
   implemented in kvm-install-harv, there may be some exotic options not available
   in the script. Feel free to add them but make sure to carefuly test if the
   configuration works as expected. Script produces configuration file with examples.
   If you want to enable the extra configuration, uncomment the example
   but pay attention to yaml indentation.

 4. When you deploy node with NVMe drives do not attach new NVMe using the
    script. It is still possible to add more by editing the node XML but I
    decided to not invest time into enhancing this functionality. 
    NVMe emulation is still being developed and libvirt/qemu is not consistent
    and some older code doesn't work. Current implementation in the script
    supports starting a Harvester node with 1 or 2 drives. Also it is possible
    to attach a new NVMe to Harvester node started without NVMe. This is for
    testing lab purposes only.

 5. Harvester, especially with multi-node deployments, requires a lot of ip addresses.
    Make sure to use scripted recipes for larger scenarios or keep track of all the 
    adresses - gateway, ntp and dns server, management ip, node ip. It may be tough
    to find a problem with deployment when wrong ip addressis used for one of these 
    options. You can also break functionality of existing services by using occupied
    ip addresses accidentally. 

 6. When bond configuration is used, mac address can be defined only for primary
    network card. Second card will receive random mac address. Customize the script
    if you require different network configuration than implemented.
 
 7. Installation is automatic so it requires to access ISO and configuration file 
    over the network. This is achieved by running python web server locally on port
    8000. If that port is taken, customize the script.  

### Use Cases

If you want to get familiar with Harvester, build special cluster or explore the configutation
combinations this script will help you, saving time and money spent on standalone servers.

Possible use-cases:

- high availability
- simplified and fast deployments
- issue debugging or issue reproduction
- learning purposes
- anything else you would do with a VM

### Troubleshooting

If you will encounter problems with the deployent make sure that VM can reach local web server
with the configuration and ISO is mounted. Switch to different console and log as rancher/rancher
to debug further.

Lot of information can be found at https://harvesterhci.io/

I strongly suggest reading about known issues and searching knowledge base if you run into trouble.

Script may contain bugs (most probably it does) or may be missing certain functionality. Contact 
the author or submit PR with your fix or feature ;)
