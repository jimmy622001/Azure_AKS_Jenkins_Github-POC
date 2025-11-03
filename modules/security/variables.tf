variable "project" {
  description = "The project name"
  type        = string
}

variable "environment" {
  description = "The environment (dev, test, prod)"
  type        = string
}

variable "location" {
  description = "The Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs that can access the Key Vault"
  type        = list(string)
  default     = []
}

# Retained for compatibility, not used in simplified implementation
variable "app_gateway_id" {
  description = "ID of the Application Gateway to associate WAF policy with"
  type        = string
}

variable "app_gateway_subnet_cidr" {
  description = "CIDR range of the Application Gateway subnet"
  type        = string
}