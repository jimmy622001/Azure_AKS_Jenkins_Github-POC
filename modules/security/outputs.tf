output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.vault.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.vault.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.vault.vault_uri
}

output "aks_nsg_id" {
  description = "The ID of the AKS network security group"
  value       = azurerm_network_security_group.aks_nsg.id
}

output "jenkins_nsg_id" {
  description = "The ID of the Jenkins network security group"
  value       = azurerm_network_security_group.jenkins_nsg.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for security monitoring"
  value       = azurerm_log_analytics_workspace.security_logs.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace for security monitoring"
  value       = azurerm_log_analytics_workspace.security_logs.name
}

# Dummy outputs for compatibility
output "waf_policy_id" {
  description = "The ID of the WAF policy (dummy for compatibility)"
  value       = "dummy-waf-id"
}

output "ddos_protection_plan_id" {
  description = "The ID of the DDoS protection plan (dummy for compatibility)"
  value       = null
}

output "security_alerts_action_group_id" {
  description = "The ID of the action group for security alerts (dummy for compatibility)"
  value       = "dummy-action-group-id"
}