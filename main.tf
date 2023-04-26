provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG" {
  name     = "Prod-Terraform-rg-EastUS-001"     //<env>-<app or service name>-rg-<region>-<###>
  location = "East Us"
}

resource "azurerm_virtual_network" "Vn" {
  name                = "vnet-shared-EastUS-001"  //vnet-<subscription purpose>-<region>-<###>
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-shared-EastUs-001"           //snet-<subscription purpose>-<region>-<###>
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.Vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-01-Terra-shared-001"      //nic-<##>-<vm name>-<subscription purpose>-<###>
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-Terra-001"                      //vm-<policy name or app name>-<###>
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_F2"
  admin_username      = "Mounika"
  admin_password      = "qwer@1234567"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_virtual_network" "VN" {
  name                = "vnet-shared-EastUS-002"            //vnet-<subscription purpose>-<region>-<###>
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "snet--shared-EastUs-002"           //snet-<subscription purpose>-<region>-<###>
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_interface" "network" {
  name                = "nic-02-TFmach-shared-001"          //nic-<##>-<vm name>-<subscription purpose>-<###>
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "virtual" {
  name                = "vm-TFmach-001"                          //vm-<policy name or app name>-<###>
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_F2"
  admin_username      = "Mounika"
  admin_password      = "qwer@1234567"
  network_interface_ids = [
    azurerm_network_interface.network.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "NSG" {
  name                = "nsg-Networksecuritygroup-001"           ///nsg-<policy name or app name>-<###>
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_network_security_rule" "NSG" {
  name                        = "blockHTTP"
  priority                    = 1051
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.RG.name
  network_security_group_name = azurerm_network_security_group.NSG.name
}

resource "azurerm_subnet_network_security_group_association" "subnet" {

subnet_id = azurerm_subnet.subnet.id

 network_security_group_id = azurerm_network_security_group.NSG.id

}

resource "azurerm_subnet_network_security_group_association" "subnet1" {

subnet_id = azurerm_subnet.subnet1.id

 network_security_group_id = azurerm_network_security_group.NSG.id

}