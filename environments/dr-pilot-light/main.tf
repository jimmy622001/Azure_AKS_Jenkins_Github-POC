# Disaster Recovery (Pilot Light) Environment Configuration

# Store state in Azure Storage Account (commented out - configure according to your environment)
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "tfstateaccount"
#     container_name       = "tfstate"
#     key                  = "azure-aks-jenkins-dr.tfstate"
#   }
# }

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

module "azure_aks_jenkins" {
  source = "../../"
  
  # Core settings
  resource_group_name = var.resource_group_name
  location            = var.location  # Different region from production
  common_tags         = var.common_tags
  
  # Network settings
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space
  subnet_configurations = var.subnet_configurations
  
  # AKS settings - minimal deployment for DR
  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  node_pool_vm_size   = var.node_pool_vm_size
  node_pool_count     = var.node_pool_count
  node_pool_max_count = var.node_pool_max_count
  node_pool_min_count = var.node_pool_min_count
  
  # Database settings - replica from production
  postgres_server_name   = var.postgres_server_name
  postgres_sku_name      = var.postgres_sku_name
  postgres_version       = var.postgres_version
  postgres_storage_mb    = var.postgres_storage_mb
  postgres_db_name       = var.postgres_db_name
  postgres_admin_user    = var.postgres_admin_user
  postgres_admin_password = var.postgres_admin_password
  
  # CI/CD settings - minimal Jenkins for DR
  acr_name           = var.acr_name
  jenkins_vm_name    = var.jenkins_vm_name
  jenkins_vm_size    = var.jenkins_vm_size
  jenkins_admin_user = var.jenkins_admin_user
  jenkins_ssh_key    = file("${path.module}/dummy_key.pub")  # Use local dummy key for testing
  
  # Security settings
  key_vault_name = var.key_vault_name
  
  # Monitoring settings
  log_analytics_workspace_name = var.log_analytics_workspace_name
}