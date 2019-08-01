#############################################################################################
# RDS Build                                                                          
#############################################################################################


#############################################################################################
# Availability Sets
#############################################################################################
resource "azurerm_availability_set" "rdsbroker-as" {
  name                         = "${var.rds_prefix}RDSBRK-AS"
  location                     = "${var.location}"
  resource_group_name          = "${var.resourceGroupName}"
  platform_update_domain_count = 20
  platform_fault_domain_count  = 2
  managed                      = true
}

resource "azurerm_availability_set" "rdsgateway-as" {
  name                         = "${var.rds_prefix}RDSGateway-AS"
  location                     = "${var.location}"
  resource_group_name          = "${var.resourceGroupName}"
  platform_update_domain_count = 20
  platform_fault_domain_count  = 2
  managed                      = true
}

resource "azurerm_availability_set" "rdsssh-as" {
  name                         = "${var.rds_prefix}RDSSSH-AS"
  location                     = "${var.location}"
  resource_group_name          = "${var.resourceGroupName}"
  platform_update_domain_count = 20
  platform_fault_domain_count  = 2
  managed                      = true
}


#############################################################################################
# RDS Servers NSGs                                                                          
#############################################################################################

resource azurerm_network_security_group rdsbroker-nsg {
  name                = "${var.rds_prefix}RDSBRK-NSG"
  location            = "${var.location}"
  resource_group_name = "${var.resourceGroupName}"
  security_rule {
    name                       = "AllowAllInbound"
    description                = "Allow all in"
    access                     = "Allow"
    priority                   = "100"
    protocol                   = "*"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    description                = "Allow all out"
    access                     = "Allow"
    priority                   = "105"
    protocol                   = "*"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  tags = "${var.tags}"
}

resource azurerm_network_security_group rdsgateway-nsg {
  name                = "${var.rds_prefix}RDSGateway-NSG"
  location            = "${var.location}"
  resource_group_name = "${var.resourceGroupName}"
  security_rule {
    name                       = "AllowAllInbound"
    description                = "Allow all in"
    access                     = "Allow"
    priority                   = "100"
    protocol                   = "*"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    description                = "Allow all out"
    access                     = "Allow"
    priority                   = "105"
    protocol                   = "*"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  tags = "${var.tags}"
}

resource azurerm_network_security_group rdsssh-nsg {
  name                = "${var.rds_prefix}RDSSSH-NSG"
  location            = "${var.location}"
  resource_group_name = "${var.resourceGroupName}"
  security_rule {
    name                       = "AllowAllInbound"
    description                = "Allow all in"
    access                     = "Allow"
    priority                   = "100"
    protocol                   = "*"
    direction                  = "Inbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    description                = "Allow all out"
    access                     = "Allow"
    priority                   = "105"
    protocol                   = "*"
    direction                  = "Outbound"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
  }
  tags = "${var.tags}"
}

#############################################################################################
# RDS Servers NICs                                                                          
#############################################################################################

resource "azurerm_network_interface" "rdsbroker-nic" {
  name                      = "${var.rds_prefix}RDSBRK-Nic1"
  location                  = "${var.location}"
  resource_group_name       = "${var.resourceGroupName}"
  network_security_group_id = "${azurerm_network_security_group.rdsbroker-nsg.id}"
  dns_servers               = "${var.dnsServers}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${data.azurerm_subnet.appSubnet.id}"
    private_ip_address            = "${var.rdsBRKIPAddress}"
    private_ip_address_allocation = "${var.rdsBRKIPAddress_allocation}"
  }
}

resource "azurerm_network_interface" "rdsgateway-nic" {
  name                      = "${var.rds_prefix}RDSGateway-Nic1"
  location                  = "${var.location}"
  resource_group_name       = "${var.resourceGroupName}"
  network_security_group_id = "${azurerm_network_security_group.rdsgateway-nsg.id}"
  dns_servers               = "${var.dnsServers}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${data.azurerm_subnet.pazSubnet.id}"
    private_ip_address            = "${var.rdsGWIPAddress}"
    private_ip_address_allocation = "${var.rdsGWIPAddress_allocation}"
  }
}

