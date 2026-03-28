# Security Guidelines for Terraform Infrastructure

## Critical Security Practices

### 1. Secrets Management

#### Never commit secrets to Git
- Never store passwords, tokens, API keys, or private SSH keys in your code
- Use Azure Key Vault for storing and retrieving secrets
- Reference secrets in your code, don't hardcode them

#### Example of retrieving secrets from Key Vault:
```hcl
data "azurerm_key_vault_secret" "db_password" {
  name         = "postgres-admin-password"
  key_vault_id = data.azurerm_key_vault.project_kv.id
}

resource "azurerm_postgresql_server" "example" {
  # ... other configuration ...
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
}
```

### 2. Configuration Files

#### Using .tfvars files safely
- Never commit real `.tfvars` files containing sensitive data
- Add `*.tfvars` to your `.gitignore` file
- Use `.tfvars.example` files as templates with placeholder values
- Document the process for creating actual `.tfvars` files locally

### 3. SSH Key Management

See [SSH_KEY_MANAGEMENT.md](./SSH_KEY_MANAGEMENT.md) for detailed guidance on:
- How to generate SSH keys
- How to store keys in Azure Key Vault
- How to reference keys in Terraform code
- Key rotation practices

### 4. Git Security Practices

#### Use pre-commit hooks
- Install the provided Git hooks by running:
  ```bash
  # For Linux/macOS
  ./install-git-hooks.sh
  
  # For Windows
  .\install-git-hooks.bat
  ```
- These hooks will prevent you from accidentally committing sensitive data

#### If sensitive data is committed
- Follow instructions in [SECURITY_INCIDENT_RESPONSE.md](./SECURITY_INCIDENT_RESPONSE.md)
- Use the `cleanup-sensitive-data.sh` script to purge secrets from Git history
- Immediately rotate any credentials that were exposed

### 5. CI/CD Pipeline Security

- Use Azure DevOps variable groups or GitHub secrets for managing secrets in pipelines
- Never print secrets in logs
- Scan code for secrets before merging pull requests
- Use restricted service principals with least-privilege access

### 6. Infrastructure Security Best Practices

- Enable Azure Security Center for all resources
- Use NSGs to restrict network access
- Enable diagnostic logs for all services
- Use Azure Policy to enforce security standards
- Implement JIT access for VMs
- Enable Azure Defender for Kubernetes

## Security Tools

### Pre-commit Hooks
We provide pre-commit hooks to catch secrets before they're committed. Install them using:
```bash
./install-git-hooks.sh  # Linux/macOS
.\install-git-hooks.bat # Windows
```

### Cleaning Sensitive Data
If sensitive data has been committed, use:
```bash
./cleanup-sensitive-data.sh  # Linux/macOS
.\cleanup-sensitive-data.bat # Windows
```

## Security Contacts

If you discover a security vulnerability, please:
1. **Do not** create a public GitHub issue
2. Email security@example.com with details
3. Follow the steps in [SECURITY_INCIDENT_RESPONSE.md](./SECURITY_INCIDENT_RESPONSE.md)