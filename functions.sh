#!/bin/bash
set -e

function set_defaults ()
{
    RIBDIR=$(dirname "$(readlink -f "$0")")

    # Defaults are set here. Override using command line arguments.
    AUTOSTART=false                 # Automatically start VM at boot time
    CPUS=2                          # Number of virtual CPUs
    FEATURE=host-passthrough        # Use host cpu features to the guest
    MEMORY=4096                     # Amount of RAM in MB
    DISK_SIZE="20"                  # Disk Size in GB
    DNSDOMAIN=example.local         # DNS domain
    GRAPHICS=spice                  # Graphics type or "auto"
    RESIZE_DISK=false               # Resize disk (boolean)
    IMAGEDIR=${HOME}/virt/images    # Directory to store images
    VMDIR=${HOME}/virt/vms          # Directory to store virtual machines
    RECIPEDIR="${RIBDIR}/recipes"   # Recipes directory
    BRIDGE=br0                      # Hypervisor bridge
    PUBKEY=${HOME}/.ssh/id_rsa.pub  # SSH public key
    DISTRO=sles155                  # Distribution
    MACADDRESS=""                   # MAC Address
    PORT=-1                         # Console port
    TIMEZONE=UTC                    # Timezone
    ADDITIONAL_USER=${USER}         # User
    ASSUME_YES=0                    # Assume yes to prompts
    ASSUME_NO=0                     # Assume no to prompts
    VERBOSE=0                       # Verbosity
    LOCALURL="https://cml.2464.cz/iso/cloud_images" # Location of manually downloaded images


    # Reset OPTIND
    OPTIND=1

    # Advanced hypervisor options. Override in ~/.kivrc if needed.
    NETWORK_MODEL=virtio
    NETWORK_EXTRA=""
    DISK_BUS=virtio
    DISK_EXTRA=""
    DISK_FORMAT=qcow2
    CI_DISK_SIZE_DEFAULT="1"
    CI_ISO_EXTRA=""
    GRAPHICS_LISTEN="0.0.0.0"      # Allow to connect to VNC from external machine
    GRAPHICS_EXTRA=""
    VIRT_INSTALL_EXTRA=""
    #    Network configuration defaults. Override in ~/.kivrc if needed.
    #    NET_IP="192.168.200.201/23"
    #    NET_GW="192.168.200.1"
    #    NET_DNS="192.168.200.2"

    # Autoyast/SLES configuration defaults
    RMT="http://cml.2464.cz"
    # RMT server fingerprint
    # check: openssl s_client -connect cml.2464.cz:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint  -sha1 -noout -in /dev/stdin
    RMTFINGER="3C:6E:A5:C7:46:11:84:88:1B:1A:46:DF:3A:46:7B:D8:AD:82:85:21"

    # Kubernetes defaults
    KUBEDIR="${HOME}/.kube"
    KUBECONFIG="${KUBEDIR}/config"
    KUBETYPE=""
    CNI="canal"
    CHANNEL="stable"
    DEBUG=0
    SRVTYPE="server"
    MODE="777"
    PROFILE=""
    PRIVKEY="${HOME}/.ssh/id_rsa"
    CLUSTER_INIT=0
    RKE_VERSION="v1.5.6"
    LOGIN_USER="sles"
    MERGE=0
    SELINUX=0

    # Loadbalancer defaults
    NGINX_CONF="/etc/nginx/nginx.conf"
    MAX_FAILS="3"
    FAIL_TIMEOUT="5s"

    # Rancher defaults
    RANCHER_NS="cattle-system"
    RANCHER_REPO="prime"
    RANCHER_AUDIT=0
    RANCHER_CERTMAN="1.14.1"
    RANCHER_PW="admin"
    RANCHER_REPLICA="3"
    RANCHER_VERSION="2.7.13"

    # Harvester defaults
    BOND=0
    JOIN=0
    JOIN_SERVER=""
    TOKEN="foo"
    VIP_IP="192.168.200.200"
    NET_NTP="192.168.200.1"
    ZONE="zone1"
    NVME_DISKSIZE="100"

    # Harvester node deployment specs
    if [ ! -z "${INSTALL_HARV}"  ]
    then
        CPUS=4                       # Number of virtual CPUs
        MEMORY=16384                 # Amount of RAM in MB
        DISK_SIZE="250"              # Disk Size in GB
        DISTRO=harv121               # Distribution
    fi
}

