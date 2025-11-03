terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0" # Latest version
    }
  }
  required_version = ">= 1.0.0"
}