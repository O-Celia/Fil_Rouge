# Create a resource group

resource "azurerm_resource_group" "project" {
  name     = var.resource_group_name
  location = var.location
}

## Create a virtual network within the resource group

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  resource_group_name = azurerm_resource_group.project.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

# Create subnet VM

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = azurerm_resource_group.project.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

## Create VM network interface

resource "azurerm_network_interface" "vm" {
  name                = var.VM-nic
  location            = var.location
  resource_group_name = azurerm_resource_group.project.name

  ip_configuration {
    name                          = var.config
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
    public_ip_address_id          = azurerm_public_ip.ip-pub.id
  }
}

# Azure public ip

resource "azurerm_public_ip" "ip-pub" {
  name                    = "pubip"
  location                = var.location
  resource_group_name     = azurerm_resource_group.project.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
  
}

# Create VM

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.VM_name
  resource_group_name = azurerm_resource_group.project.name
  location            = var.location
  size                = "Standard_A1_v2"
  network_interface_ids = [azurerm_network_interface.vm.id]

  admin_ssh_key {
    username   = var.admin
    public_key = file("/mnt/c/Users/utilisateur/.ssh/id_rsa.pub") 
    }

  os_disk {
    name                 = var.OSdisk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
  
  computer_name                   = var.computerVM_name
  disable_password_authentication = true
  admin_username                  = var.admin
}

## Create NSG

resource "azurerm_network_security_group" "vm" {
  name                = var.NSG
  location            = var.location
  resource_group_name = azurerm_resource_group.project.name

  security_rule {
    name                       = var.VM_rule
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = var.VM_rule2
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }



  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.vm.id
}