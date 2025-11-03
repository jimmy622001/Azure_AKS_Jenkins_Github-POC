# Migration Guide: AWS to Azure

This guide provides step-by-step instructions for migrating from AWS ECS to Azure AKS infrastructure. It assumes you have already deployed the AWS infrastructure and want to migrate to the Azure infrastructure defined in this repository.

## Prerequisites

- Access to both AWS and Azure accounts
- AWS CLI and Azure CLI installed and configured
- Terraform installed (v1.0.0+)
- kubectl installed
- Both AWS and Azure infrastructure repositories available

## Migration Overview

The migration process follows these major steps:

1. Prepare Azure infrastructure
2. Migrate container images
3. Migrate database
4. Update CI/CD pipeline
5. Deploy applications to AKS
6. Test and validate
7. Cut over to Azure
8. Decommission AWS resources

## Detailed Migration Steps

### 1. Prepare Azure Infrastructure

#### 1.1 Deploy Base Infrastructure

```bash
# Navigate to dev environment directory
cd environments/dev

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
nano terraform.tfvars

# Initialize and apply Terraform
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

#### 1.2 Configure DNS (if using custom domains)

Set up Azure DNS zones or update your existing DNS provider to point to Azure resources.

#### 1.3 Set up monitoring and alerts

Configure additional monitoring requirements in Azure Monitor.

### 2. Migrate Container Images

#### 2.1 Set up ACR access

```bash
# Login to ACR
az acr login --name <acr-name>
```

#### 2.2 Pull images from ECR and push to ACR

```bash
# Script to migrate images from ECR to ACR
for image in $(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text); do
  # Get ECR image tags
  tags=$(aws ecr describe-images --repository-name $image --query 'imageDetails[].imageTags[]' --output text)
  
  for tag in $tags; do
    # Pull from ECR
    aws ecr get-login-password | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.<region>.amazonaws.com
    docker pull <aws-account-id>.dkr.ecr.<region>.amazonaws.com/$image:$tag
    
    # Tag for ACR
    docker tag <aws-account-id>.dkr.ecr.<region>.amazonaws.com/$image:$tag <acr-name>.azurecr.io/$image:$tag
    
    # Push to ACR
    az acr login --name <acr-name>
    docker push <acr-name>.azurecr.io/$image:$tag
  done
done
```

### 3. Migrate Database

#### 3.1 Create a backup of your AWS RDS PostgreSQL database

```bash
pg_dump -h <rds-hostname> -U <username> -d <database> -F c -b -v -f backup.dump
```

#### 3.2 Restore to Azure Database for PostgreSQL

```bash
# First create the database if it doesn't exist
psql -h <azure-postgres-server>.postgres.database.azure.com -U <username>@<azure-postgres-server> -c "CREATE DATABASE <database>;"

# Restore the dump file
pg_restore -h <azure-postgres-server>.postgres.database.azure.com -U <username>@<azure-postgres-server> -d <database> -v backup.dump
```

#### 3.3 Validate database migration

Run tests to ensure all data was properly migrated.

### 4. Update CI/CD Pipeline

#### 4.1 Update Jenkins configuration

Access your new Jenkins instance and configure:

- Install necessary plugins
- Set up credentials for GitHub, ACR, and AKS
- Configure Azure CLI in Jenkins

#### 4.2 Update pipeline scripts

Modify your Jenkinsfile to use Azure-specific commands:

```groovy
pipeline {
    agent any
    
    environment {
        ACR_SERVER = '<acr-name>.azurecr.io'
        ACR_CREDENTIALS_ID = 'acr-credentials'
        AKS_RESOURCE_GROUP = 'aks-jenkins-dev-rg'
        AKS_CLUSTER_NAME = 'aks-jenkins-dev-cluster'
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t $ACR_SERVER/myapp:$BUILD_NUMBER .'
            }
        }
        
        stage('Push to ACR') {
            steps {
                withCredentials([azureServicePrincipal('azure-credentials')]) {
                    sh '''
                    az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                    az acr login --name <acr-name>
                    docker push $ACR_SERVER/myapp:$BUILD_NUMBER
                    '''
                }
            }
        }
        
        stage('Deploy to AKS') {
            steps {
                withCredentials([azureServicePrincipal('azure-credentials')]) {
                    sh '''
                    az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                    az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME
                    sed -i "s|image:.*|image: $ACR_SERVER/myapp:$BUILD_NUMBER|g" kubernetes/deployment.yaml
                    kubectl apply -f kubernetes/deployment.yaml
                    '''
                }
            }
        }
    }
}
```

### 5. Deploy Applications to AKS

#### 5.1 Prepare Kubernetes manifests

- Update image references to ACR
- Update service configurations
- Add Azure-specific configurations (e.g., Ingress)

#### 5.2 Deploy applications

```bash
# Connect to AKS
az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>

# Apply manifests
kubectl apply -f ./kubernetes/
```

### 6. Test and Validate

#### 6.1 Functional testing

Test all application functionality in the Azure environment.

#### 6.2 Performance testing

Run performance tests to ensure the new environment meets performance requirements.

#### 6.3 Security testing

Verify security configurations and access controls.

### 7. Cut Over to Azure

#### 7.1 Update DNS records

Update DNS records to point to Azure services.

#### 7.2 Verify client connectivity

Verify clients can connect to applications through the new Azure endpoints.

#### 7.3 Monitor for issues

Closely monitor the application during the cutover period.

### 8. Decommission AWS Resources

Once the migration is complete and verified:

```bash
# Navigate to AWS infrastructure directory
cd /path/to/aws/terraform

# Destroy AWS resources (be careful!)
terraform destroy
```

## Post-Migration Tasks

- Update documentation
- Train team members on Azure-specific operations
- Implement additional Azure features as needed
- Review costs and optimize as necessary

## Rollback Plan

In case of migration issues, be prepared to:

1. Switch DNS records back to AWS endpoints
2. Restore database backups to AWS RDS
3. Continue running on AWS until issues are resolved

## Common Issues and Solutions

### Connectivity Issues

**Problem**: Applications can't connect to Azure Database for PostgreSQL
**Solution**: Check NSG rules, firewall settings, and private endpoints

### Performance Issues

**Problem**: Slower performance in Azure
**Solution**: Review Azure VM sizes, AKS node sizes, and connection pooling settings

### Authentication Issues

**Problem**: Applications can't authenticate with Azure services
**Solution**: Verify managed identities are properly configured and permissions are assigned

## References

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure Database for PostgreSQL Documentation](https://docs.microsoft.com/en-us/azure/postgresql/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)