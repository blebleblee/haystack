#!/usr/bin/env bats

VMPREFIX=batstestvm

@test "Install VM - $VMPREFIX-destroy" {
    run ./kvm-install-vm create ${VMPREFIX}-destroy
    [ "$status" -eq 0 ]
}

@test "Shutdown/Destroy VM - $VMPREFIX-destroy" {
    run virsh destroy $VMPREFIX-destroy
    [ "$status" -eq 0 ]
}

@test "Delete VM - $VMPREFIX-destroy" {
    run ./kvm-install-vm remove ${VMPREFIX}-destroy
    [[ "${lines[0]}" =~ "Domain is not running." ]]
    [ "$status" -eq 0 ]
}
