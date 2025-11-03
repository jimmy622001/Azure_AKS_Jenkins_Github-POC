# Network Module - outputs.tf

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = azurerm_subnet.subnets["aks"].id
}

output "db_subnet_id" {
  description = "The ID of the database subnet"
  value       = azurerm_subnet.subnets["db"].id
}

output "jenkins_subnet_id" {
  description = "The ID of the Jenkins subnet"
  value       = azurerm_subnet.subnets["jenkins"].id
}

output "gateway_subnet_id" {
  description = "The ID of the Application Gateway subnet"
  value       = azurerm_subnet.subnets["gateway"].id
}

output "app_gateway_id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.app_gateway.id
}