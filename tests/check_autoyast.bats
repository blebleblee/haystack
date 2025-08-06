#!/usr/bin/env bats

VMNAME=batstestvm

function create_test_autoyast ()
{
    local -r var="$1"
    run ./kvm-install-autoyast create -t ${var} ${VMNAME}-${var}
    [ "$status" -eq 0 ]
}

function remove_test_autoyast ()
{
    local -r var="$1"
    run ./kvm-install-autoyast remove ${VMNAME}-${var}
    [ "$status" -eq 0 ]
}

@test "Install VM (SUSE Linux Enterprise 15 SP3) - $VMNAME-sles153" {
    create_test_autoyast sles153
}

@test "Delete VM (SUSE Linux Enterprise 15 SP3) - $VMNAME-sles153" {
    remove_test_autoyast sles153
}

@test "Install VM (SUSE Linux Enterprise 15 SP4) - $VMNAME-sles154" {
    create_test_autoyast sles154
}

@test "Delete VM (SUSE Linux Enterprise 15 SP4) - $VMNAME-sles154" {
    remove_test_autoyast sles154
}

@test "Install VM (SUSE Linux Enterprise 15 SP5) - $VMNAME-sles155" {
    create_test_autoyast sles155
}

@test "Delete VM (SUSE Linux Enterprise 15 SP5) - $VMNAME-sles155" {
    remove_test_autoyast sles155
}

@test "Install VM (SUSE Linux Enterprise 15 SP6) - $VMNAME-sles156" {
    create_test_autoyast sles156
}

@test "Delete VM (SUSE Linux Enterprise 15 SP6) - $VMNAME-sles156" {
    remove_test_autoyast sles156
}

@test "Install VM (SUSE Linux Enterprise 15 SP7) - $VMNAME-sles157" {
    create_test_autoyast sles157
}

@test "Delete VM (SUSE Linux Enterprise 15 SP7) - $VMNAME-sles157" {
    remove_test_autoyast sles157
}