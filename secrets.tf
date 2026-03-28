# Sensitive data sources - This file handles secure secret retrieval
# These data sources fetch secrets from Azure Key Vault and assign them to sensitive variables

data "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgres-admin-password"
  key_vault_id = module.security.key_vault_id
  
  lifecycle {
    postcondition {
      condition     = self.value != ""
      error_message = "PostgreSQL password secret cannot be empty."
    }
  }
}

data "azurerm_key_vault_secret" "jenkins_ssh_key" {
  name         = "jenkins-ssh-public-key"
  key_vault_id = module.security.key_vault_id
  
  lifecycle {
    postcondition {
      condition     = self.value != ""
      error_message = "Jenkins SSH key secret cannot be empty."
    }
  }
}

# Override sensitive variables with Key Vault values
# This ensures secrets are fetched securely and not exposed in logs
locals {
  postgres_admin_password = sensitive(data.azurerm_key_vault_secret.postgres_password.value)
  jenkins_ssh_key        = sensitive(data.azurerm_key_vault_secret.jenkins_ssh_key.value)
}
