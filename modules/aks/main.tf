# AKS Module - main.tf
# Creates Azure Kubernetes Service cluster with all necessary components

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  default_node_pool {
    name           = "default"
    vm_size        = var.node_pool_vm_size
    vnet_subnet_id = var.subnet_id
    # Auto-scaling settings
    max_count       = var.node_pool_max_count
    min_count       = var.node_pool_min_count
    os_disk_size_gb = 50
    auto_scaling_enabled = true # Updated for Azure Provider 4.x
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.aks_identity_id]
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }

  # Updated to use separate addon blocks instead of addon_profile
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_policy_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

# Additional Node Pool for User Applications
resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.node_pool_vm_size
  node_count            = 1
  auto_scaling_enabled  = true # Updated for Azure Provider 4.x
  max_count             = 3
  min_count             = 1
  mode                  = "User"
  os_disk_size_gb       = 50
  tags                  = var.tags
  vnet_subnet_id        = var.subnet_id
}

# Role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}