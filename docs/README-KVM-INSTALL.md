## kvm-install-vm

A bash wrapper around virt-install to build virtual machines on a local KVM
hypervisor.

Original project: https://github.com/giovtorres/kvm-install-vm

## kvm-install-autoyast

A stripped down version of the bash wrapper around `virt-install` to install virtual 
machines on a local KVM hypervisor using AutoYaST. Currently only supports SUSE
Linux Enterprise Linux 15. Configure RMT and RMT_FINGER variables in `functions.sh` file.

Script also requires unpacked/automounted ISO files. See function `set_vars()`
One way of achieving this is with automount and a webserver:

```sh
$ cat /etc/auto.master
+auto.master
/srv/www/htdocs/inst/ program:/bin/automap -fstype=iso9660,ro,loop –timeout=120

$ cat /bin/automap
#!/bin/bash
ret=$(find /srv/nas/iso -name $1.iso)
if [[ "" != "$ret" ]] ; then
 echo / :$ret
fi
```

### Prerequisites

You need to have the KVM hypervisor installed, along with a few other packages (naming of packages can differ on other distributions):

- genisoimage or mkisofs
- virt-install
- libguestfs-tools-c/guestfs-tools
- qemu-img
- libvirt-client
- libosinfo

To install the dependencies, run:

- OpenSUSE example:

If you didn't run `hostprepare.sh` then:
```
cd tools
./hostprepare-packages.sh
```

- Fedora example:

```
sudo dnf -y install genisoimage virt-install libguestfs-tools-c qemu-img libvirt-client wget libosinfo
```

- Ubuntu example:

```
sudo apt install -y genisoimage virtinst libguestfs-tools qemu-utils libvirt-clients wget libosinfo-bin
```

If you want to resolve guests by their hostnames, install the `libvirt-nss` package:

- Fedora example:

```
sudo dnf -y install libvirt-nss
```

- Ubuntu example:

```
sudo apt install -y libnss-libvirt
```

