# Git Security Best Practices for Infrastructure Code

## 1. Managing Secrets

### Do's
- ✅ Use Azure Key Vault, AWS Secrets Manager, or HashiCorp Vault to store secrets
- ✅ Use environment variables for CI/CD pipelines
- ✅ Mark variables as sensitive in Terraform: `sensitive = true`
- ✅ Use `.tfvars.example` files with dummy/redacted values as templates
- ✅ Consider using a secrets scanning tool in your CI pipeline (GitGuardian, Gitleaks, etc.)

### Don'ts
- ❌ Never commit real credentials, even temporarily
- ❌ Don't store sensitive values in Terraform code or `.tfvars` files
- ❌ Avoid using default or predictable passwords in examples
- ❌ Don't disable security scanning tools

## 2. Terraform-Specific Practices

### State File Management
- Store state files in a secure, encrypted backend (Azure Storage, S3, etc.)
- Ensure state locking is enabled
- Control access to the state storage with tight IAM permissions

### Variable Handling
```terraform
# In variables.tf
variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

# Reference in your code
resource "azurerm_virtual_machine" "vm" {
  # ...
  admin_password = var.admin_password
}
```

### Data Sources for Secure Values
```terraform
# Fetching secrets from Key Vault
data "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  key_vault_id = data.azurerm_key_vault.example.id
}

# Using in resources
resource "azurerm_virtual_machine" "vm" {
  # ...
  admin_password = data.azurerm_key_vault_secret.vm_password.value
}
```

## 3. SSH Key Management

### Generation and Storage
- Generate SSH keys locally, not in the repo
- Store public keys in secure storage and reference them
- Consider using Terraform to generate keys if needed:

```terraform
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Output only the public key
output "ssh_public_key" {
  value     = tls_private_key.ssh.public_key_openssh
  sensitive = false
}

# The private key is sensitive
output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}
```

## 4. CI/CD Security

### Pipeline Configuration
- Use environment variables or pipeline secrets for sensitive values
- Avoid writing secrets to disk during builds
- Consider using OpenID Connect for cloud authentication instead of static credentials
- Implement proper RBAC for your CI/CD system

### Example: Azure DevOps Variable Group
```yaml
variables:
- group: 'Terraform-Production-Secrets'

steps:
- script: |
    terraform apply -var="admin_password=$(ADMIN_PASSWORD)" -auto-approve
  displayName: 'Apply Terraform'
```

## 5. Regular Auditing

- Run periodic secret scanning on your repositories
- Review access permissions regularly
- Rotate secrets and credentials on a schedule
- Update dependencies to address security vulnerabilities

## 6. Tools for Secret Detection

- [GitGuardian](https://www.gitguardian.com/)
- [Gitleaks](https://github.com/zricethezav/gitleaks)
- [TruffleHog](https://github.com/trufflesecurity/trufflehog)
- [git-secrets](https://github.com/awslabs/git-secrets)
- [detect-secrets](https://github.com/Yelp/detect-secrets)

## 7. If Secrets Are Accidentally Committed

1. Rotate the credentials immediately
2. Remove from Git history using BFG Repo-Cleaner or git-filter-repo
3. Force push the cleaned repository
4. Notify team members to update their local repositories
5. Review security logs for potential unauthorized access