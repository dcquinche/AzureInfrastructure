provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "Azuredevops" {
  name     = "Azuredevops"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = azurerm_resource_group.Azuredevops.name

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.Azuredevops.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = azurerm_resource_group.Azuredevops.name

  security_rule {
    name                       = "AllowInboundLoadBalancer"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowOutboundSameSubnetVms"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInboundSameSubnetVms"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyInboundInternet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}

resource "azurerm_network_interface" "main" {
  count               = var.vms_number
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-ip"
  resource_group_name = azurerm_resource_group.Azuredevops.name
  location            = azurerm_resource_group.Azuredevops.location
  allocation_method   = "Static"

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = azurerm_resource_group.Azuredevops.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-as"
  location            = azurerm_resource_group.Azuredevops.location
  resource_group_name = azurerm_resource_group.Azuredevops.name
  managed             = true

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vms_number
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.Azuredevops.name
  location                        = azurerm_resource_group.Azuredevops.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  source_image_id                 = var.packer_image
  disable_password_authentication = false
  network_interface_ids = [
    element(azurerm_network_interface.main.*.id, count.index)
  ]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-md"
  location             = azurerm_resource_group.Azuredevops.location
  resource_group_name  = azurerm_resource_group.Azuredevops.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    project_name = "Azure-Udacity-Project"
    source       = "terraform"
  }
}
