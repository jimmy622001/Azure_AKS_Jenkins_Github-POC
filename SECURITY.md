# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| 0.9.x   | :white_check_mark: |
| 0.8.x   | :x:                |
| < 0.8   | :x:                |

## Reporting a Vulnerability

We take the security of our infrastructure as code seriously. If you believe you've found a security vulnerability in this project, please follow these steps:

1. **Do not disclose the vulnerability publicly**
2. **Email us at security@example.com with details about the issue**
3. **Include the following information in your report**:
   - Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
   - Full paths of source file(s) related to the issue
   - Location of the affected source code (tag/branch/commit or direct URL)
   - Any special configuration required to reproduce the issue
   - Step-by-step instructions to reproduce the issue
   - Proof-of-concept or exploit code (if possible)
   - Impact of the issue, including how an attacker might exploit the issue

## Response Policy

- We aim to acknowledge receipt of vulnerability reports within 48 hours
- We will provide an initial assessment of the vulnerability within 5 business days
- We prioritize fixing critical vulnerabilities as soon as possible, typically within 30 days

## Security Best Practices

This project implements several security best practices:

1. **Infrastructure Security**:
   - All resources deployed with least privilege principles
   - Network security groups and private endpoints where appropriate
   - Key Vault for secret management
   - Network isolation between components

2. **AKS Security**:
   - Azure Policy integration
   - Azure Active Directory integration
   - Regular patching of node images
   - Pod Security Policies enabled

3. **Jenkins Security**:
   - Authentication through Azure AD
   - Authorization using role-based access control
   - Secure credential storage
   - Pipeline security with proper approval workflows

4. **Monitoring and Compliance**:
   - Azure Security Center integration
   - Continuous security monitoring
   - Compliance checks through CI/CD pipelines

See our [OWASP_SECURITY.md](docs/OWASP_SECURITY.md) and [SECURITY_SCANNING.md](docs/SECURITY_SCANNING.md) documents for more detailed information on our security practices.