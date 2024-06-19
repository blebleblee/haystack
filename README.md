# Haystack Toolkit

This project provides a comprehensive set of scripts and configurations to deploy VMs, RKE/RKE2/K3S clusters on top of them, and Rancher for managing Kubernetes clusters. Additionally, it includes scripts to deploy Harvester into VMs, manage kubeconfigs, and configure the load balancer on the host system.

## Table of Contents

- [Hardware Requirements](#hardware-requirements)
- [Documentation](#documentation)
- [Example Usage](#example-usage)
  - [Deploy VMs](#deploy-vms)
  - [Configure Load Balancer](#configure-load-balancer)
  - [Deploy RKE/RKE2/K3S](#deploy-rke-rke2-k3s)
  - [Deploy Rancher](#deploy-rancher)
  - [Deploy Harvester](#deploy-harvester)
  - [Manage Kubeconfigs](#manage-kubeconfigs)
  - [Automation with RIB](#rib-automation) 
- [License](#license)

## Hardware Requirements

Depending on what you plan to deploy you will need the following:

```
Single VM: 1 vCPU core, 2 GB RAM, 20 GB disk space
Single VM with RKE/RKE2/K3S: 2 vCPU cores, 4 GB RAM, 20 GB disk space
Harvester VM: 8-16 vCPU cores, 16-32GB RAM, 250-300 GB or more disk space
```

HA deployment for example:

```
3 x RKE2 control plane nodes - 6 vCPU cores, 12 GB RAM, 60 GB disk space
3 x RKE2 worker nodes - 6 vCPU cores, 12 GB RAM, 60 GB disk space
```

For "Ranchester" which is a RKE2 cluster with Rancher and standalone Harvester
node, I recommend 8 vCPU cores or more, 32 GB RAM and 400 GB disk space.

If you plan to run VMs in Harvester make sure you have nested virtualization enabled (default on OpenSUSE 15.5/15.6).

## Documentation

For detailed installation instructions, please refer to the `/docs/` directory:

- [Host Installation](docs/README-HOSTPREPARE.md)
- [KVM VM Installation](docs/README-KVM-INSTALL.md)
- [Harvester Installation](docs/README-HARVESTER.md)
- [K8S Installation](docs/README-INSTALL-TOOLS.md)
- [RIB Automation](docs/README-RIB.md)

All script should be executed as user "root" therefore use them only on a machine without any important data.
I am not responsible for any data loss caused by an incorrect script usage.

## Example usage

If you plan to use existing installed system, make sure to read [Host Installation](docs/README-HOSTPREPARE.md) and review the scripts.
You will need to have libvirt installed and running, some virtual bridges and passwordless ssh key. All commands are executed as "root" user.

Ideally, a fresh install of OpenSUSE 15.5 or 15.6 should be performed then follow the docs/run `tools/hostprepare.sh` script with customized settings to prepare the host system.

### Deploy VMs

To deploy virtual machines, use the provided script `kvm-install-vm`.

```sh
./kvm-install-vm create -c 2 -m 4096 -d 30 foo
```

This will deploy VM named "foo" with 2 vCPU cores, 4GB RAM and 30GB disk. It will use defaults for any other options.
Since there is no static address specified, VM will acquire IP address from DHCP server over the bridge that it is connected to and you will see this line:

```sh
- SSH to foo: 'ssh sles@192.168.200.200' or 'ssh sles@foo'
```
You can log in and use the VM.

### Configure Loadbalancer

You can install Kubernetes into this VM but if you need to add multiple nodes (for HA for example), you may want to configure a loadbalancer. It runs as an nginx service on the host.
Use the script `manage-lb` to add the port and the node to port's upstream. You may want to reset previous loadbalancer configuration. 

For RKE2 we need two ports - 6443 and 9345:

```sh
./manage-lb reset
./manage-lb add-port -P 6443 -U rke2_api
./manage-lb add-port -P 9345 -U rke2_mgmt
./manage-lb add-node -P 6443 -N 192.168.200.200
./manage-lb add-node -P 9345 -N 192.168.200.200
```
Check the nginx loadbalancer configuration with `manage-lb list`:
```sh
- Reading file /etc/nginx/nginx.conf ... OK
load_module /usr/lib64/nginx/modules/ngx_stream_module.so;
worker_processes 4;
worker_rlimit_nofile 40000;
events {
    worker_connections 8192;
}

stream {
    server {
        listen 9345;
        proxy_pass rke2_mgmt;
    }
    upstream rke2_mgmt {
        server 192.168.200.200:9345 max_fails=3 fail_timeout=5s;
        least_conn;
    }
    server {
        listen 6443;
        proxy_pass rke2_api;
    }
    upstream rke2_api {
        server 192.168.200.200:6443 max_fails=3 fail_timeout=5s;
        least_conn;
    }

}
```
For temporary cluster, for example for testing, this configuration is fine. For more persistent setup use static ip addresses. Bear in mind that Kubernetes are not designed to work on systems that change the ip addresses. 

The toolkit totally allows you to do that and more. It's intentional, to provide safe testing and learning environment. However, make sure to consult the official documentation to make sure your configuration is fine.

### Deploy RKE/RKE2/K3S

Deploy your Kubernetes cluster using install scripts, for example `install-rke2`:

```sh
./install-rke2 create -t 192.168.201.16.sslip.io 192.168.200.200
```

When installation is finished you will see `kubectl get nodes` output:
```sh
- Verifying the cluster...
NAME   STATUS   ROLES                       AGE   VERSION
foo    Ready    control-plane,etcd,master   62s   v1.28.10+rke2r1
```
The parameter "-t" ensures that our host is added to TLS-SAN section of the configuration so that it is possible to connect to the RKE2 cluster via loadbalancer.
It is required only if you want to add more nodes later to have a full HA cluster. 

### Deploy Rancher

Deploy Rancher on top of your Kubernetes cluster using the script `install-rancher`. We want to access Rancher via our loadbalancer and add more nodes later to scale up the deployment so we need to add more ports on the loadbalancer.
```sh
./manage-lb add-port -P 80 -U rancher_http
./manage-lb add-port -P 443 -U rancher_https
./manage-lb add-node -P 80 -N 192.168.200.200
./manage-lb add-node -P 443 -N 192.168.200.200
```

Then Install Rancher:
```sh
./install-rancher create -R 1 -H 192.168.201.16.sslip.io -V 2.8.4 192.168.200.200
```
The command will install Rancher on node with ip address 192.168.200.200 but configure hostname as 192.168.201.16.sslip.ip (our host/lb ip with .sslip.io domain, as it must be a resolvable FQDN).
It will install one replica deployment of Rancher v2.8.4, which can be scaled up later with more nodes.

After a moment we can log in with the bootstrap password 'admin' and use Rancher.

To add more nodes, repeat the process but install new node in join mode, for example like this to add an agent node:
```sh
./kvm-install-vm create -c 2 -m 4096 -d 30 foo2
./install-rke2 create -s agent -S 192.168.201.16.sslip.io:9345 192.168.200.202
```
For server nodes you also need to add the nodes to the loadbalancer. Also keep the number of nodes odd as it's required for the quorum to work.

### Deploy Harvester

Deploy Harvester so that you can run additional Kubernetes clusters from your Rancher somewhere. Use script `kvm-install-harv`:

```sh
./kvm-install-harv create -c 8 -m 32768 -d 400 foo3
```
Once Harvester node is up and running you can log in with bootstrap password "password" and configure network, upload images, import cluster to Rancher and start your guest clusters.
Consult Rancher and Harvester documentation on how to perform these steps:
https://docs.harvesterhci.io/v1.3/rancher/rancher-integration


### Manage Kubeconfigs

For convenience you can import kubeconfigs from RKE2 node and Harvester to the host and merge them in order to use the context of each cluster. This is the task of script `manager-kubeconfig`:

```sh
./manage-kubeconfig import -t rke2 -m 192.168.200.200
```
Then you can use the context and work with the cluster from the host:
```sh
# kubectl config get-contexts
CURRENT   NAME                   CLUSTER                AUTHINFO               NAMESPACE
*         192.168.200.200        192.168.200.200        192.168.200.200
          harv_192.168.144.100   harv_192.168.144.100   harv_192.168.144.100
          k3s_192.168.143.10     k3s_192.168.143.10     k3s_192.168.143.10
          k3s_192.168.143.20     k3s_192.168.143.20     k3s_192.168.143.20
          rke2_192.168.143.10    rke2_192.168.143.10    rke2_192.168.143.10
          rke2_192.168.143.20    rke2_192.168.143.20    rke2_192.168.143.20
          rke_192.168.143.10     rke_192.168.143.10     rke_192.168.143.10

# kubectl get nodes
NAME   STATUS   ROLES                       AGE   VERSION
foo    Ready    control-plane,etcd,master   20m   v1.28.10+rke2r1
```
Switch to another context:
```sh
./kubectl config use-context harv_192.168.144.100
Switched to context "harv_192.168.144.100".
```

### Automation with RIB

Automating all tasks performed above is possible with the `rib` script.
It works with so called recipes that describe deployments in yaml format. See available recipes with:

```sh
./rib list
```

Deploy recipe single_rke2 with:
```sh
./rib create -y single_rke2
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

