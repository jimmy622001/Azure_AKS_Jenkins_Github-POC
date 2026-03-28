# Security Incident Response Guide

## What Constitutes a Security Incident?

- Exposure of API keys, passwords, or private SSH keys in Git history
- Accidental commit of terraform.tfvars files with real credentials
- Public exposure of sensitive configuration details
- Unauthorized access to resources
- Data breaches or other security vulnerabilities

## Immediate Response Steps

### 1. If Credentials Were Exposed in Git:

#### Remove the credentials from Git history
1. Use the `cleanup-sensitive-data.sh` (or `.bat`) script:
   ```bash
   # For Linux/macOS
   ./cleanup-sensitive-data.sh
   
   # For Windows
   .\cleanup-sensitive-data.bat
   ```
2. Follow the prompts to specify the file(s) and pattern(s) to remove

#### Force push the cleaned repository
```bash
git push origin --force
```

**Note:** This will rewrite history! Ensure all team members are aware and take appropriate steps.

### 2. Rotate All Exposed Credentials Immediately:

#### Azure Service Principals
```bash
az ad sp credential reset --name "your-sp-name"
```

#### SSH Keys
Generate new key pairs and update them in Azure Key Vault and on all systems.

#### Database Passwords
Update database passwords in the Azure Portal or using CLI/PowerShell and update the corresponding secrets in Key Vault.

#### GitHub Tokens
Revoke and regenerate affected tokens in GitHub Settings.

### 3. Verify Affected Resources

1. Check access logs for suspicious activity
2. Enable additional monitoring temporarily
3. Verify resource configurations match expected state
4. Run security scanning tools against potentially affected resources

### 4. Document the Incident

Create an incident report including:
- What happened
- When it was discovered
- What credentials were exposed
- What actions were taken
- What systems were affected
- Remediation steps taken
- Lessons learned

### 5. Preventive Measures

- Review and strengthen pre-commit hooks
- Conduct security training for team members
- Improve documentation around handling secrets
- Consider adding automated secret scanning to CI/CD pipelines

## Contact Information

**Security Team:** security@example.com
**On-call Engineer:** oncall@example.com | Phone: +1-555-123-4567

## Additional Resources

- [Git BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) - Alternative tool for cleaning sensitive data
- [Azure Security Center Documentation](https://docs.microsoft.com/en-us/azure/security-center/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)