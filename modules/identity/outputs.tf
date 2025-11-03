# Identity Module - outputs.tf

output "aks_identity_id" {
  description = "The ID of the AKS user assigned managed identity"
  value       = azurerm_user_assigned_identity.aks_identity.id
}

output "aks_identity_principal_id" {
  description = "The Principal ID of the AKS user assigned managed identity"
  value       = azurerm_user_assigned_identity.aks_identity.principal_id
}

output "aks_identity_client_id" {
  description = "The Client ID of the AKS user assigned managed identity"
  value       = azurerm_user_assigned_identity.aks_identity.client_id
}

output "jenkins_identity_id" {
  description = "The ID of the Jenkins user assigned managed identity"
  value       = azurerm_user_assigned_identity.jenkins_identity.id
}

output "jenkins_identity_principal_id" {
  description = "The Principal ID of the Jenkins user assigned managed identity"
  value       = azurerm_user_assigned_identity.jenkins_identity.principal_id
}

output "jenkins_identity_client_id" {
  description = "The Client ID of the Jenkins user assigned managed identity"
  value       = azurerm_user_assigned_identity.jenkins_identity.client_id
}