resource "azurerm_network_interface" "rdsssh-nics" {
  count                     = "${length(var.rdsSSHIPAddresses)}"
  name                      = "${var.rds_prefix}RDSSSH-${count.index + 1}-Nic1"
  location                  = "${var.location}"
  resource_group_name       = "${var.resourceGroupName}"
  network_security_group_id = "${azurerm_network_security_group.rdsssh-nsg.id}"
  dns_servers               = "${var.dnsServers}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${data.azurerm_subnet.appSubnet.id}"
    private_ip_address_allocation = "${var.rdsSSHIPAddress_allocation}"
    private_ip_address            = "${var.rdsSSHIPAddresses[count.index]}"
  }
}

#############################################################################################
# Broker                                                                      
#############################################################################################

resource "azurerm_virtual_machine" "RDSBroker" {
  name                  = "${var.rds_prefix}RDSBRK"
  location              = "${var.location}"
  resource_group_name   = "${var.resourceGroupName}"
  network_interface_ids = ["${azurerm_network_interface.rdsbroker-nic.id}"]
  vm_size               = "${var.broker_gateway_vm_size}"

  primary_network_interface_id = "${azurerm_network_interface.rdsbroker-nic.id}"
  availability_set_id          = "${azurerm_availability_set.rdsbroker-as.id}"

  os_profile {
    computer_name  = "${var.rds_prefix}broker"
    admin_username = "${var.admin_username}"
    admin_password = "${data.azurerm_key_vault_secret.secretPassword.value}"
  }

  storage_image_reference {
    publisher = "${var.storage_image_reference.publisher}"
    offer     = "${var.storage_image_reference.offer}"
    sku       = "${var.storage_image_reference.sku}"
    version   = "${var.storage_image_reference.version}"
  }

  storage_os_disk {
    name          = "${var.rds_prefix}RDSBRK_OSDisk"
    caching       = "${var.storage_os_disk.caching}"
    create_option = "${var.storage_os_disk.create_option}"
    os_type       = "${var.storage_os_disk.os_type}"
  }

  storage_data_disk {
    name          = "${var.rds_prefix}RDSBRK_DataDisk1"
    create_option = "Empty"
    lun           = 0
    disk_size_gb  = 30
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

#############################################################################################
# Gateway                                                                         
#############################################################################################

resource "azurerm_virtual_machine" "RDSGateway" {
  name                  = "${var.rds_prefix}RDSGateway"
  location              = "${var.location}"
  resource_group_name   = "${var.resourceGroupName}"
  network_interface_ids = ["${azurerm_network_interface.rdsgateway-nic.id}"]
  vm_size               = "${var.broker_gateway_vm_size}"

  primary_network_interface_id = "${azurerm_network_interface.rdsgateway-nic.id}"
  availability_set_id          = "${azurerm_availability_set.rdsgateway-as.id}"

  os_profile {
    computer_name  = "${var.rds_prefix}gateway"
    admin_username = "${var.admin_username}"
    admin_password = "${data.azurerm_key_vault_secret.secretPassword.value}"
  }

  storage_image_reference {
    publisher = "${var.storage_image_reference.publisher}"
    offer     = "${var.storage_image_reference.offer}"
    sku       = "${var.storage_image_reference.sku}"
    version   = "${var.storage_image_reference.version}"
  }

  storage_os_disk {
    name          = "${var.rds_prefix}RDSGateway_OSDisk"
    caching       = "${var.storage_os_disk.caching}"
    create_option = "${var.storage_os_disk.create_option}"
    os_type       = "${var.storage_os_disk.os_type}"
  }

  storage_data_disk {
    name          = "${var.rds_prefix}RDSGateway_DataDisk1"
    create_option = "Empty"
    lun           = 0
    disk_size_gb  = 30
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

#############################################################################################
# Session Hosts                                                                         
#############################################################################################

resource "azurerm_virtual_machine" "RDSSSH" {
  count                 = 2
  name                  = "${var.rds_prefix}RDSSSH-${count.index + 1}"
  location              = "${var.location}"
  resource_group_name   = "${var.resourceGroupName}"
  network_interface_ids = ["${element(azurerm_network_interface.rdsssh-nics.*.id, count.index)}"]
  vm_size               = "${var.session_hosts_vm_size}"

  primary_network_interface_id = "${element(azurerm_network_interface.rdsssh-nics.*.id, count.index)}"
  availability_set_id          = "${azurerm_availability_set.rdsssh-as.id}"

  os_profile {
    computer_name  = "${var.rds_prefix}RDSSSH-${count.index + 1}"
    admin_username = "${var.admin_username}"
    admin_password = "${data.azurerm_key_vault_secret.secretPassword.value}"
  }

  storage_image_reference {
    publisher = "${var.storage_image_reference.publisher}"
    offer     = "${var.storage_image_reference.offer}"
    sku       = "${var.storage_image_reference.sku}"
    version   = "${var.storage_image_reference.version}"
  }

  storage_os_disk {
    name          = "${var.rds_prefix}RDSSSH-${count.index + 1}_OSDisk"
    caching       = "${var.storage_os_disk.caching}"
    create_option = "${var.storage_os_disk.create_option}"
    os_type       = "${var.storage_os_disk.os_type}"
  }

  storage_data_disk {
    name          = "${var.rds_prefix}RDSSSH-${count.index + 1}_DataDisk1"
    create_option = "Empty"
    lun           = 0
    disk_size_gb  = 30
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

#############################################################################################
# RDS VM extensions
#############################################################################################

resource "azurerm_virtual_machine_extension" "ProvisionRDSGateway" {
  name                 = "provisionRDSGateway"
  location             = "${var.location}"
  resource_group_name  = "${var.resourceGroupName}"
  virtual_machine_name = "${azurerm_virtual_machine.RDSGateway.name}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.77"

  settings = <<SETTINGS
            {
                "WmfVersion": "latest",
                "configuration": {
                    "url": "${var.DSC_URL}",
                    "script": "Configuration.ps1",
                    "function": "Gateway"
                },
                "configurationArguments": {
                    "DomainName": "${var.ad_domain_name}"
                }
            }
            SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
        {
            "configurationArguments": {
                "adminCreds": {
                    "UserName": "${var.admin_username}",
                    "Password": "${data.azurerm_key_vault_secret.secretPassword.value}"
                }
            }
        }
    PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "PrepareRDSSessionHosts" {
    count                = "${length(azurerm_virtual_machine.RDSSSH)}"
    name                 = "prepareRDSSessionHosts"
    location             = "${var.location}"
    resource_group_name  = "${var.resourceGroupName}"
    virtual_machine_name = "${element(azurerm_virtual_machine.RDSSSH.*.name, count.index)}"
    publisher            = "Microsoft.Powershell"
    type                 = "DSC"
    type_handler_version = "2.77"

    settings = <<SETTINGS
            {
                "WmfVersion": "latest",
                "configuration": {
                    "url": "${var.DSC_URL}",
                    "script": "Configuration.ps1",
                    "function": "SessionHost"
                },
                "configurationArguments": {
                    "DomainName": "${var.ad_domain_name}"
                }
            }
            SETTINGS
    protected_settings = <<PROTECTED_SETTINGS
        {
            "configurationArguments": {
                "adminCreds": {
                    "UserName": "${var.admin_username}",
                    "Password": "${data.azurerm_key_vault_secret.secretPassword.value}"
                }
            }
        }
    PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "DeployRDS" {
  name                 = "deployRDS"
  location             = "${var.location}"
  resource_group_name  = "${var.resourceGroupName}"
  virtual_machine_name = "${azurerm_virtual_machine.RDSBroker.name}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.77"

  depends_on = ["azurerm_virtual_machine_extension.PrepareRDSSessionHosts",
  "azurerm_virtual_machine_extension.ProvisionRDSGateway"]

  settings = <<SETTINGS
            {
                "WmfVersion": "latest",
                "configuration": {
                    "url": "${var.DSC_URL}",
                    "script": "Configuration.ps1",
                    "function": "RDSDeployment"
                },
                "configurationArguments": {
                    "DomainName": "${var.ad_domain_name}",
                    "connectionBroker": "${var.rds_prefix}broker.${var.ad_domain_name}",
                    "externalfqdn": "ops-rds.aafccloud.com",
                    "numberOfRdshInstances": "${length(azurerm_virtual_machine.RDSSSH)}",
                    "sessionHostNamingPrefix": "${var.rds_prefix}RDSSSH-",
                    "webAccessServer": "${var.rds_prefix}gateway.${var.ad_domain_name}"
                }
            }
            SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
        {
            "configurationArguments": {
                "adminCreds": {
                    "UserName": "${var.admin_username}",
                    "Password": "${data.azurerm_key_vault_secret.secretPassword.value}"
                }
            }
        }
    PROTECTED_SETTINGS
}