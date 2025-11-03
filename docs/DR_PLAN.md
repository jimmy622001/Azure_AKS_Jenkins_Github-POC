# Disaster Recovery Plan

This document outlines the disaster recovery (DR) procedures for the Azure AKS Jenkins GitHub infrastructure.

## Table of Contents

1. [Overview](#overview)
2. [Recovery Point Objective (RPO) and Recovery Time Objective (RTO)](#recovery-point-objective-rpo-and-recovery-time-objective-rto)
3. [Disaster Recovery Approaches](#disaster-recovery-approaches)
4. [DR Environment Setup](#dr-environment-setup)
5. [Failover Procedures](#failover-procedures)
6. [Failback Procedures](#failback-procedures)
7. [Testing and Validation](#testing-and-validation)
8. [Roles and Responsibilities](#roles-and-responsibilities)

## Overview

The disaster recovery strategy for this infrastructure is designed to recover critical systems and data in the event of a major disruption to the primary Azure region. The strategy employs a pilot light approach where a minimal version of the environment is kept running in a secondary region.

## Recovery Point Objective (RPO) and Recovery Time Objective (RTO)

- **RPO (Recovery Point Objective)**: 15 minutes
  - Maximum acceptable amount of data loss measured in time
  - Achieved through regular data replication to secondary region
  
- **RTO (Recovery Time Objective)**: 4 hours
  - Maximum acceptable downtime
  - Time to restore service operation in DR region

## Disaster Recovery Approaches

### Pilot Light Approach

Our DR strategy primarily uses the "pilot light" approach:

1. Core infrastructure components are deployed in the DR region but scaled down
2. Data is continuously replicated from primary to DR region
3. In a disaster, the DR environment is scaled up to handle production load
4. DNS/traffic is redirected to the DR environment

### Components in DR Environment

- AKS cluster (minimal node count)
- Azure Container Registry (geo-replicated)
- Azure Key Vault (geo-replicated)
- Azure SQL Database (geo-replication)
- Virtual Network and associated resources
- Jenkins instance (standby)

## DR Environment Setup

The DR environment is defined in the `environments/dr-pilot-light` directory and can be deployed with:

```bash
cd environments/dr-pilot-light
terraform init
terraform apply
```

### Data Replication Configuration

- **Databases**: Azure SQL Database geo-replication
- **Storage**: Azure Storage Account geo-redundant storage (GRS)
- **Container Images**: Azure Container Registry geo-replication
- **Configuration**: Azure Key Vault soft-delete and backup features

## Failover Procedures

### Disaster Assessment

1. Confirm disaster status and impact assessment
2. Declare disaster and initiate recovery plan
3. Notify stakeholders

### Failover Execution

1. **Scale Up DR Resources**:
   ```bash
   terraform apply -var="environment=dr" -var="is_disaster_recovery=true"
   ```

2. **Promote Replicated Databases**:
   ```bash
   az sql database failover --resource-group myResourceGroup --server myserver --name myDB
   ```

3. **Update DNS and Traffic Routing**:
   ```bash
   az network traffic-manager profile update --resource-group myResourceGroup --name myTrafficManager --routing-method Priority
   ```

4. **Validate Application Functionality**:
   - Run smoke tests against DR environment
   - Verify critical functions are operational

5. **Resume CI/CD Pipelines**:
   - Update Jenkins configuration to deploy to DR environment
   - Verify pipeline functionality

## Failback Procedures

Once the primary region becomes available again:

1. Assess primary region status and readiness
2. Synchronize data from DR to primary region
3. Validate primary environment functionality
4. Redirect traffic back to primary environment
5. Scale down DR environment to pilot light state

## Testing and Validation

The DR plan should be tested at least twice a year:

1. **Scheduled DR Drills**:
   - Perform complete failover test to DR environment
   - Document issues and improvement areas
   - Update DR plan based on lessons learned

2. **Component-Level Testing**:
   - Test database failover separately
   - Test storage failover separately
   - Test application deployment to DR environment

## Roles and Responsibilities

| Role | Responsibilities |
|------|------------------|
| DR Coordinator | Overall coordination of DR activities |
| Infrastructure Engineer | Execute infrastructure failover steps |
| Database Administrator | Manage database failover process |
| Application Owner | Verify application functionality |
| Security Officer | Ensure security controls in DR environment |

## Documentation and Record Keeping

All DR activities should be documented, including:
- Test results and lessons learned
- Actual disaster events and response performance
- Updates to the DR plan
- Changes to DR infrastructure

## Communication Plan

During a DR event, communication will follow this chain:
1. DR Coordinator notifies executive leadership
2. Team leads notify their respective teams
3. Regular status updates provided via predefined communication channels
4. External stakeholders notified per the business continuity plan