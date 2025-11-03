# Identity Module - main.tf
# Creates managed identities for AKS and sets up appropriate RBAC

# User-assigned Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Role Assignment for AKS Identity to manage network resources
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Data source for the current subscription
data "azurerm_subscription" "current" {}

# User-assigned Managed Identity for Jenkins
resource "azurerm_user_assigned_identity" "jenkins_identity" {
  name                = "jenkins-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Role Assignment for Jenkins Identity to deploy to AKS
resource "azurerm_role_assignment" "jenkins_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.jenkins_identity.principal_id
}