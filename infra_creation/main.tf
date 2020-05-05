data "azurerm_resource_group" "rg" {
  name = "TestRG"
}

data "azurerm_virtual_network" "vnet" {
  name                = "TestRG-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = "default"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_network_interface" "networkinterface" {
  name                = "pipelinemaster367"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_image" "ubuntuSlave" {
  name                = "ubuntuSlaveImage"
  resource_group_name = "TestRG"
}

variable "prefix" {
  default = "hk"
}


resource "azurerm_network_interface" "networkinterface" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vmmain" {
  name                  = "${var.prefix}-vm"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.networkinterface.id]
  size               = "Standard_DS1_v2"
  admin_username = "vmadmin"
  admin_password = "Welcome@1234"
  computer_name  = "jenkinsSlave1"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
#   delete_data_disks_on_termination = true

  source_image_id = data.azurerm_image.ubuntuSlave.id

  os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  disable_password_authentication = false
  

  tags = {
    Owner = "Hiren Kamat"
  }
}

output "private_ip" {
    value = azurerm_linux_virtual_machine.vmmain.private_ip_addresses
}

output "vm_id" {
    value = azurerm_linux_virtual_machine.vmmain.id
}
