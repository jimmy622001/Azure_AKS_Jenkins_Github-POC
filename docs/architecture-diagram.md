# Architecture Diagrams

## Azure AKS Jenkins GitHub Architecture

The following diagram illustrates the Azure architecture for the AKS Jenkins GitHub integration:

```mermaid
graph TD
    subgraph "Azure Cloud"
        subgraph "Resource Group"
            subgraph "Virtual Network"
                subgraph "AKS Subnet"
                    AKS[AKS Cluster]
                end
                
                subgraph "Database Subnet"
                    PSQL[Azure Database for PostgreSQL]
                end
                
                subgraph "Jenkins Subnet"
                    VM[Jenkins VM]
                end
                
                subgraph "Gateway Subnet"
                    APPGW[Application Gateway]
                end
            end
            
            KV[Key Vault]
            ACR[Azure Container Registry]
            MONITOR[Azure Monitor]
            DDOS[DDoS Protection]
            
            AKS -- "Pulls from" --> ACR
            VM -- "Pushes to" --> ACR
            VM -- "Deploys to" --> AKS
            AKS -- "Stores data in" --> PSQL
            AKS -- "Gets secrets from" --> KV
            VM -- "Gets secrets from" --> KV
            APPGW -- "Routes to" --> AKS
            MONITOR -- "Monitors" --> AKS
            MONITOR -- "Monitors" --> PSQL
            MONITOR -- "Monitors" --> VM
            MONITOR -- "Logs" --> LOGS[Log Analytics]
        end
    end
    
    INTERNET((Internet)) -- "HTTPS" --> APPGW
    DEVS((Developers)) -- "SSH/HTTPS" --> VM
    GITHUB[GitHub] -- "Webhooks" --> VM
    GITHUB -- "Source Code" --> VM
```

## Network Architecture

The following diagram shows the network architecture with security components:

```mermaid
graph TD
    subgraph "Azure Virtual Network"
        subgraph "AKS Subnet"
            AKS_NSG[Network Security Group]
            AKS[AKS Cluster]
            AKS_NSG -- "Secures" --> AKS
        end
        
        subgraph "Database Subnet"
            DB_NSG[Network Security Group]
            PSQL[PostgreSQL]
            PE_PSQL[Private Endpoint]
            DB_NSG -- "Secures" --> PSQL
            PE_PSQL -- "Connects to" --> PSQL
        end
        
        subgraph "Jenkins Subnet"
            J_NSG[Network Security Group]
            VM[Jenkins VM]
            J_NSG -- "Secures" --> VM
        end
        
        subgraph "Gateway Subnet" 
            GW_NSG[Network Security Group]
            APPGW[Application Gateway + WAF]
            GW_NSG -- "Secures" --> APPGW
        end
        
        VNET_PEERING[VNet Peering]
    end
    
    subgraph "Private DNS Zones"
        DNS_KV[keyvault.azure.net]
        DNS_PSQL[postgres.database.azure.net]
        DNS_ACR[azurecr.io]
    end
    
    subgraph "Key Resources"
        ACR[Container Registry]
        KV[Key Vault]
        PE_KV[Private Endpoint]
    end
    
    DDOS[DDoS Protection] -- "Protects" --> VNET
    
    PE_KV -- "Connects to" --> KV
    DNS_KV -- "Resolves" --> PE_KV
    DNS_PSQL -- "Resolves" --> PE_PSQL
    DNS_ACR -- "Resolves" --> ACR
    
    INTERNET((Internet)) -- "Inbound Traffic" --> APPGW
```

## CI/CD Pipeline Flow

The following diagram illustrates the CI/CD pipeline flow from GitHub to AKS:

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant JK as Jenkins VM
    participant ACR as Azure Container Registry
    participant AKS as AKS Cluster
    
    Dev->>GH: Push code
    GH->>JK: Trigger webhook
    JK->>GH: Clone repository
    
    JK->>JK: Build Docker image
    JK->>ACR: Push image
    JK->>AKS: Deploy application
    
    JK->>JK: Run tests
    JK->>GH: Update status
    
    AKS->>AKS: Scale application
    AKS->>AKS: Route traffic
```

## Security Components

The following diagram shows how the security components integrate:

```mermaid
graph TD
    subgraph "Identity & Access"
        AAD[Azure Active Directory]
        MI[Managed Identities]
        RBAC[Role-Based Access Control]
    end
    
    subgraph "Secret Management"
        KV[Key Vault]
        KV_SECRETS[Secrets]
        KV_CERTS[Certificates]
        KV_KEYS[Keys]
    end
    
    subgraph "Network Security"
        NSG[Network Security Groups]
        PE[Private Endpoints]
        WAF[Web Application Firewall]
        DDOS[DDoS Protection]
    end
    
    subgraph "Monitoring & Security"
        AZM[Azure Monitor]
        LOGS[Log Analytics]
        MDC[Microsoft Defender for Cloud]
    end
    
    AAD --> RBAC
    AAD --> MI
    MI --> KV
    MI --> AKS[AKS]
    MI --> ACR[Container Registry]
    
    KV --> KV_SECRETS
    KV --> KV_CERTS
    KV --> KV_KEYS
    
    NSG --> VNET[Virtual Network]
    PE --> KV
    PE --> PSQL[PostgreSQL]
    WAF --> APPGW[Application Gateway]
    DDOS --> VNET
    
    AZM --> LOGS
    LOGS --> MDC
    AZM --> AKS
    AZM --> PSQL
    AZM --> VM[Jenkins VM]
    AZM --> ACR
```

## High Availability and Disaster Recovery

```mermaid
graph TD
    subgraph "Primary Region"
        AKS1[AKS Cluster]
        PSQL1[Azure Database for PostgreSQL]
        ACR1[Azure Container Registry]
    end
    
    subgraph "Secondary Region"
        AKS2[AKS Cluster - Standby]
        PSQL2[Azure Database for PostgreSQL - Replica]
        ACR2[Azure Container Registry - Replica]
    end
    
    TM[Traffic Manager]
    GEO_BACKUP[Geo-Redundant Backups]
    
    AKS1 --> PSQL1
    AKS2 --> PSQL2
    
    PSQL1 -- "Replication" --> PSQL2
    ACR1 -- "Geo-replication" --> ACR2
    
    TM -- "Active endpoint" --> AKS1
    TM -- "Passive endpoint" --> AKS2
    
    PSQL1 --> GEO_BACKUP
    AKS1 --> GEO_BACKUP
```