# Main Terraform configuration for Azure AKS + Jenkins + GitHub integration

# Configure the Azure provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Store state in Azure Storage Account (commented out - configure according to your environment)
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "tfstateaccount"
#     container_name       = "tfstate"
#     key                  = "azure-aks-jenkins.tfstate"
#   }
# }

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.common_tags
}

# Deploy Network Module
module "network" {
  source               = "./modules/network"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  vnet_name            = var.vnet_name
  vnet_address_space   = var.vnet_address_space
  subnet_configurations = var.subnet_configurations
  tags                 = var.common_tags
}

# Deploy Identity Module
module "identity" {
  source              = "./modules/identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.common_tags
  cluster_name        = var.cluster_name
}

# Deploy Security Module - Simplified version without AppGateway
module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  project             = "aks-jenkins"
  environment         = "dev"
  app_gateway_id      = "dummy-id" # Replace with actual ID when available
  app_gateway_subnet_cidr = "10.0.6.0/24"
  subnet_ids          = [module.network.aks_subnet_id, module.network.jenkins_subnet_id]
}

# Deploy AKS Module
module "aks" {
  source                   = "./modules/aks"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  cluster_name             = var.cluster_name
  kubernetes_version       = var.kubernetes_version
  node_pool_vm_size        = var.node_pool_vm_size
  node_pool_count          = var.node_pool_count
  node_pool_max_count      = var.node_pool_max_count
  node_pool_min_count      = var.node_pool_min_count
  subnet_id                = module.network.aks_subnet_id
  aks_identity_id          = module.identity.aks_identity_id
  key_vault_id             = module.security.key_vault_id
  acr_id                   = "dummy-acr-id" # Will be updated to module.cicd.acr_id when CICD module is ready
  tags                     = var.common_tags
  depends_on               = [module.network, module.identity, module.security]
}

# Deploy Database Module
module "database" {
  source                = "./modules/database"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  tags                  = var.common_tags
  postgres_server_name  = var.postgres_server_name
  postgres_sku_name     = var.postgres_sku_name
  postgres_version      = var.postgres_version
  postgres_storage_mb   = var.postgres_storage_mb
  postgres_db_name      = var.postgres_db_name
  postgres_admin_user   = var.postgres_admin_user
  postgres_admin_password = var.postgres_admin_password
  subnet_id             = module.network.db_subnet_id
  depends_on            = [module.network]
}

# Dummy CICD module - will be implemented later
module "cicd" {
  source              = "./modules/cicd"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.common_tags
  acr_name            = var.acr_name
  jenkins_vm_name     = var.jenkins_vm_name
  jenkins_vm_size     = var.jenkins_vm_size
  jenkins_admin_user  = var.jenkins_admin_user
  jenkins_ssh_key     = var.jenkins_ssh_key
  subnet_id           = module.network.jenkins_subnet_id
  aks_cluster_id      = module.aks.cluster_id
  depends_on          = [module.network]
}

# Deploy Monitoring Module
module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.common_tags
  log_analytics_workspace_name = var.log_analytics_workspace_name
  aks_cluster_id      = module.aks.cluster_id
  depends_on          = [module.aks]
}