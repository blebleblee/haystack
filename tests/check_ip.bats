#!/usr/bin/env bats

VMNAME=batstestvm

function create_test_vm ()
{
    local -r var="$1"
    run ./kvm-install-vm create -t ${var} -I "192.168.200.222/23" -G "192.168.200.1" -R "192.168.200.2" ${VMNAME}-${var}
    [ "$status" -eq 0 ]
}

function remove_test_vm ()
{
    local -r var="$1"
    run ./kvm-install-vm remove ${VMNAME}-${var}
    [ "$status" -eq 0 ]
}

@test "Install VM (CentOS 8) - $VMNAME-centos8" {
    create_test_vm centos8
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (CentOS 8) - $VMNAME-centos8" {
    remove_test_vm centos8
}

@test "Install VM (CentOS 7) - $VMNAME-centos7" {
    create_test_vm centos7
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (CentOS 7) - $VMNAME-centos7" {
    remove_test_vm centos7
}

@test "Install VM (Fedora 38) - $VMNAME-fedora38" {
    create_test_vm fedora38
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Fedora 38) - $VMNAME-fedora38" {
    remove_test_vm fedora38
}

@test "Install VM (Fedora 39) - $VMNAME-fedora39" {
    create_test_vm fedora39
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Fedora 39) - $VMNAME-fedora39" {
    remove_test_vm fedora39
}

@test "Install VM (Ubuntu 18.04) - $VMNAME-ubuntu1804" {
    create_test_vm ubuntu1804
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Ubuntu 18.04) - $VMNAME-ubuntu1804" {
    remove_test_vm ubuntu1804
}

@test "Install VM (Ubuntu 20.04) - $VMNAME-ubuntu2004" {
    create_test_vm ubuntu2004
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Ubuntu 20.04) - $VMNAME-ubuntu2004" {
    remove_test_vm ubuntu2004
}

@test "Install VM (Ubuntu 22.04) - $VMNAME-ubuntu2204" {
    create_test_vm ubuntu2204
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Ubuntu 22.04) - $VMNAME-ubuntu2204" {
    remove_test_vm ubuntu2204
}

@test "Install VM (Ubuntu 25.04) - $VMNAME-ubuntu2504" {
    create_test_vm ubuntu2504
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Ubuntu 25.04) - $VMNAME-ubuntu2504" {
    remove_test_vm ubuntu2504
}

@test "Install VM (Debian 12) - $VMNAME-debian12" {
    create_test_vm debian12
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Debian 12) - $VMNAME-debian12" {
    remove_test_vm debian12
}

@test "Install VM (openSUSE Leap 15.4) - $VMNAME-opensuse154" {
    create_test_vm opensuse154
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (openSUSE Leap 15.4) - $VMNAME-opensuse154" {
    remove_test_vm opensuse154
}

@test "Install VM (openSUSE Leap 15.5) - $VMNAME-opensuse155" {
    create_test_vm opensuse155
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (openSUSE Leap 15.5) - $VMNAME-opensuse155" {
    remove_test_vm opensuse155
}

@test "Install VM (openSUSE Leap 15.6) - $VMNAME-opensuse156" {
    create_test_vm opensuse156
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (openSUSE Leap 15.6) - $VMNAME-opensuse156" {
    remove_test_vm opensuse155
}

@test "Install VM (SUSE Linux Micro 6.0) - $VMNAME-micro6" {
    create_test_vm micro6
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (SUSE Linux Micro 6.0) - $VMNAME-micro6" {
    remove_test_vm micro6
}

@test "Install VM (SUSE Linux Enterprise 15 SP5) - $VMNAME-sles155" {
    create_test_vm sles155
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (SUSE Linux Enterprise 15 SP5) - $VMNAME-sles155" {
    remove_test_vm sles155
}

@test "Install VM (SUSE Linux Enterprise 15 SP6) - $VMNAME-sles156" {
    create_test_vm sles156
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (SUSE Linux Enterprise 15 SP6) - $VMNAME-sles156" {
    remove_test_vm sles156
}

@test "Install VM (SUSE Linux Enterprise 15 SP7) - $VMNAME-sles157" {
    create_test_vm sles157
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (SUSE Linux Enterprise 15 SP7) - $VMNAME-sles157" {
    remove_test_vm sles157
}

@test "Install VM (Rocky 9.3) - $VMNAME-rocky93" {
    create_test_vm rocky93
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (Rocky 9.3) - $VMNAME-rocky93" {
    remove_test_vm rocky93
}

@test "Install VM (RHEL 7.9) - $VMNAME-rhel79" {
    create_test_vm rhel79
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (RHEL 7.9) - $VMNAME-rhel79" {
    remove_test_vm rhel79
}

@test "Install VM (RHEL 8.9) - $VMNAME-rhel89" {
    create_test_vm rhel89
    [[ "${lines[6]}" =~ "IP address: 192.168.200.222" ]]
    [ "$status" -eq 0 ]
}

@test "Delete VM (RHEL 8.9) - $VMNAME-rhel89" {
    remove_test_vm rhel89
}

