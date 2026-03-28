# DNS Module Variables

variable "domain_name" {
  description = "The domain name for the environment (e.g., example.com)"
  type        = string
}

variable "environment" {
  description = "The environment name (prod, dev, dr)"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name where DNS resources will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_cdn" {
  description = "Whether to enable Azure CDN for this environment"
  type        = bool
  default     = false
}

variable "cdn_sku" {
  description = "The SKU of the CDN profile"
  type        = string
  default     = "Standard_Microsoft"
  validation {
    condition     = contains(["Standard_Akamai", "Standard_Microsoft", "Standard_Verizon", "Premium_Verizon"], var.cdn_sku)
    error_message = "CDN SKU must be one of Standard_Akamai, Standard_Microsoft, Standard_Verizon, or Premium_Verizon"
  }
}

variable "cdn_optimization_type" {
  description = "Optimization type for the CDN endpoint"
  type        = string
  default     = "GeneralWebDelivery"
  validation {
    condition     = contains(["GeneralWebDelivery", "DynamicSiteAcceleration", "GeneralMediaStreaming", "VideoOnDemandMediaStreaming", "LargeFileDownload"], var.cdn_optimization_type)
    error_message = "CDN optimization type must be valid"
  }
}

variable "cdn_cache_duration" {
  description = "Cache duration for CDN in format 'days.hours:minutes:seconds'"
  type        = string
  default     = "1.00:00:00" # 1 day
}

variable "app_service_hostname" {
  description = "Hostname of the app service or frontend application"
  type        = string
}

variable "app_service_id" {
  description = "Resource ID of the app service or frontend service"
  type        = string
}

variable "custom_domain" {
  description = "Custom domain name to use for CDN (if different from domain_name)"
  type        = string
  default     = ""
}