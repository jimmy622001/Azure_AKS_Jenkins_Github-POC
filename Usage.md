# Azure AKS Jenkins GitHub - Usage Guide

This guide provides instructions for deploying, managing, and maintaining the Azure AKS Jenkins GitHub infrastructure.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Deployment Instructions](#deployment-instructions)
3. [Environment Management](#environment-management)
4. [Patching and Update Management](#patching-and-update-management)
5. [Blue/Green Deployments](#bluegreen-deployments)
6. [Disaster Recovery](#disaster-recovery)
7. [Monitoring and Alerting](#monitoring-and-alerting)
8. [Troubleshooting](#troubleshooting)
9. [Security Best Practices](#security-best-practices)

## Prerequisites

Before deploying the infrastructure, ensure you have:

- Terraform 1.0.0 or newer
- Azure CLI configured with appropriate permissions
- Azure subscription with required resource providers enabled
- GitHub access token with repo and admin:repo_hook permissions

## Deployment Instructions

### Basic Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Azure_AKS_Jenkins_Github.git
   cd Azure_AKS_Jenkins_Github
   ```

2. Configure your deployment variables:
   ```bash
   cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
   ```
   Edit the `terraform.tfvars` file with your specific configuration.

3. Initialize Terraform:
   ```bash
   cd environments/dev
   terraform init
   ```

4. Deploy the infrastructure:
   ```bash
   terraform apply
   ```

### Advanced Deployment Options

For production environments:
```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with production settings
terraform init
terraform apply
```

## Environment Management

### Managing Multiple Environments

This repository includes configurations for multiple environments:
- `environments/dev` - Development environment
- `environments/prod` - Production environment
- `environments/dr-pilot-light` - Disaster Recovery environment

### Environment-Specific Configuration

Each environment can have its own configuration by modifying the appropriate `terraform.tfvars` file.

## Patching and Update Management

### AKS Updates

Azure manages the Kubernetes control plane. For node updates:

```bash
# Check for available updates
az aks get-upgrades --resource-group myResourceGroup --name myAKSCluster

# Perform upgrade
az aks upgrade --resource-group myResourceGroup --name myAKSCluster --kubernetes-version 1.xx.x
```

### Jenkins Updates

Jenkins can be updated through the UI or by updating the image version in your Terraform configuration.

## Blue/Green Deployments

The infrastructure supports blue/green deployments for both AKS clusters and applications:

1. Deploy the new (green) environment
2. Test the new environment
3. Switch traffic to the green environment
4. Monitor for issues
5. Decommission the old (blue) environment if no issues are found

## Disaster Recovery

Refer to the [MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md) and [docs/DR_PLAN.md](docs/DR_PLAN.md) for detailed disaster recovery procedures.

## Monitoring and Alerting

The infrastructure includes Azure Monitor and Log Analytics integration. Key metrics are tracked, and alerts can be configured through the Azure Portal or Terraform.

## Troubleshooting

### Common Issues

- **AKS Connectivity Issues**: Check network security groups and VNet peering
- **Jenkins Pipeline Failures**: Verify service principal permissions and container registry access
- **Terraform Apply Failures**: Check Azure service quotas and resource provider registration

### Logs

Access logs through:
- Azure Portal (Log Analytics)
- `kubectl logs` for AKS workloads
- Jenkins UI for CI/CD logs

## Security Best Practices

Refer to [OWASP_SECURITY.md](docs/OWASP_SECURITY.md) and [SECURITY_SCANNING.md](docs/SECURITY_SCANNING.md) for security recommendations and scanning procedures.

## Contributing

Please read the [CONTRIBUTING.md](CONTRIBUTING.md) file for details on our code of conduct and the process for submitting pull requests.