# Network Module - variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_configurations" {
  description = "Configuration for all subnets"
  type = map(object({
    address_prefix = string
    service_endpoints = list(string)
    delegation = optional(map(object({
      name    = string
      actions = list(string)
    })))
    # These properties remain the same for backward compatibility
    # But are mapped to the new string attributes in the resource
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}