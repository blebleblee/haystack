## Rancher Infrastructure Builder (rib)

RIB (Rancher Infrastructure Builder) is a bash script that uses power of standalone install
scripts to create and deploy VMs, install Kubernetes, deploy Harvester into VMs and other
tasks that would be otherwise performed manually. It basically saves time and prevents 
mistakes that could happen due to large amount of variables and options.

It uses so called recipes that define what and how will be installed. Such a "disposable
infrastructure" can be installed over and over to deliver the same environment for 
testing, learning or debugging. All recipes are located in /recipe directory.
Each recipe is basically a yaml file describing the infrastructure - nodes, harvester
nodes, kubernetes etc.

### Recipes
Each recipe uses anchors and aliases to prevent repetition of the same configuration.
An anchor is for example default value, see below. Alias then refers to the anchor 
section and expands the data. If you'd like to see full yaml of a recipe file use:
```sh
yq e '. | explode(.)' recipes/single_rke2.rcp
```

#### Default values
These are default sections for a node network and a vm. It is an example how to write
recipe so feel free to change them and create your own ones.

```yaml
...
default_network: &default_network
  gw: 192.168.143.1                           # Default gateway ip address
  dns: 192.168.200.2                          # DNS resolver ip address
  bridge: br-rancher                          # VM node bridge
  domain: example.local                       # Default domain
  netmask: 24                                 # VM network mask

default_vm: &default_vm
  vcpu: 2                                     # Default vcpu count for a node
  disk: 20                                    # Default VM root disk size in GB
  memory: 4096                                # Default VM memory in MB
...

...
nodes:
  - name: node1                               # Node name
    network:
      <<: *default_network                    # Alias to default network anchor
      ip: &node1_ip 192.168.143.10            # Node IP address and anchor
    vm:
      <<: *default_vm                         # Alias to default VM anchor
    kubernetes:
      <<: *default_kubernetes                 # Alias to kubernetes anchor settings
      servicetype: server                     # Node service type (server, agent)
    <<: *default_node                         # Alias to default node settings
   ...
```


An example recipe file for single RKE2 node deployment with static up address:
```yaml
recipe_desc: |
  Example recipe file.  Single RKE2 node.
  Loadbalancer is configured for RKE2.
  Requirements: CPU: 2, Memory: 4GB, Disk: 20GB
  Versions: RKE2 1.26.13+rke2r1
  Network: 192.168.143.1/24 (br-rancher)

default_network: &default_network
  gw: 192.168.143.1                           # Default gateway ip address
  dns: 192.168.200.2                          # DNS resolver ip address
  bridge: br-rancher                          # VM node bridge
  domain: example.local                       # Default domain
  netmask: 24                                 # VM network mask

default_vm: &default_vm
  vcpu: 2                                     # Default vcpu count for a node
  disk: 20                                    # Default VM root disk size in GB
  memory: 4096                                # Default VM memory in MB

default_kubernetes: &default_kubernetes
  version: v1.26.13+rke2r1                    # RKE2 version
  type: rke2                                  # Kubernetes type
  channel: stable                             # RKE2 channel (stable,latest)
  cni: calico                                 # CNI plugin
  debug: true                                 # Turn debug on/off
  selinux: false                              # Enable or disable selinux support
  privkey: /root/.ssh/id_rsa                  # Path to ssh key for logging to VM
  tlssan: 192.168.143.1.sslip.io              # TLS-SAN entries in RKE2 config
  token: secrets                              # RKE2 token
  mode: 600                                   # kubeconfig ACL

default_node: &default_node
  distro: opensuse155                         # Image distro name
  user: opensuse                              # Default user

nodes:
  - name: node1                               # Node name
    network:
      <<: *default_network                    # Alias to default network anchor
      ip: &node1_ip 192.168.143.10            # Node IP address and anchor
    vm:
      <<: *default_vm                         # Alias to default VM anchor
    kubernetes:
      <<: *default_kubernetes                 # Alias to kubernetes anchor settings
      servicetype: server                     # Node service type (server, agent)
    <<: *default_node                         # Alias to default node settings
    join: false                               # Cluster join (true, false)

loadbalancer:                                 # Loadbalancer definition
  - port: 6443                                # Server port number
    upstream: rke2_api                        # Upstream name
    nodes:
      node1: *node1_ip                        # Format is node: alias to node ip
    nodeport: 6443                            # Node port number
  - port: 9345
    upstream: rke1_mgmt
    nodes:
      node1: *node1_ip
    nodeport: 9345

kubeconfig:
  - name: rke_node1                          # Rancher configuration
    <<: *default_node                        # Include node anchor
    ip: *node1_ip                            # Alias to Kubernetes node ip
    file: ~/.kube/kc_192.168.143.10          # Local filename
    merge: true                              # Merge kubeconfig
    context: rke2_192.168.143.10             # Kubeconfig context
    server: 192.168.143.10:6443              # Kubeconfig server/port
    type: rke2                               # Cluster type
```
### Usage
RIB uses the same structure of commands as other scripts in the toolkit:
```sh
# ./rib help
NAME
    rib - Rancher Infrastructure Builder creates and removes Rancher product deployments
    on a local KVM hypervisor. It starts/stops already built environments.

SYNOPSIS
    rib COMMAND [OPTIONS]

DESCRIPTION
    RIB or Rancher Infrastructure Builder is a tool to easily create and tear down infrastructure,
    install Rancher products like RKE2 clusters or Harvester on a local KVM hypervisor.
    It can also start/stop existing deployments easily.

COMMANDS
    create      - create a new infrastructure
    remove      - delete deployed infrastructure
    start       - start existing infrastructure
    stop        - stop existing infrastructure
    list        - list all available recipes and descriptions
    help        - show this help or help for a subcommand
```

