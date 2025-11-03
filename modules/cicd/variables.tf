# CI/CD Module - variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "jenkins_vm_name" {
  description = "Name of the Jenkins VM"
  type        = string
}

variable "jenkins_vm_size" {
  description = "Size of the Jenkins VM"
  type        = string
}

variable "jenkins_admin_user" {
  description = "Admin username for Jenkins VM"
  type        = string
}

variable "jenkins_ssh_key" {
  description = "SSH key for Jenkins VM"
  type        = string
  sensitive   = true
}

variable "admin_allowed_cidr" {
  description = "CIDR block allowed to access Jenkins admin"
  type        = string
  default     = "0.0.0.0/0" # Should be restricted in production
}

variable "subnet_id" {
  description = "ID of the subnet for Jenkins VM"
  type        = string
}

variable "jenkins_identity_id" {
  description = "ID of the Jenkins user assigned managed identity"
  type        = string
  default     = null
}

variable "jenkins_identity_principal_id" {
  description = "Principal ID of the Jenkins user assigned managed identity"
  type        = string
  default     = null
}

variable "aks_cluster_id" {
  description = "ID of the AKS cluster"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}