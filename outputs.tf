# Root module outputs

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "aks_kube_config" {
  description = "The kube config for the AKS cluster"
  value       = module.aks.kube_config
  sensitive   = true
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = module.cicd.acr_name
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = module.cicd.acr_login_server
}

output "jenkins_vm_public_ip" {
  description = "The public IP address of the Jenkins VM"
  value       = module.cicd.jenkins_vm_public_ip
}

output "postgres_server_fqdn" {
  description = "The FQDN of the PostgreSQL server"
  value       = module.database.postgres_server_fqdn
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.security.key_vault_uri
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.network.vnet_name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = module.network.vnet_id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_id
}