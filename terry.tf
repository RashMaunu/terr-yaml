terraform {
  backend "azurerm" {
  resource_group_name = "TerraformRG1"
  storage_account_name = "storageaccountterra1"
  container_name = "container"
  key = "ExpYtqDU16r3hj7mlRzwFsKGurGhwJO42aWfTbBPRVrinjTPau33lY9fAoLW5TztvPByXTto4ClL+AStk9eLyA=="
 }
}
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name     = "TerraformRG1"

}



resource "azurerm_virtual_network" "vnet" {
  name                = "trial-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "trial-subnet"
  address_prefixes     = ["10.0.1.0/24"]
resource_group_name = "${data.azurerm_resource_group.rg.name}"
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "pip" {
  name                = "my-public-ip"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "my-nic"
  location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "my-vm"
 location            = "${data.azurerm_resource_group.rg.location}"
  resource_group_name = "${data.azurerm_resource_group.rg.name}"
  size                  = "Standard_D2s_v3"
  admin_username        = "r"
  admin_password        = "P@ssw0rd!"
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    name              = "my-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}


