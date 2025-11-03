# AKS Module - variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "node_pool_vm_size" {
  description = "VM size for AKS node pool"
  type        = string
}

variable "node_pool_count" {
  description = "Initial node pool count"
  type        = number
}

variable "node_pool_max_count" {
  description = "Maximum node pool count for autoscaling"
  type        = number
}

variable "node_pool_min_count" {
  description = "Minimum node pool count for autoscaling"
  type        = number
}

variable "subnet_id" {
  description = "ID of the subnet for AKS nodes"
  type        = string
}

variable "aks_identity_id" {
  description = "ID of the AKS user assigned managed identity"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Key Vault"
  type        = string
}

variable "acr_id" {
  description = "ID of the Azure Container Registry"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for AKS monitoring"
  type        = string
  default     = null
}

variable "admin_group_object_ids" {
  description = "Object IDs of the AAD groups that will have admin access to the AKS cluster"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}