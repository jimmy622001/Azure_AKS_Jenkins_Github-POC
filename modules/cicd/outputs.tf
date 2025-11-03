# CI/CD Module - outputs.tf

output "acr_id" {
  description = "The ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "The login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "jenkins_vm_id" {
  description = "The ID of the Jenkins VM"
  value       = azurerm_linux_virtual_machine.jenkins_vm.id
}

output "jenkins_vm_public_ip" {
  description = "The public IP address of the Jenkins VM"
  value       = azurerm_public_ip.jenkins_ip.ip_address
}

output "jenkins_vm_private_ip" {
  description = "The private IP address of the Jenkins VM"
  value       = azurerm_network_interface.jenkins_nic.private_ip_address
}

output "jenkins_admin_username" {
  description = "The admin username for the Jenkins VM"
  value       = var.jenkins_admin_user
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${azurerm_public_ip.jenkins_ip.ip_address}:8080"
}