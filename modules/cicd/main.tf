# CI/CD Module - main.tf
# Creates Azure Container Registry and Jenkins VM

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = var.tags
}

# Public IP for Jenkins VM
resource "azurerm_public_ip" "jenkins_ip" {
  name                = "${var.jenkins_vm_name}-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}

# Network Security Group for Jenkins VM
resource "azurerm_network_security_group" "jenkins_nsg" {
  name                = "${var.jenkins_vm_name}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_allowed_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface for Jenkins VM
resource "azurerm_network_interface" "jenkins_nic" {
  name                = "${var.jenkins_vm_name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_ip.id
  }
}

# Associate Network Security Group with Network Interface
resource "azurerm_network_interface_security_group_association" "jenkins_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.jenkins_nic.id
  network_security_group_id = azurerm_network_security_group.jenkins_nsg.id
}

# Jenkins VM
resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                = var.jenkins_vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.jenkins_vm_size
  admin_username      = var.jenkins_admin_user
  tags                = var.tags
  
  network_interface_ids = [
    azurerm_network_interface.jenkins_nic.id
  ]

  identity {
    type = "UserAssigned"
    identity_ids = [var.jenkins_identity_id]
  }

  admin_ssh_key {
    username   = var.jenkins_admin_user
    public_key = var.jenkins_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/jenkins_init.tpl", {
    admin_user = var.jenkins_admin_user
    acr_name = azurerm_container_registry.acr.name
    acr_login_server = azurerm_container_registry.acr.login_server
  }))

  boot_diagnostics {
    storage_account_uri = null # Use managed storage account
  }
}

# Role assignment for Jenkins VM to push to ACR
resource "azurerm_role_assignment" "jenkins_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = var.jenkins_identity_principal_id
}

# Role assignment for Jenkins VM to deploy to AKS
resource "azurerm_role_assignment" "jenkins_aks_user" {
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.jenkins_identity_principal_id
}