Then, add `libvirt` and `libvirt_guest` to list of **hosts** databases in
`/etc/nsswitch.conf`.  See [here](https://libvirt.org/nss.html) for more
information.

### Usage

```
# ./kvm-install-vm help
NAME
    kvm-install-vm - Install virtual guests using cloud-init on a local KVM
    hypervisor.

SYNOPSIS
    kvm-install-vm COMMAND [OPTIONS]

DESCRIPTION
    A bash wrapper around virt-install to build virtual machines on a local KVM
    hypervisor. You can run it as a normal user which will use qemu:///session
    to connect locally to your KVM domains.

COMMANDS
    create      - create a new guest domain
    remove      - delete a guest domain
    list        - list all domains, running and stopped
    attach-disk - create and attach a disk device to a guest domain
    detach-disk - detach a disk device from a guest domain
    attach-nvme - create and attach a nvme device to a guest domain (VM reboot required)
    attach-nic  - create and attach a network interface to a guest domain
    help        - show this help or help for a subcommand
```

#### Creating Guest VMs

```
# ./kvm-install-vm help create
NAME
    kvm-install-vm create [COMMANDS] [OPTIONS] VMNAME

DESCRIPTION
    Create a new guest domain.

COMMANDS
    help - show this help

OPTIONS
    -a          Autostart             (default: false)
    -b          Bridge                (default: br0)
    -c          Number of vCPUs       (default: 2)
    -d          Disk Size (GB)        (default: 20)
    -D          DNS Domain            (default: example.local)
    -f          CPU Model / Feature   (default: host-passthrough)
    -g          Graphics type         (default: spice)
    -G          Default Gateway       (default: dhcp)
    -h          Display help
    -i          Custom QCOW2 Image
    -I          IP address/netmask    (default: dhcp)
    -k          SSH Public Key        (default: /root/.ssh/id_rsa.pub)
    -l          Location of Images    (default: /root/virt/images)
    -L          Location of VMs       (default: /root/virt/vms)
    -m          Memory Size (MB)      (default: 2048)
    -M          Mac address           (default: auto-assigned)
    -p          Console port          (default: auto)
    -R          Resolver(s)           (default: dhcp)
    -s          Custom shell script
    -t          Linux Distribution    (default: sles155)
    -T          Timezone              (default: UTC)
    -u          Custom user           (default: root)
    -y          Assume yes to prompts (default: false)
    -n          Assume no to prompts  (default: false)
    -v          Be verbose

DISTRIBUTIONS
    NAME            DESCRIPTION                         LOGIN
    centos8         CentOS 8                            centos
    centos7         CentOS 7                            centos
    debian12        Debian 12 (Bookworm)                debian
    fedora38        Fedora 38                           fedora
    fedora39        Fedora 39                           fedora
    opensuse154     OpenSUSE Leap 15.4                  opensuse
    opensuse155     OpenSUSE Leap 15.5                  opensuse
    micro6          SUSE Linux Micro 6.0 RC             sles
    sles152         SUSE Enterprise Linux 15 SP2        sles
    sles153         SUSE Enterprise Linux 15 SP3        sles
    sles154         SUSE Enterprise Linux 15 SP4        sles
    sles155         SUSE Enterprise Linux 15 SP5        sles
    sles155qu1      SUSE Enterprise Linux 15 SP5 QU1    sles
    ubuntu1804      Ubuntu 18.04 LTS (Bionic Beaver)    ubuntu
    ubuntu2004      Ubuntu 20.04 LTS (Focal Fossa)      ubuntu
    ubuntu2204      Ubuntu 22.04 LTS (Jammy Jellyfish)  ubuntu
    rocky9.3        Rocky Linux                         rocky
    rhel7.9         Red Hat Enterprise Linux 7.9        rhel
    rhel8.9         Red Hat Enterprise Linux 8.9        rhel

EXAMPLES
    kvm-install-vm create foo
        Create VM with the default parameters: SLES 15 SP5, 2 vCPU, 2GB RAM,
        20GB of disk capacity.

    kvm-install-vm create -c 4 -m 4096 -d 30 foo
        Create VM with custom parameters: 4 vCPUs, 4GB RAM, and 30GB of disk
        capacity.

    kvm-install-vm create -T UTC -u bar -v foo
        Create a default VM with UTC timezone, custom user "bar" and be verbose.

    kvm-install-vm create -I 192.168.200.202/23 -R 192.168.200.2 -G 192.168.200.1 foo
        Create VM with static network settings: IP address 192.168.200.202/23, DNS server 192.168.200.2
        and default gateway 192.168.200.1. All three parameters are required.
```

#### Deleting a Guest Domain

```
# ./kvm-install-vm help remove
NAME
    kvm-install-vm remove [COMMANDS] VMNAME

DESCRIPTION
    Destroys (stops) and undefines a guest domain. This also removes the
    associated storage pool.

COMMANDS
    help - show this help

OPTIONS
    -l          Location of Images  (default: /root/virt/images)
    -L          Location of VMs     (default: /root/virt/vms)
    -v          Be verbose

EXAMPLE
    kvm-install-vm remove foo
        Remove (destroy and undefine) a guest domain.  WARNING: This will
        delete the guest domain and any changes made inside it!
```

#### Attaching a new disk

```
# ./kvm-install-vm help attach-disk
NAME
    kvm-install-vm attach-disk [OPTIONS] [COMMANDS] VMNAME

DESCRIPTION
    Attaches a new disk to a guest domain.

COMMANDS
    help - show this help

OPTIONS
    -d SIZE     Disk size (GB)
    -f FORMAT   Disk image format       (default: qcow2)
    -s IMAGE    Source of disk device
    -t TARGET   Disk device target

EXAMPLE
    kvm-install-vm attach-disk -d 10 -s example-5g.qcow2 -t vdb foo
        Attach a 10GB disk device named example-5g.qcow2 to the foo guest
        domain.
```

#### Attaching a new nvme disk (experimental)

```
# ./kvm-install-vm help attach-nvme
NAME
    kvm-install-vm attach-nvme [OPTIONS] [COMMANDS] VMNAME

DESCRIPTION
    Attaches a new NVMe disk to a guest domain. VM will be restarted.

COMMANDS
    help - show this help

OPTIONS
    -d SIZE     Disk size (GB)
    -f FORMAT   Disk image format       (default: qcow2)

EXAMPLE
    kvm-install-vm attach-nvme -d 20 -f qcow2 foo
        Attach 20GB NVMe device to the foo guest domain.
```


#### Attaching a new network interface

```
# ./kvm-install-vm help attach-nic
NAME
    kvm-install-vm detach-nic [OPTIONS] [COMMANDS] VMNAME

DESCRIPTION
    Attaches a new network interface to a guest domain.

COMMANDS
    help - show this help

OPTIONS
    -m MODEL   Model of new network interface     (default: virtio)
    -b BRIDGE  Bridge                             (default: br0)

EXAMPLE
    kvm-install-vm attach-nic -t e1000 -b br-rancher foo
        Attach a new network interface of type e1000. Target bridge is br-rancher
        and guest domain foo.
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

1. This script will download a qcow2 cloud image from the respective
   distribution's download site.  See script for URLs.

2. If using libvirt-nss, keep in mind that DHCP leases take some time to
   expire, so if you create a VM, delete it, and recreate another VM with the
   same name in a short period of time, there will be two DHCP leases for the
   same host and its hostname will likely not resolve until the old lease
   expires.

3. The Operating System information database (osinfo-db) provides Operating
   System specific information needed to create guests for the various systems
   supported by `kvm-install-vm`.  The database files provided by your package
   manager may be out of date and not provide definitions for recent Operating
   System versions. If you encounter the following error message, you may need
   to update the database files:
   ```sh
   ERR: Unknown OS variant '<name>'. Please update your osinfo-db.
   ```

   If you have already updated your system, and the osinfo-db is still to old,
   then you can use the `osinfo-db-import` tool with the `--local` option, to
   install an up-to-date database in your home directory which will not
   conflict with your package manager files. The `osinfo-db-import` tool is
   provided by the rpm/deb packages `osinfo-db-tools`.
   See https://libosinfo.org/download for more information.

### Testing

Tests are written using [Bats](https://github.com/sstephenson/bats).  To
execute the tests, run `./test.sh` in the root directory of the project.

### Use Cases

If you don't need to use Docker or Vagrant, don't want to make changes to a
production machine, or just want to spin up one or more VMs locally to test
things like:

- high availability
- clustering
- package installs
- preparing for exams
- checking for system defaults
- anything else you would do with a VM

...then this wrapper could be useful for you.

### Troubleshooting

If you will encounter something similar:

```
ERR: Unknown OS variant 'fedora31'. Please update your osinfo-db.  See https://libosinfo.org/download for more information.
```

Then you need to update the DB in libosinfo.
Check the url and select the latest date ( https://releases.pagure.org/libosinfo/ )

```
wget -O "/tmp/osinfo-db.tar.xz" https://releases.pagure.org/libosinfo/osinfo-db-20200515.tar.xz
sudo osinfo-db-import --local "/tmp/osinfo-db.tar.xz"
```
