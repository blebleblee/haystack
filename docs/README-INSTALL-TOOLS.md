## Install tools

Install tools are helper scripts that are used to install K3S, RKE or RKE2 nodes.
While even the default configuration will work, it is advisable to study all
available options which may be neccessary to install advanced features.

For highly available clusters loadbalancer must be configured. Script `manage-lb`
provides functionality to configure server ports and upstream sections.

When cluster is up and running another script - `manage-kubeconfig` - provides
functionality to import and merge the cluster kubeconfig files.

### Prerequisites

The scripts will connect to any VM using username and ssh key, so it can be used
with VMs deployed by kvm-install-vm, manually installed VMs or in a public cloud.

### Usage

The functionality is similar for all scripts. Create option:

```
./install-k3s help
NAME
    install-k3s - Install K3S node on a VM.

SYNOPSIS
    install-k3s COMMAND [OPTIONS]

DESCRIPTION
    A bash script to install and remove K3S nodes. The aim is to simplify
    the installation and make the deployments scriptable.

COMMANDS
    create      - create a new K3S node
    remove      - delete a K3S node
    help        - show this help or help for a subcommand
```

```
# ./install-k3s help create
NAME
    install-k3s create [COMMANDS] [OPTIONS] HOST

DESCRIPTION
    Create a new K3S node.

COMMANDS
    help - show this help

OPTIONS
    -C          K3S Channel           (default: stable)
    -d          Debug mode            (default: false)
    -h          Display help
    -i          cluster-init          (default: false)
    -k          SSH Private Key       (default: /root/.ssh/id_rsa)
    -s          Service type          (default: server)
    -S          Server to connect to  (default: none)
    -t          TLS-SAN hostname/ip   (default: none)
    -T          Token for auth        (default: foo)
    -u          SSH user              (default: sles)
    -V          K3S Version           (default: none)
    -w          Write kubeconfig mode (default: 777)

EXAMPLES
    install-k3s create 192.168.200.201
        Create a new K3S server node on host 192.168.200.201 with default settings.

    install-k3s create -s agent -S 192.169.200.201:6443 -T secret 192.168.200.202
        Create a new K3S agent node that connects to existing server node 192.168.200.201.
        Use token "secret". Host machine is 192.168.200.202.

    install-k3s create -d -C testing -t lb.example.local 192.168.200.203
        Create a new K3S server node on host 192.168.200.203. Turn on debug information.
        Channel "testing" will be used and loabalancer FQDN will be added to TLS-SAN.

    install-k3s create -V v1.28.6+k3s1 -w 600 -u ubuntu 192.168.200.204
        Create a new K3S server node with version 1.28.6. Write kubeconfig so that only
        owner can read and write to it. Use "ubuntu" as user for ssh.
```

```
# ./install-rke help create
NAME
    install-rke create [COMMANDS] [OPTIONS] HOST

DESCRIPTION
    Create a new RKE node.

COMMANDS
    help - show this help

OPTIONS
    -c          CNI Plugin            (default: canal)
    -h          Display help
    -k          SSH Private Key       (default: /root/.ssh/id_rsa)
    -s          Service type          (default: server)
    -S          Server to connect to  (default: none)
    -u          SSH user              (default: sles)
    -V          Kubernetes Version    (default: none)

EXAMPLES
    install-rke create 192.168.200.201
        Create a new RKE server node on the host 192.168.200.201 with default settings.

    install-rke create -c calico -s worker -S 192.169.200.201 192.168.200.202
        Create a new RKE worker node that connects to the existing server node 192.168.200.201.
        Use CNI plugin calico. Host machine is 192.168.200.202.

    install-rke create -V v1.3.0 -u ubuntu 192.168.200.204
        Create a RKE server node with RKE version v1.3.0. Use "ubuntu" as user for ssh.
```

```
# ./install-rke2 help create
NAME
    install-rke2 create [COMMANDS] [OPTIONS] HOST

DESCRIPTION
    Create a new RKE2 node.

COMMANDS
    help - show this help

OPTIONS
    -c          CNI Plugin            (default: canal)
    -C          RKE2 Channel          (default: stable)
    -d          Debug mode            (default: false)
    -h          Display help
    -k          SSH Private Key       (default: /root/.ssh/id_rsa)
    -p          Profile (e.g. "cis")
    -s          Service type          (default: server)
    -S          Server to connect to  (default: none)
    -t          TLS-SAN hostname/ip   (default: none)
    -T          Token for auth        (default: foo)
    -u          SSH user              (default: sles)
    -V          RKE2 Version          (default: none)
    -x          Containerd SElinux    (default: false)
    -w          Write kubeconfig mode (default: 777)

EXAMPLES
    install-rke2 create 192.168.200.201
        Create a new RKE2 server node on host 192.168.200.201 with default settings.

    install-rke2 create -c calico -s agent -S 192.169.200.201:9345 -T secret 192.168.200.202
        Create a new RKE2 agent node that connects to existing server node 192.168.200.201.
        Use token "secret" and CNI calico. Host machine is 192.168.200.202.

    install-rke2 create -d -C testing -t lb.example.local 192.168.200.203
        Create a new RKE2 server node on host 192.168.200.203. Turn on debug information.
        Channel "testing" will be used and loabalancer FQDN will be added to TLS-SAN.

    install-rke2 create -V v1.28.6+rke2r1 -w 600 -u ubuntu 192.168.200.204
        Create a new RKE2 server node with version 1.28.6. Write kubeconfig so that only
        owner can read and write to it. Use "ubuntu" as user for ssh.
```

The removal also works the same way for all types of clusters:

