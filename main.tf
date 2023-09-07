# Create a resource group
resource "azurerm_resource_group" "my_resource_group" {
  name     = var.resource_group_name
  location = var.location
}

# Create an NSG for the web VM
resource "azurerm_network_security_group" "nsg-web" {
  name                = "nsg-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

# Define security rules for web NSG
resource "azurerm_network_security_rule" "web-rule-8080" {
  name                        = "web-rule-8080"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg-web.name
}

resource "azurerm_network_security_rule" "web-rule-80" {
  name                        = "web-rule-80"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg-web.name
}

resource "azurerm_network_security_rule" "web-rule-5000" {
  name                        = "web-rule-5000"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg-web.name
}

resource "azurerm_network_security_rule" "allow22" {
  name                        = "allow22"
  priority                    = 1004
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg-web.name
}

# Create a virtual network
resource "azurerm_virtual_network" "my_virtual_network" {
  name                = "vn-cars"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  address_space       = ["10.0.0.0/16"]
}

# Create subnets
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.my_virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_public_ip" "vm-web-public-ip" {
  name                = "vm-web-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  allocation_method   = "Static"
  sku                 = "Basic"
}
# Create the web VM
resource "azurerm_linux_virtual_machine" "vm-web" {
  name                  = "vm-web"
  location              = var.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.vm-web-nic.id]
  size                  = "Standard_DS2_v2"

  admin_username = var.admin_username
  admin_password = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}
# Associate the NSG with the web subnet
resource "azurerm_subnet_network_security_group_association" "web-nsg-assoc" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.nsg-web.id
}

# Create an NSG for the db VM
resource "azurerm_network_security_group" "nsg-db" {
  name                = "nsg-db"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

# Define security rules for db NSG
resource "azurerm_network_security_rule" "db-rule" {
  name                        = "db-rule"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "10.0.2.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg-db.name
}

resource "azurerm_network_security_rule" "allow22-db" {
  name                        = "allow22-db"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg-db.name
}
# Associate the NSG with the db subnet
resource "azurerm_subnet_network_security_group_association" "db-nsg-assoc" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.nsg-db.id
}
# Create a subnet for the db VM
resource "azurerm_subnet" "db" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.my_virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vm-db-public-ip" {
  name                = "vm-db-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  allocation_method   = "Static"
}
# Create the db VM
resource "azurerm_linux_virtual_machine" "vm-db" {
  name                  = "vm-db"
  location              = var.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.vm-db-nic.id]
  size                  = "Standard_DS2_v2"

  admin_username = var.admin_username
  admin_password = var.admin_password  # Specify the admin password here
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30  # Adjust the size as needed
  }

  source_image_reference {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
  }
}
resource "azurerm_virtual_machine_extension" "PostgreSQL_DB" {
  name                 = "PostgreSQL_DB"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm-db.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

settings = <<SETTINGS
    {
       "script": "${base64encode(file("setup_postgresql.sh"))}"
    }

SETTINGS
}
# Create network interfaces for the VMs
resource "azurerm_network_interface" "vm-web-nic" {
  name                = "vm-web-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "web-ip-config"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.vm-web-public-ip.id
  }
}

resource "azurerm_network_interface" "vm-db-nic" {
  name                = "vm-db-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "db-ip-config"
    subnet_id                     = azurerm_subnet.db.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.vm-db-public-ip.id
  }
}
