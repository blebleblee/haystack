#!/usr/bin/env bats

VMNAME=batstestvm

function create_test_vm ()
{
    local -r var="$1"
    run ./kvm-install-vm create -t ${var} ${VMNAME}-${var}
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
}

@test "Delete VM (CentOS 8) - $VMNAME-centos8" {
    remove_test_vm centos8
}

@test "Install VM (CentOS 7) - $VMNAME-centos7" {
    create_test_vm centos7
}

@test "Delete VM (CentOS 7) - $VMNAME-centos7" {
    remove_test_vm centos7
}

@test "Install VM (Fedora 38) - $VMNAME-fedora38" {
    create_test_vm fedora38
}

@test "Delete VM (Fedora 38) - $VMNAME-fedora38" {
    remove_test_vm fedora38
}

@test "Install VM (Fedora 39) - $VMNAME-fedora39" {
    create_test_vm fedora39
}

@test "Delete VM (Fedora 39) - $VMNAME-fedora39" {
    remove_test_vm fedora39
}

@test "Install VM (Ubuntu 18.04) - $VMNAME-ubuntu1804" {
    create_test_vm ubuntu1804
}

@test "Delete VM (Ubuntu 18.04) - $VMNAME-ubuntu1804" {
    remove_test_vm ubuntu1804
}

@test "Install VM (Ubuntu 20.04) - $VMNAME-ubuntu2004" {
    create_test_vm ubuntu2004
}

@test "Delete VM (Ubuntu 20.04) - $VMNAME-ubuntu2004" {
    remove_test_vm ubuntu2004
}

@test "Install VM (Ubuntu 22.04) - $VMNAME-ubuntu2204" {
    create_test_vm ubuntu2204
}

@test "Delete VM (Ubuntu 22.04) - $VMNAME-ubuntu2204" {
    remove_test_vm ubuntu2204
}

@test "Install VM (Debian 12) - $VMNAME-debian12" {
    create_test_vm debian12
}

@test "Delete VM (Debian 12) - $VMNAME-debian12" {
    remove_test_vm debian12
}

@test "Install VM (openSUSE Leap 15.4) - $VMNAME-opensuse154" {
    create_test_vm opensuse154
}

@test "Delete VM (openSUSE Leap 15.4) - $VMNAME-opensuse154" {
    remove_test_vm opensuse154
}

@test "Install VM (openSUSE Leap 15.5) - $VMNAME-opensuse155" {
    create_test_vm opensuse155
}

@test "Delete VM (openSUSE Leap 15.5) - $VMNAME-opensuse155" {
    remove_test_vm opensuse155
}

@test "Install VM (openSUSE Leap 15.6) - $VMNAME-opensuse156" {
    create_test_vm opensuse156
}

@test "Delete VM (openSUSE Leap 15.6) - $VMNAME-opensuse156" {
    remove_test_vm opensuse156
}

@test "Install VM (SL Micro 6.0) - $VMNAME-micro6" {
    create_test_vm micro6
}

@test "Delete VM (SL Micro 6.0) - $VMNAME-micro6" {
    remove_test_vm micro6
}

@test "Install VM (SUSE Linux Enterprise 15 SP2) - $VMNAME-sles152" {
    create_test_vm sles152
}

@test "Delete VM (SUSE Linux Enterprise 15 SP2) - $VMNAME-sles152" {
    remove_test_vm sles152
}

@test "Install VM (SUSE Linux Enterprise 15 SP3) - $VMNAME-sles153" {
    create_test_vm sles153
}

@test "Delete VM (SUSE Linux Enterprise 15 SP3) - $VMNAME-sles153" {
    remove_test_vm sles153
}

@test "Install VM (SUSE Linux Enterprise 15 SP4) - $VMNAME-sles154" {
    create_test_vm sles154
}

@test "Delete VM (SUSE Linux Enterprise 15 SP4) - $VMNAME-sles154" {
    remove_test_vm sles154
}

@test "Install VM (SUSE Linux Enterprise 15 SP5) - $VMNAME-sles155" {
    create_test_vm sles155
}

@test "Delete VM (SUSE Linux Enterprise 15 SP5) - $VMNAME-sles155" {
    remove_test_vm sles155
}

@test "Install VM (SUSE Linux Enterprise 15 SP5 QU1) - $VMNAME-sles155qu1" {
    create_test_vm sles155qu1
}

@test "Delete VM (SUSE Linux Enterprise 15 SP5 QU1) - $VMNAME-sles155qu1" {
    remove_test_vm sles155qu1
}

@test "Install VM (SUSE Linux Enterprise 15 SP6) - $VMNAME-sles156" {
    create_test_vm sles156
}

@test "Delete VM (SUSE Linux Enterprise 15 SP6) - $VMNAME-sles156" {
    remove_test_vm sles156
}

@test "Install VM (Rocky 9.3) - $VMNAME-rocky93" {
    create_test_vm rocky93
}

@test "Delete VM (Rocky 9.3) - $VMNAME-rocky93" {
    remove_test_vm rocky93
}

@test "Install VM (RHEL 7.9) - $VMNAME-rhel79" {
    create_test_vm rocky93
}

@test "Delete VM (RHEL 7.9) - $VMNAME-rhel79" {
    remove_test_vm rhel79
}

@test "Install VM (RHEL 8.9) - $VMNAME-rhel89" {
    create_test_vm rhel89
}

@test "Delete VM (RHEL 8.9) - $VMNAME-rhel89" {
    remove_test_vm rhel89
}

