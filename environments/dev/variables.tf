# Dev Environment Variables

# Core Infrastructure Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "aks-jenkins-dev-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "AKS-Jenkins-GitHub"
    ManagedBy   = "Terraform"
  }
}

# Network Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "aks-dev-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_configurations" {
  description = "Configuration for all subnets"
  type = map(object({
    address_prefix    = string
    service_endpoints = list(string)
    delegation = optional(map(object({
      name    = string
      actions = list(string)
    })))
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  default = {
    aks = {
      address_prefix                            = "10.0.0.0/22"
      service_endpoints                         = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
      private_endpoint_network_policies_enabled = false
    }
    db = {
      address_prefix                            = "10.0.4.0/24"
      service_endpoints                         = ["Microsoft.Sql"]
      private_endpoint_network_policies_enabled = false
    }
    jenkins = {
      address_prefix                            = "10.0.5.0/24"
      service_endpoints                         = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
      private_endpoint_network_policies_enabled = true
    }
    gateway = {
      address_prefix                            = "10.0.6.0/24"
      service_endpoints                         = []
      private_endpoint_network_policies_enabled = true
    }
  }
}

# AKS Variables
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-jenkins-dev-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27.3"
}

variable "node_pool_vm_size" {
  description = "VM size for AKS node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "node_pool_count" {
  description = "Initial node pool count"
  type        = number
  default     = 2
}

variable "node_pool_max_count" {
  description = "Maximum node pool count for autoscaling"
  type        = number
  default     = 5
}

variable "node_pool_min_count" {
  description = "Minimum node pool count for autoscaling"
  type        = number
  default     = 1
}

# Database Variables
variable "postgres_server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
  default     = "aks-jenkins-dev-postgres"
}

variable "postgres_sku_name" {
  description = "SKU name for PostgreSQL server"
  type        = string
  default     = "GP_Gen5_2"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "11"
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
  default     = 5120
}

variable "postgres_db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "appdb"
}

variable "postgres_admin_user" {
  description = "PostgreSQL admin username"
  type        = string
  default     = "postgresadmin"
  sensitive   = true
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

# CI/CD Variables
variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "aksjenkinsdevacr"
}

variable "jenkins_vm_name" {
  description = "Name of the Jenkins VM"
  type        = string
  default     = "jenkins-dev-vm"
}

variable "jenkins_vm_size" {
  description = "Size of the Jenkins VM"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "jenkins_admin_user" {
  description = "Admin username for Jenkins VM"
  type        = string
  default     = "jenkins"
}

variable "jenkins_ssh_key" {
  description = "SSH key for Jenkins VM"
  type        = string
  sensitive   = true
}

# Security Variables
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "aks-jenkins-dev-kv"
}

# Monitoring Variables
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "aks-jenkins-dev-analytics"
}