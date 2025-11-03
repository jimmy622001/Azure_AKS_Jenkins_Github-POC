# Database Module - variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "postgres_server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
}

variable "postgres_sku_name" {
  description = "SKU name for PostgreSQL server"
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage in MB"
  type        = number
}

variable "postgres_db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "postgres_admin_user" {
  description = "PostgreSQL admin username"
  type        = string
  sensitive   = true
}

variable "postgres_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "ID of the subnet for private endpoint"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}