#!/usr/bin/env bats

function create_recipe ()
{
    local -r var="$1"
    run ./rib create -y ${var} 
    [ "$status" -eq 0 ]
}

function remove_recipe ()
{
    local -r var="$1"
    run ./rib remove ${var}
    [ "$status" -eq 0 ]
}

@test "Install single_k3s.rcp" {
    create_recipe single_k3s.rcp
}

@test "Delete VM single_k3s.rcp" {
    remove_recipe single_k3s.rcp
}

@test "Install single_rke1.rcp" {
    create_recipe single_rke1.rcp
}

@test "Delete single_rke1.rcp" {
    remove_recipe single_rke1.rcp
}

@test "Install single_rke2.rcp" {
    create_recipe single_rke2.rcp
}

@test "Delete single_rke2.rcp" {
    remove_recipe single_rke2.rcp
}
@test "Install single_rancher_rke2.rcp" {
    create_recipe single_rancher_rke2.rcp
}

@test "Delete single_rancher_rke2.rcp" {
    remove_recipe single_rancher_rke2.rcp
}
@test "Install ranchester.rcp" {
    create_recipe ranchester.rcp
}

@test "Delete ranchester.rcp" {
    remove_recipe ranchester.rcp
}
@test "Install ha_rke1.rcp" {
    create_recipe ha_rke1.rcp
}

@test "Delete ha_rke1.rcp" {
    remove_recipe ha_rke1.rcp
}
@test "Install ha_rke2.rcp" {
    create_recipe ha_rke2.rcp
}

@test "Delete ha_rke2.rcp" {
    remove_recipe ha_rke2.rcp
}
@test "Install ha_k3s.rcp" {
    create_recipe ha_k3s.rcp
}

@test "Delete ha_k3s.rcp" {
    remove_recipe ha_k3s.rcp
}

@test "Install ha_rancher_k3s.rcp" {
    create_recipe ha_rancher_k3s.rcp
}

@test "Delete ha_rancher_k3s.rcp" {
    remove_recipe ha_rancher_k3s.rcp
}

@test "Install ha_rancher_rke1.rcp" {
    create_recipe ha_rancher_rke1.rcp
}

@test "Delete ha_rancher_rke1.rcp" {
    remove_recipe ha_rancher_rke1.rcp
}

@test "Install ha_rancher_rke2.rcp" {
    create_recipe ha_rancher_rke2.rcp
}

@test "Delete ha_rancher_rke2.rcp" {
    remove_recipe ha_rancher_rke2.rcp
}

@test "Install ha_rancher_harv_rke2.rcp" {
    create_recipe ha_rancher_harv_rke2.rcp
}

@test "Delete ha_rancher_harv_rke2.rcp" {
    remove_recipe ha_rancher_harv_rke2.rcp
}

@test "Install ha_harvester.rcp" {
    create_recipe ha_harvester.rcp
}

@test "Delete ha_harvester.rcp" {
    remove_recipe ha_harvester.rcp
}

@test "Install dual_rke2.rcp" {
    create_recipe dual_rke2.rcp
}

@test "Delete dual_rke2.rcp" {
    remove_recipe dual_rke2.rcp
}

@test "Install dual_rke2_ha.rcp" {
    create_recipe dual_rke2_ha.rcp
}

@test "Delete dual_rke2_ha.rcp" {
    remove_recipe dual_rke2_ha.rcp
}

@test "Install dual_k3s_ha.rcp" {
    create_recipe dual_k3s_ha.rcp
}

@test "Delete dual_k3s_ha.rcp" {
    remove_recipe dual_k3s_ha.rcp
}
