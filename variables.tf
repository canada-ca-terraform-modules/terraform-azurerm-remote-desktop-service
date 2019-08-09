variable "location" {
  description = "Location of the network"
  default     = "canadacentral"
}

variable "keyVaultName" {
  default = "PwS3-Infra-KV-simc2atbrf"
}

variable "keyVaultResourceGroupName" {
  default = "PwS3-Infra-Keyvault-RG"
}
variable "tags" {
  default = {
    "Organizations"     = "PwP0-CCC-E&O"
    "DeploymentVersion" = "2018-12-14-01"
    "Classification"    = "Unclassified"
    "Enviroment"        = "Sandbox"
    "CostCenter"        = "PwP0-EA"
    "Owner"             = "cloudteam@tpsgc-pwgsc.gc.ca"
  }
}

variable "ad_domain_name" {
  default = "mgmt.demo.gc.ca.local"
}

variable "rds_prefix" {
  default = "adds"
}

variable "pazSubnetName" {
  default = "PwS3-Shared-PAZ-Openshift-RG"
}

variable "appSubnetName" {
  default = "PwS3-Shared-APP-Openshift-RG"
}

variable "vnetName" {
  default = "PwS3-Infra-NetShared-VNET"
}
variable "vnetResourceGroupName" {
  default = "PwS3-Infra-NetShared-RG"
}

variable "dnsServers" {
  default = null
}

variable "externalfqdn" {
  default = "rds.pws1.pspc-spac.ca"
  
}

variable "rdsGWIPAddress" {
  default = ""
}

variable "rdsGWIPAddress_allocation" {
  default = "Static"
}
variable "rdsBRKIPAddress" {
  default = ""
}

variable "rdsBRKIPAddress_allocation" {
  default = "Static"
}

variable "rdsSSHIPAddresses" {
  type = "list"
  default = ["ip1", "ip2"]
}

variable "rdsSSHIPAddress_allocation" {
  default = "Static"
}

variable "resourceGroupName" {
  default = "PwS3-GCInterrop-Openshift"
}

variable "admin_username" {
  default = "azureadmin"
}

variable "secretPasswordName" {
  default = "server2016DefaultPassword"
}

variable "broker_gateway_vm_size" {
  default = "Standard_D2s_v3"
}

variable "session_hosts_vm_size" {
  default = "Standard_D4s_v3"
}

variable "storage_image_reference" {
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

variable "storage_os_disk" {
  default = {
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = "Windows"
  }
}
variable "DSC_URL" {
  default = "https://raw.githubusercontent.com/canada-ca-terraform-modules/terraform-azurerm-remote-desktop-service/20190801.1/DSC/Configuration.zip"
}