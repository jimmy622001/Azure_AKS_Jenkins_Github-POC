# Azure AKS Jenkins GitHub Environment Setup

This document outlines the environment setup for the Azure AKS Jenkins GitHub project, explaining how we've implemented the key requirements.

## Environment Structure

The project includes three distinct environments:

1. **Production (`/environments/prod/`)**
   - Domain: example.com with CDN enabled
   - Full-scale deployment with all resources
   - Connected to `main` branch in GitHub

2. **Development (`/environments/dev/`)**
   - Domain: dev.example.com (without CDN)
   - Scaled-down resources for cost efficiency
   - Connected to `develop` branch in GitHub

3. **Disaster Recovery Pilot Light (`/environments/dr-pilot-light/`)**
   - Located in a different Azure region (westus2)
   - Minimal resources in normal operation
   - Can be scaled up during failover
   - Connected to `dr` branch in GitHub

## Key Implementation Details

### 1. Separate Environment Stacks

Each environment runs in a physically separate stack with:
- Independent resource groups
- Different Azure regions (especially for DR)
- Different VNet address spaces
- Environment-specific Terraform state files
- Customized scaling settings for each environment

### 2. Domain Configuration

- **Production**: Uses example.com with Azure CDN for global content delivery
- **Development**: Uses dev.example.com subdomain without CDN
- **DR**: No active domain in normal state, but can take over example.com during failover

### 3. GitHub Branch Integration

Each environment has a dedicated GitHub branch:
- `main` branch for Production
- `develop` branch for Development
- `dr` branch for DR Pilot Light

CI/CD for each environment runs independently via:
- Environment-specific GitHub workflows
- Branch-specific pipeline triggers
- Separate Terraform state files

### 4. Infrastructure and Application Separation

The deployment is separated into:
- **Infrastructure deployment**: Terraform for Azure resources
- **Application deployment**: Container builds and Kubernetes deployments

This separation ensures that:
- Infrastructure changes don't trigger application rebuilds
- Application updates don't waste time redeploying unchanged infrastructure
- Each can be scaled and managed independently

## Deployment Methods

### Infrastructure Deployment

```bash
# For production
terraform -chdir=environments/prod init
terraform -chdir=environments/prod apply

# For development
terraform -chdir=environments/dev init
terraform -chdir=environments/dev apply

# For DR pilot light
terraform -chdir=environments/dr-pilot-light init
terraform -chdir=environments/dr-pilot-light apply

# For DR failover activation
terraform -chdir=environments/dr-pilot-light apply -var="is_failover_active=true"
```

### CI/CD Options

1. **Jenkins Pipeline**
   - Parameters for environment selection: `dev`, `prod`, or `dr-pilot-light`
   - Parameters for deployment type: `infrastructure`, `application`, or `both`
   - Options for plan-only mode and DR failover activation

2. **GitHub Actions**
   - Separate workflows for each environment and deployment type
   - Automatic triggers based on branch and path changes
   - Manual triggers with workflow_dispatch

## DR Failover Process

1. Activate the DR failover mode:
   ```bash
   terraform -chdir=environments/dr-pilot-light apply -var="is_failover_active=true"
   ```

2. This will:
   - Scale up the DR resources
   - Update DNS records to point example.com to the DR infrastructure
   - Activate the standby systems

3. After the primary region is restored:
   ```bash
   terraform -chdir=environments/dr-pilot-light apply -var="is_failover_active=false"
   ```

## Security Notes

- Each environment uses separate Azure credentials and service principals
- GitHub secrets are environment-specific
- Key Vault is used for storing sensitive values
- DR environment has read-only replication of production secrets in normal state