```sh
# ./rib help create
NAME
    rib create [COMMANDS] [OPTIONS] RECIPE

DESCRIPTION
    Create a new infrastructure based on a recipe.

COMMANDS
    help - show this help

OPTIONS
    -y          Assume yes to prompts (default: false)
    -n          Assume no to prompts  (default: false)

EXAMPLES
    rib create foo
        Create infrastructure from the recipe"foo".
```

# Recipe file structure
Following is the set of values currently supported in recipes.

## Node configuration
Define the configuration for individual nodes.

```yaml
nodes:
  - distro: "ubuntu"                # "ubuntu", "centos", etc.
    user: "ubuntu"                  # Username for the VM
    vm:
      vcpu: 2                       # Number of virtual CPUs
      disk: "20G"                   # Disk size (e.g., "20G" for 20 GB)
      memory: "4096M"               # Memory size (e.g., "4096M" for 4 GB)
    network:
      dns: "8.8.8.8"                # DNS server IP
      gw: "192.168.1.1"             # Gateway IP
      domain: "example.com"         # Domain name
      bridge: "br0"                 # Network bridge name
      ip: "192.168.1.100"           # Static IP address
      netmask: "255.255.255.0"      # Network mask
    name: "node-1"                  # Name of the VM
```

## Kubernetes configuration
Define the settings for Kubernetes clusters. Check each install script for
supported options of each type (RKE/RKE2/K3S).

```yaml
kubernetes:
  user: "ubuntu"                    # Username for the VM
  network:
    ip: "192.168.1.101"             # Static IP address
  join: "yes"                       # "yes" or "no"
  kubernetes:
    tlssan: "192.168.1.101"         # TLS SAN (Subject Alternative Name)
    channel: "stable"               # Update channel (e.g., "stable", "latest")
    cni: "canal"                    # Container Network Interface (e.g., "canal", "flannel")
    type: "rke2"                    # Kubernetes type (e.g., "rke2", "k3s", "rke")
    profile: "default"              # Profile name
    servicetype: "ClusterIP"        # Service type (e.g., "ClusterIP", "NodePort")
    token: "my-token"               # Token for joining the cluster
    debug: "false"                  # Enable debug mode ("true" or "false")
    selinux: "false"                # Enable SELinux ("true" or "false")
    privkey: "/path/to/private/key" # Path to private key
    version: "v1.21.4"              # Kubernetes version
    mode: "server"                  # Mode ("server" or "agent")
    server: "192.168.1.101"         # Server IP address
    clusterinit: "true"             # Cluster initialization ("true" or "false")
```

## Harvester configuration
Define the settings for Harvester clusters.

```yaml
harvester:
  distro: "harvester"               # Distribution type (e.g., "harvester")
  vm:
    vcpu: 4                         # Number of virtual CPUs
    disk: "50G"                     # Disk size (e.g., "50G" for 50 GB)
    memory: "8192M"                 # Memory size (e.g., "8192M" for 8 GB)
    nvme: "true"                    # Enable NVMe ("true" or "false")
    nvmesize: "200G"                # NVMe size (e.g., "200G" for 200 GB)
  network:
    dns: "8.8.8.8"                  # DNS server IP
    gw: "192.168.1.1"               # Gateway IP
    domain: "example.com"           # Domain name
    bond: "bond0"                   # Network bonding name
    bridge: "br0"                   # Network bridge name
    ip: "192.168.1.102"             # Static IP address
    netmask: "255.255.255.0"        # Network mask
    ntp: "pool.ntp.org"             # NTP server
    proxy: "http://proxy.example.com" # Proxy URL
    vip: "192.168.1.103"            # Virtual IP address
    addnic: "eth1"                  # Additional NIC
    addnicbr: "br1"                 # Additional NIC bridge
  ssl:
    ca: "/path/to/ca.crt"           # Path to CA certificate
    key: "/path/to/key.key"         # Path to SSL key
    cert: "/path/to/cert.crt"       # Path to SSL certificate
  join: "true"                      # Join existing cluster ("true" or "false")
  join_server: "192.168.1.103"      # IP of the server to join
  role: "worker"                    # Role in the cluster (e.g., "worker", "master")
  token: "harvester-token"          # Token for joining the cluster
  zone: "zone1"                     # Zone name
  skipchecks: "false"               # Skip checks ("true" or "false")
  name: "harvester-node-1"          # Name of the VM
```

## Rancher configuration
Define the settings for Rancher deployment.

```yaml
rancher:
  user: "ubuntu"                    # Username for the VM
  password: "password123"           # Bootstrap password
  ip: "192.168.1.104"               # IP address of the server node
  repo: "rancher/rancher"           # Docker repository
  hostname: "rancher.example.com"   # Rancher hostname
  certman: "true"                   # Enable certificate manager ("true" or "false")
  namespace: "cattle-system"        # Kubernetes namespace
  version: "v2.6.3"                 # Rancher version
  replica: 3                        # Number of replicas
  audit: "true"                     # Enable audit logs ("true" or "false")
```

## Kubeconfig configuration
Define the settings for kubeconfig files.

```yaml
kubeconfig:
  user: "ubuntu"                    # Username for the VM
  file: "/home/ubuntu/.kube/config" # Path to kubeconfig file
  ip: "192.168.1.105"               # Static IP address
  context: "default"                # Kubernetes context
  type: "admin"                     # User type (e.g., "admin", "user")
  server: "https://192.168.1.105:6443" # Kubernetes API server URL
  merge: "true"                     # Merge with existing kubeconfig ("true" or "false")
  sudopass: "password123"           # Sudo password (for example in Harvester)
```


