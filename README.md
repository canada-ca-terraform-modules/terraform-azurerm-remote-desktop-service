# Microsoft Remote Desktop Services

## Introduction

This template deploys a Microsaoft Remote Desktop Service infrastructure comprised of one Gateway, one Broker and two or more Session Hosts.

## Security Controls

The following security controls can be met through configuration of this template:

* None documented yet

## Dependancies

* [Resource Groups](https://github.com/canada-ca/accelerators_accelerateurs-azure/blob/master/Templates/arm/resourcegroups/latest/readme.md)
* [Keyvault](https://github.com/canada-ca/accelerators_accelerateurs-azure/blob/master/Templates/arm/keyvaults/latest/readme.md)
* [VNET-Subnet](https://github.com/canada-ca/accelerators_accelerateurs-azure/blob/master/Templates/arm/vnet-subnet/latest/readme.md)

## Usage

```terraform
terraform {
  required_version = ">= 0.12.1"
}
provider "azurerm" {
  version = ">= 1.32.0"
  # subscription_id = "2de839a0-37f9-4163-a32a-e1bdb8d6eb7e"
}

data "azurerm_client_config" "current" {}

module "rdsvms" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm-remote-desktop-service?ref=20190801.1"

  ad_domain_name            = "mgmt.demo.gc.ca.local"
  rds_prefix                = "DAZF"
  resourceGroupName         = "${var.envprefix}-MGMT-RDS-RG"
  admin_username            = "azureadmin"
  secretPasswordName        = "server2016DefaultPassword"
  pazSubnetName             = "${var.envprefix}-MGMT-PAZ"
  appSubnetName             = "${var.envprefix}-MGMT-APP"
  vnetName                  = "${var.envprefix}-Core-NetMGMT-VNET"
  vnetResourceGroupName     = "${var.envprefix}-Core-NetMGMT-RG"
  externalfqdn              = "rds.pws1.pspc-spac.ca"
  dnsServers                = ["100.96.122.4", "100.96.122.5"]
  rdsGWIPAddress            = "100.96.120.10"
  rdsBRKIPAddress           = "100.96.122.10"
  rdsSSHIPAddresses         = ["100.96.122.11", "100.96.122.12"]
  broker_gateway_vm_size    = "Standard_D2s_v3"
  session_hosts_vm_size     = "Standard_D4s_v3"
  keyVaultName              = "someKVName"
  keyVaultResourceGroupName = "some-Keyvault-RG"
}

```

## Variable Values

To be documented

## History

| Date     | Release    | Change             |
| -------- | ---------- | ------------------ |
| 20190726 | 20190801.1 | 1st module version |
