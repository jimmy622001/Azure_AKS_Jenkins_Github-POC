# Disaster Recovery (Pilot Light) Environment Configuration

# General
project_name         = "aks-jenkins-github"
environment          = "dr-pilot-light"
location             = "westus2"  # Different region from production
tags = {
  Environment = "DR-PilotLight"
  Project     = "AKS-Jenkins-GitHub"
  Owner       = "DevOps Team"
  ManagedBy   = "Terraform"
  IsDisasterRecovery = "true"
  CostCenter  = "10001"
}

# Azure Network Configuration
vnet_address_space   = ["10.2.0.0/16"]  # Different CIDR from production
aks_subnet_cidr      = ["10.2.0.0/22"]
jenkins_subnet_cidr  = ["10.2.4.0/24"]
database_subnet_cidr = ["10.2.5.0/24"]

# AKS Configuration - minimal for DR
kubernetes_version   = "1.27.3"  # Same as production for compatibility
aks_node_count       = 1  # Minimal for pilot light
aks_vm_size          = "Standard_D2s_v3"  # Smaller size for cost efficiency
aks_max_pods         = 50  # Same as production for full failover capacity
enable_auto_scaling  = true
aks_min_nodes        = 1  # Minimal for pilot light
aks_max_nodes        = 8  # Same as production for full failover capacity
aks_network_plugin   = "azure"

# Azure Database for PostgreSQL Configuration - replica from production
db_sku_name          = "GP_Gen5_2"  # Smaller for DR until scale-up
db_storage_mb        = 10240  # Same as production for full data capacity
db_backup_retention_days = 14
db_geo_redundant_backup = true
db_auto_grow         = true
db_admin_username    = "postgres"
# Password is stored in Key Vault
db_admin_password  = "DummyPassword123!"  # Dummy password for testing

# Jenkins VM Configuration - minimal for DR
jenkins_vm_size      = "Standard_D2s_v3"  # Smaller for cost efficiency
admin_username       = "azureuser"
# SSH key is stored in Key Vault or generated during deployment
ssh_public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8jHskc2YY2Cl6gH4c72D2X3Fv6/EAmQT8d2+XXekYOc2UcGKKZYhBkzxGcqxnhkFW+CpAMmqjnrq1R+RMOQZJYHCJQvNMvZwgpkfB8mMP4b79OzkSYwn7MKkLlfLYFv75jLRCNrofcEFwltOKxUcQ92dFI6Upb5OQoOLeTpkO8kISk/hdPka3j4n9RzUGR7NRaozXX+LbIg1jTF0apkD7heUITkeH0bQNnXZ1hLGRA8HhfxUERUnZ5j2cSCQ/e+dg4cO/acImmqtY/Fzqr8IMtCgk6XUNeZCFQT9H1OaSQb4/+HUcS0InsyPnIc7jQoyN9ddEJBtBVbENWA0zGCmB dummy@example.com"

# GitHub Integration
github_owner         = "yourorganization"
github_token_secret_name = "github-token"
github_repositories  = ["app-repo-1", "app-repo-2"]

# Monitoring Configuration
log_analytics_retention_days = 90
enable_container_insights    = true
enable_network_watcher      = true

# Security Configuration
enable_ddos_protection      = true
enable_bastion              = true
enable_azure_firewall       = true
enable_service_endpoints    = true

# Backup Configuration
enable_vm_backup            = true
backup_retention_days       = 30

# Other Settings
enable_diagnostics          = true
resource_prefix             = "dr"

# DR-specific Settings
is_active                   = false  # Set to true during DR activation
failover_mode               = "pilot-light"  # Options: pilot-light, warm-standby, hot-standby