# Production Environment Configuration

# General
project_name = "aks-jenkins-github"
environment  = "prod"
location     = "eastus2"
tags = {
  Environment = "Production"
  Project     = "AKS-Jenkins-GitHub"
  Owner       = "DevOps Team"
  ManagedBy   = "Terraform"
  CostCenter  = "10001"
}

# Azure Network Configuration
vnet_address_space   = ["10.1.0.0/16"]
aks_subnet_cidr      = ["10.1.0.0/22"]
jenkins_subnet_cidr  = ["10.1.4.0/24"]
database_subnet_cidr = ["10.1.5.0/24"]

# AKS Configuration
kubernetes_version  = "1.27.3"
aks_node_count      = 3
aks_vm_size         = "Standard_D4s_v3"
aks_max_pods        = 50
enable_auto_scaling = true
aks_min_nodes       = 3
aks_max_nodes       = 8
aks_network_plugin  = "azure"

# Azure Database for PostgreSQL Configuration
db_sku_name              = "GP_Gen5_4"
db_storage_mb            = 10240
db_backup_retention_days = 14
db_geo_redundant_backup  = true
db_auto_grow             = true
db_admin_username        = "postgres"
# Password is stored in Key Vault
# db_admin_password  = "Ch@ngeMe!"

# Jenkins VM Configuration
jenkins_vm_size = "Standard_D4s_v3"
admin_username  = "azureuser"
# SSH key is stored in Key Vault or generated during deployment
ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8jHskc2YY2Cl6gH4c72D2X3Fv6/EAmQT8d2+XXekYOc2UcGKKZYhBkzxGcqxnhkFW+CpAMmqjnrq1R+RMOQZJYHCJQvNMvZwgpkfB8mMP4b79OzkSYwn7MKkLlfLYFv75jLRCNrofcEFwltOKxUcQ92dFI6Upb5OQoOLeTpkO8kISk/hdPka3j4n9RzUGR7NRaozXX+LbIg1jTF0apkD7heUITkeH0bQNnXZ1hLGRA8HhfxUERUnZ5j2cSCQ/e+dg4cO/acImmqtY/Fzqr8IMtCgk6XUNeZCFQT9H1OaSQb4/+HUcS0InsyPnIc7jQoyN9ddEJBtBVbENWA0zGCmB dummy@example.com"

# GitHub Integration
github_owner             = "yourorganization"
github_token_secret_name = "github-token"
github_repositories      = ["app-repo-1", "app-repo-2"]

# Monitoring Configuration
log_analytics_retention_days = 90
enable_container_insights    = true
enable_network_watcher       = true

# Security Configuration
enable_ddos_protection   = true
enable_bastion           = true
enable_azure_firewall    = true
enable_service_endpoints = true

# Backup Configuration
enable_vm_backup      = true
backup_retention_days = 30

# Other Settings
enable_diagnostics = true
resource_prefix    = "prod"