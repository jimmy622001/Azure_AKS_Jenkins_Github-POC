# Azure AKS Jenkins GitHub Infrastructure POC

This repository contains Terraform code to deploy and manage a complete infrastructure for running applications on Azure Kubernetes Service (AKS) with Jenkins for CI/CD, integrated with GitHub for source control.

## Architecture

The infrastructure consists of:

1. **Azure Kubernetes Service (AKS)** cluster for container orchestration
2. **Jenkins** for CI/CD pipelines, running on Azure VMs
3. **Azure Database for PostgreSQL** for application and Jenkins data
4. **Azure Key Vault** for secrets management
5. **Azure Monitor** for monitoring and alerting
6. **GitHub integration** for source code management and webhooks

### Architecture Diagram

For a visual representation of the architecture, see [architecture-diagram.md](docs/architecture-diagram.md)

## Features

- **Multi-environment Support**: Separate configurations for dev, prod, and DR environments
- **Security-focused**: Network isolation, RBAC, Azure AD integration, managed identities
- **High Availability**: AKS deployed across availability zones, database replication
- **CI/CD Pipeline**: Automated build, test, and deployment pipelines with Jenkins
- **Infrastructure as Code**: All resources managed with Terraform
- **Disaster Recovery**: Pilot light DR setup in a secondary region
- **Monitoring & Alerting**: Azure Monitor integration with custom dashboards
- **Cost Optimization**: Right-sized resources with auto-scaling

## Prerequisites

Before deploying this infrastructure, you need:

- Azure subscription with contributor access
- Terraform 1.0.0 or newer
- Azure CLI 2.30.0 or newer
- GitHub account with admin access to target repositories

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/Azure_AKS_Jenkins_Github.git
cd Azure_AKS_Jenkins_Github
```

### 2. Configure the environment

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific configuration
```

### 3. Deploy the infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access the infrastructure

After deployment completes, you can access:

- Jenkins: URL will be in the terraform outputs
- AKS: Configure kubectl with `az aks get-credentials`

## Module Structure

The repository is organized into the following modules:

- **aks**: Kubernetes cluster and node pools
- **cicd**: Jenkins and related resources
- **network**: Virtual network, subnets, and security
- **database**: Azure Database for PostgreSQL
- **identity**: Azure AD integration and managed identities
- **monitoring**: Azure Monitor, Log Analytics, and alerts
- **security**: Key Vault, network security groups, and policies

## Environment Structure

```
environments/
├── dev/           # Development environment
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── prod/          # Production environment
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── dr-pilot-light/ # Disaster Recovery environment
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

## Documentation

- [Usage Guide](Usage.md): Detailed usage instructions
- [AWS to Azure Comparison](docs/AWS_AZURE_COMPARISON.md): Comparison between AWS ECS and Azure AKS
- [Migration Guide](docs/MIGRATION_GUIDE.md): Guide for migrating from AWS to Azure
- [CI/CD Integration](docs/CI_CD_INTEGRATION.md): Integrating applications with the CI/CD pipeline
- [Disaster Recovery Plan](docs/DR_PLAN.md): DR procedures and recovery information
- [OWASP Security](docs/OWASP_SECURITY.md): Security practices based on OWASP guidelines
- [Security Scanning](docs/SECURITY_SCANNING.md): Infrastructure and application security scanning

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Security

For security-related information, please see [SECURITY.md](SECURITY.md).

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