```
# ./install-rke2 remove
NAME
    install-rke2 remove [COMMANDS] HOST

DESCRIPTION
    Uninstalls RKE2 completely from specified host.

COMMANDS
    help - show this help

OPTIONS
    -d          Debug mode            (default: false)
    -h          Display help
    -k          SSH Private Key       (default: /root/.ssh/id_rsa)
    -u          SSH user              (default: sles)

EXAMPLE
    install-rke2 remove -u sles 192.168.200.201
        Remove RKE2 from host 192.168.200.201. Use "sles" as user for ssh.
```

When configuring the loadbalancer you need to configure a server port and 
add nodes to the upstream. Loadbalancer can be used also for applications
like Rancher of course.

```
# ./manage-lb help
NAME
    manage-lb - Script to manage nginx based loadbalancer.

SYNOPSIS
    manage-lb COMMAND [OPTIONS]

DESCRIPTION
    A bash script to maintain the loadbalancer configuration.

COMMANDS
    add-port    - add server port
    remove-port - remove server port
    add-node    - add node(s) to specified server port
    remove-node - remove node(s) from specified server port
    list        - list nginx config
    reset       - remove any customization from nginx.conf
    help        - show this help or help for a subcommand
```

It is more comfortable to use kubecongfig from the management machine
although it works on master nodes as well. Merging is supported and 
by switching context to the preferred one, cluster can be easily managed
without the need to log into the nodes.

```
# ./manage-kubeconfig help
NAME
    manage-kubeconfig - Import, merge and remove kubeconfig files

SYNOPSIS
    manage-kubeconfig COMMAND [OPTIONS]

DESCRIPTION
    A bash script to manage kubeconfig files. It imports kubeconfig from the specifiend
    node, merges it with the main kubeconfig or removes the context.

COMMANDS
    import      - import new kubeconfig
    remove      - delete kubeconfig file
    help        - show this help or help for a subcommand
```

```# ./manage-kubeconfig help import
NAME
    manage-kubeconfig import [COMMANDS] [OPTIONS] HOST

DESCRIPTION
    Import kubeconfig from a host.

COMMANDS
    help - show this help

OPTIONS
    -f          Local filename           (default: /root/.kube/kc_$HOST)
    -h          Display help
    -k          SSH Private Key          (default: /root/.ssh/id_rsa)
    -m          Merge kubeconfig         (default: false)
    -n          New name/context         (default: $HOST)
    -p          Sudo password            (default: none)
    -S          Kubeconfig server/port   (default: $HOST:6443)
    -t          Type (k3s,rke1,rke2,k8s) (default: k8s)
    -u          SSH user                 (default: sles)

EXAMPLES
    manage-kubeconfig import 192.168.200.201
        Import k8s kubeconfig from the host 192.168.200.201 with default settings.

    manage-kubeconfig import -m -t rke2 -f ~/.kube/config_192.169.200.202 192.168.200.202
        Import RKE2 kubeconfig from node 192.168.200.201, merge it with the main.
        kubeconfig. Save downloaded file to ~/.kube/config_192.168.200.202.

    manage-kubeconfig import -m -u ubuntu -t k3s -S 192.168.200.200.sslip.io:6666 -n test 192.168.200.204
        Import K3S kubeconfig and merge it. Use ubuntu user for ssh connection.
        Rename default cluster and context to "test". Kubeconfig server is set to
        a loadbalancer FQDN set in TLS-SAN and server port for cluster API.
```

It is possible also easily install Rancher on top of Kubernetes cluster:

```
# ./install-rancher help create
NAME
    install-rancher create [COMMANDS] [OPTIONS] HOST

DESCRIPTION
    Set-up a new Rancher.

COMMANDS
    help - show this help

OPTIONS
    -a          Enable auditlog       (default: false)
    -c          Cert-manager version  (default: 1.14.1)
    -h          Display help
    -H          Set Rancher hostname
    -k          SSH Private Key       (default: /root/.ssh/id_rsa)
    -n          Namespace             (default: cattle-system)
    -p          Bootstrap password    (default: admin)
    -r          Chart repository      (default: prime)
    -R          Replica count         (default: 3)
    -u          SSH user              (default: sles)
    -V          Rancher version       (default: 2.7.13)

EXAMPLES
    install-rancher create 192.168.200.201
        Set up a new Rancher installation on a Kubernetes node 192.168.200.201 with default settings.

    install-rancher create -H 192.168.200.200.sslip.io -p linux -r stable -R 1 -V 2.8.4 192.168.200.202
        Set up a new Rancher installation with hostname 192.168.200.200.sslip.io and bootstrap password linux.
        Use "stable" Rancher chart repository. Run 1 replica and version v2.8.4.

    install-rancher create -d -r latest -H lb.example.local -u sles -a 192.168.200.203
        Set up a new Rancher installation with hostname lb.example.local. Enable audit log and debug mode.
        Use repository "latest" and VM user "sles".
```

### Notes

1. Due to large amount of configuration options, not all that are available
for K3S, RKE or RKE2 may be available via scripts. Feel free to add more.

2. Scripts perform a minimal option sanitization if any. Hence it is possible
to create setup that won't work or behave incorrectly. It is intentional,
to be able to reproduce bugs and test various configuration. Minimize set of
the options if things do not work and make sure you understand what are they doing.

3. Hack the scripts and add debug prints if something is not working or you
want to understand some functionality. It is the whole purpose of this toolkit
to provide easily hackable code for tweaking and debugging. Add line calling
function `prepare_ssh_payload` just before ssh is called to see the payload.
If anything from payload doesn't work as expected, log into the node and 
execute the line manually to get more information about the problem.



