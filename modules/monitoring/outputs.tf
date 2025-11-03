# Monitoring Module - outputs.tf

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.workspace.name
}

output "log_analytics_primary_shared_key" {
  description = "The primary shared key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.workspace.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_customer_id" {
  description = "The workspace customer ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.workspace.workspace_id
}

output "action_group_id" {
  description = "The ID of the Action Group"
  value       = azurerm_monitor_action_group.critical.id
}