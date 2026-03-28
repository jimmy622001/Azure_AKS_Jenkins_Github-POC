# Secure Development Workflow for Terraform Projects

This document outlines the recommended workflow for developing infrastructure code securely, especially when dealing with sensitive information like SSH keys and passwords.

## Development Workflow

### 1. Initial Setup

**Create a `.env` file for local development (never commit this file):**
```
# .env file (add to .gitignore)
TF_VAR_jenkins_admin_username=adminuser
TF_VAR_jenkins_admin_password=your_secure_password
TF_VAR_postgres_admin_password=your_secure_db_password
```

**Create a script to load environment variables:**
```bash
# set-env.sh
#!/bin/bash
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo "Environment variables loaded from .env file"
fi
```

### 2. Working with SSH Keys

**Generate SSH keys locally:**
```bash
# Generate a key pair for development
ssh-keygen -t rsa -b 4096 -f ./ssh_keys/jenkins_key -N ""

# Add to .gitignore:
# /ssh_keys/*
```

**Reference keys in Terraform:**
```terraform
# Using environment variables
variable "ssh_public_key" {
  description = "SSH public key for Jenkins VM"
  type        = string
  sensitive   = true
}

# In the resource
resource "azurerm_linux_virtual_machine" "jenkins" {
  # ...
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }
}
```

### 3. Environment-Specific Configuration

**Create template files:**
```
# terraform.tfvars.example
location                = "eastus"
resource_group_name     = "jenkins-rg"
jenkins_admin_username  = "admin" # Example value
# jenkins_admin_password = "Set this via environment variable"
# ssh_public_key         = "Set this via environment variable or Key Vault"
```

**For each environment:**
1. Use the example file as a template
2. Set sensitive values via environment variables or Key Vault

### 4. Continuous Integration

**In GitHub Actions:**
```yaml
name: Terraform Plan

on:
  pull_request:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        
      - name: Terraform Init
        run: terraform init
        env:
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
          
      - name: Terraform Plan
        run: terraform plan
        env:
          TF_VAR_jenkins_admin_username: ${{ secrets.JENKINS_ADMIN_USERNAME }}
          TF_VAR_jenkins_admin_password: ${{ secrets.JENKINS_ADMIN_PASSWORD }}
          TF_VAR_ssh_public_key: ${{ secrets.SSH_PUBLIC_KEY }}
```

### 5. Key Vault Integration

**Setup Key Vault:**
```terraform
# Create Key Vault if needed
resource "azurerm_key_vault" "infra_kv" {
  name                = "infra-secrets-kv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

# Add access policy for terraform service principal
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.infra_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List"
  ]
}
```

**Store and retrieve secrets:**
```terraform
# Store secrets (one-time setup)
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "jenkins-ssh-public-key"
  value        = var.ssh_public_key
  key_vault_id = azurerm_key_vault.infra_kv.id
}

# Retrieve secrets in regular configuration
data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "jenkins-ssh-public-key"
  key_vault_id = azurerm_key_vault.infra_kv.id
}

# Use in resources
resource "azurerm_linux_virtual_machine" "jenkins" {
  # ...
  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  }
}
```

## Code Review Checklist

Before submitting a pull request:

- [ ] No secrets or credentials in the code
- [ ] No sensitive data in comments
- [ ] Sensitive variables marked with `sensitive = true`
- [ ] `.tfvars` files not included in the commit (except examples)
- [ ] Proper referencing of secrets from secure sources
- [ ] No SSH keys or certificates committed

## Regular Maintenance

1. **Secret Rotation:**
   - Rotate all secrets every 90 days
   - Update Key Vault or CI/CD variables
   - No code changes needed if using proper references

2. **Access Reviews:**
   - Review Key Vault access policies quarterly
   - Review CI/CD variable access

3. **Vulnerability Scanning:**
   - Run Terraform security scans (tfsec, checkov, etc.)
   - Keep Terraform and providers updated