function set_custom_defaults ()
{
    # Source custom defaults, if set
    if [ -f ~/.kivrc ];
    then
        source "${HOME}"/.kivrc
    fi
}

# Console output colors
bold() { echo -e "\e[1m$@\e[0m" ; }
red() { echo -e "\e[31m$@\e[0m" ; }
green() { echo -e "\e[32m$@\e[0m" ; }
yellow() { echo -e "\e[33m$@\e[0m" ; }

die() { red "ERR: $@" >&2 ; exit 2 ; }
silent() { "$@" > /dev/null 2>&1 ; }
output() { echo -e "- $@" ; }
outputn() { echo -en "- $@ ... " ; }
ok() { green "${@:-OK}" ; }

pushd() { command pushd "$@" >/dev/null ; }
popd() { command popd "$@" >/dev/null ; }

# Join zero or more strings into a delimited string.
function join ()
{
    local sep="$1"
    if [ $# -eq 0 ]; then
        return
    fi
    shift
    while [ $# -gt 1 ]; do
        printf "%s%s" "$1" "$sep"
        shift
    done
    printf "%s\n" "$1"
}

# Print an optional name=value[,value,..] parameter.
# Prints nothing if no values are given.
function param ()
{
    if [ $# -lt 2 ] || [ -z "$2" ] ; then
        return # skip empty value
    fi
    local name="$1"
    shift
    local values="$(join ',' "$@")"
    printf "%s=%s\n" "$name" "$values"
}

# Output a command, one argument per line.
function output_command ()
{
    local line_cont=$'  \\ \n     '
    local command_lines=$(join "$line_cont" "$@")
    printf "    %s\n" "$command_lines"
}

# Detect OS and set wget parameters
function set_wget ()
{
    if [ -f /etc/fedora-release ]
    then
        WGET="wget --quiet --show-progress"
    else
        WGET="wget"
    fi
}

function check_ssh_key ()
{
    local key
    if [ -z "${PUBKEY}" ]; then
        # Try to find a suitable key file.
        for key in ~/.ssh/id_{rsa,dsa,ed25519}.pub; do
            if [ -f "$key" ]; then
                PUBKEY="$key"
                break
            fi
        done
    fi

    if [ ! -f "${PUBKEY}" ]
    then
        # Check for existence of a pubkey, or else exit with message
        die "Please generate an SSH keypair using \"ssh-keygen -t rsa\" or specify one with the \"-k\" flag."
    else
        # Place contents of $PUBKEY into $KEY
        KEY=$(<"${PUBKEY}")
    fi
}

function check_os_variant ()
{
    if [[ ${OS_VARIANT} != auto ]]; then
        osinfo-query os short-id="${OS_VARIANT}" >/dev/null \
            || die "Unknown OS variant '${OS_VARIANT}'. Please update your osinfo-db. "\
            "See https://libosinfo.org/download for more information."
    fi
}

function domain_exists ()
{
    virsh dominfo "${1}" > /dev/null 2>&1 \
        && DOMAIN_EXISTS=1 \
        || DOMAIN_EXISTS=0
}

function storpool_exists ()
{
    virsh pool-info "${1}" > /dev/null 2>&1 \
        && STORPOOL_EXISTS=1 \
        || STORPOOL_EXISTS=0
}

function set_sudo_group ()
{
    case "${DISTRO}" in
        centos*|fedora*|rocky*|opensuse*|sles*|rhel*|micro* )
            SUDOGROUP="wheel"
            ;;
        ubuntu*|debian* )
            SUDOGROUP="sudo"
            ;;
        *)
            die "OS not supported."
            ;;
    esac
}

