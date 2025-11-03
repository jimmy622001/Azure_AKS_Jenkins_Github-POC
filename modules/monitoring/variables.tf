# Monitoring Module - variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "aks_cluster_id" {
  description = "ID of the AKS cluster to monitor"
  type        = string
}

variable "admin_email" {
  description = "Email address for alerts"
  type        = string
  default     = "admin@example.com"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}