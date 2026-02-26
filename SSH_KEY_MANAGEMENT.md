# SSH Keys Management Guide

## IMPORTANT: Security Best Practices

1. **NEVER commit SSH keys to Git repositories**
2. **NEVER include SSH keys in Docker images**
3. **NEVER share SSH keys via email or messaging platforms**

## Recommended Approach for SSH Keys

### For Development Environments
1. Generate SSH keys locally:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/[PROJECT_NAME]_key -C "[YOUR_EMAIL]"
   ```
2. Store the public key in Azure Key Vault:
   ```bash
   az keyvault secret set --vault-name [YOUR_KEYVAULT_NAME] --name "[ENV]-ssh-public-key" --value "$(cat ~/.ssh/[PROJECT_NAME]_key.pub)"
   ```
3. Store the private key in Azure Key Vault:
   ```bash
   az keyvault secret set --vault-name [YOUR_KEYVAULT_NAME] --name "[ENV]-ssh-private-key" --value "$(cat ~/.ssh/[PROJECT_NAME]_key)"
   ```
4. Reference the key in your Terraform variables:
   ```hcl
   ssh_public_key = data.azurerm_key_vault_secret.ssh_public_key.value
   ```

### For CI/CD Pipelines
1. Use Azure DevOps variable groups or GitHub secrets to store SSH keys
2. Pass the secrets to your Terraform runs using environment variables
3. Never print or log the values of these environment variables

### Key Rotation
1. Rotate SSH keys every 90 days
2. Update the keys in Azure Key Vault
3. Run Terraform to update the infrastructure with the new keys

## Azure Key Vault Integration

See the example in `main.tf` for how to retrieve SSH keys from Azure Key Vault for use in your Terraform code:

```hcl
data "azurerm_key_vault" "project_kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}

data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "${var.environment}-ssh-public-key"
  key_vault_id = data.azurerm_key_vault.project_kv.id
}
```