function set_cloud_init_remove ()
{
    case "${DISTRO}" in
        centos8|centos7|fedora*|rocky*|ubuntu*|debian*|opensuse*|sles*|rhel* )
            CLOUDINITDISABLE="systemctl disable cloud-init.service"
            ;;
    esac
}

function set_network_restart_cmd ()
{
    case "${DISTRO}" in
        ubuntu*|debian*)    NETRESTART="systemctl stop networking && systemctl start networking" ;;
        *)                  NETRESTART="systemctl stop network && systemctl start network" ;;
    esac
}

function set_network_intf_name ()
{
    case "${DISTRO}" in
        ubuntu*|debian*)    NET_INTF="enp1s0" ;;
        *)                  NET_INTF="eth0" ;;
    esac
}

function check_delete_known_host ()
{
    output "Checking for ${IP} in known_hosts file"
    grep -q "${IP}" "${HOME}"/.ssh/known_hosts \
        && outputn "Found entry for ${IP}. Removing" \
        && (sed --in-place "/^${IP}/d" ~/.ssh/known_hosts && ok ) \
        || output "No entries found for ${IP}"
}

# Command wrapper to output the command to be run in verbose
# mode and redirect stdout and stderr to the vm log file.
function run ()
{
    local msg="$1"
    shift
    if [ "${VERBOSE}" -eq 1 ]
    then
        output "$msg with the following command"
        output_command "$@"
    else
        outputn "$msg"
    fi
    ( "$@" &>> "${VMNAME}".log && ok )
}

function check_vmname_set ()
{
    [ -n "${VMNAME}" ] || die "VMNAME not set."
}

function delete_vm ()
{
    # Check if domain exists and set DOMAIN_EXISTS variable.
    domain_exists "${VMNAME}"

    # Check if storage pool exists and set STORPOOL_EXISTS variable.
    storpool_exists "${VMNAME}"

    check_vmname_set

    if [ "${DOMAIN_EXISTS}" -eq 1 ]
    then
        outputn "Destroying ${VMNAME} domain"
        virsh destroy --graceful "${VMNAME}" > /dev/null 2>&1 \
            && ok \
            || yellow "(Domain is not running.)"

        outputn "Undefining ${VMNAME} domain"
        virsh undefine --managed-save --snapshots-metadata "${VMNAME}" > /dev/null 2>&1 \
            && ok \
            || die "Could not undefine domain."
    else
        output "Domain ${VMNAME} does not exist"
    fi

    [[ -d ${VMDIR}/${VMNAME} ]] && DISKDIR=${VMDIR}/${VMNAME} || DISKDIR=${IMAGEDIR}/${VMNAME}
    [ -d "${DISKDIR}" ] \
        && outputn "Deleting ${VMNAME} files" \
        && rm -rf "${DISKDIR}" \
        && ok

    if [ "${STORPOOL_EXISTS}" -eq 1 ]
    then
        outputn "Destroying ${VMNAME} storage pool"
        virsh pool-destroy "${VMNAME}" > /dev/null 2>&1 && ok
    else
        output "Storage pool ${VMNAME} does not exist"
    fi
}

function extract_subnet_mask() {
    local IP_CIDR=$1
    NET_ADDR=$(echo "${IP_CIDR}" | awk -F'/' '{print $1}')

    local CIDR=$(echo "${IP_CIDR}" | awk -F'/' '{print $2}')
    VALUE=$(( 0xffffffff ^ ((1 << (32 - ${CIDR})) - 1) ))
    NET_MASK=$(echo "$(( (VALUE >> 24) & 0xff )).$(( (VALUE >> 16) & 0xff )).$(( (VALUE >> 8) & 0xff )).$(( VALUE & 0xff ))")
}
