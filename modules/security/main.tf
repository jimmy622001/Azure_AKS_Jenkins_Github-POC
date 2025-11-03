# Simplified Azure Key Vault for storing secrets securely
resource "azurerm_key_vault" "vault" {
  name                        = "kv-${var.project}-${var.environment}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  sku_name                    = "standard"

  # Simple network ACL configuration
  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    virtual_network_subnet_ids = var.subnet_ids
  }

  # Using access policies instead of RBAC for compatibility
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update",
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete",
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update",
    ]
  }

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Simplified Network Security Group for AKS cluster
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "nsg-aks-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTPS from Application Gateway
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.app_gateway_subnet_cidr
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Simplified Network Security Group for Jenkins VM
resource "azurerm_network_security_group" "jenkins_nsg" {
  name                = "nsg-jenkins-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow SSH
  security_rule {
    name                       = "AllowSSHInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS for Jenkins Web UI
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Simplified Log Analytics Workspace for Security Monitoring
resource "azurerm_log_analytics_workspace" "security_logs" {
  name                = "log-security-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}