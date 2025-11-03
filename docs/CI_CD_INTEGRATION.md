# CI/CD Integration Guide

This document provides details on integrating your applications with the Jenkins CI/CD pipeline and GitHub workflows in the Azure AKS Jenkins GitHub infrastructure.

## Table of Contents

1. [Overview](#overview)
2. [GitHub Integration](#github-integration)
3. [Jenkins Pipeline Configuration](#jenkins-pipeline-configuration)
4. [AKS Deployment Strategies](#aks-deployment-strategies)
5. [Secrets Management](#secrets-management)
6. [Build Optimization](#build-optimization)
7. [Testing Framework](#testing-framework)
8. [Quality Gates](#quality-gates)
9. [Monitoring and Observability](#monitoring-and-observability)

## Overview

The CI/CD pipeline in this infrastructure is designed to automate the build, test, and deployment of applications to the Azure Kubernetes Service (AKS) cluster. It integrates GitHub for source control, Jenkins for orchestration, and various security scanning tools to ensure code quality and security.

### Architecture

```
GitHub Repository -> GitHub Actions -> Jenkins -> Azure Container Registry -> AKS
                       |                |              |
                       v                v              v
                  Code Quality    Security Scans    Image Scans
```

## GitHub Integration

### Webhook Configuration

Jenkins is configured to receive webhooks from GitHub to trigger builds automatically.

1. Webhooks are already set up in the infrastructure
2. New repositories can be added by modifying the `github_repos` variable in `terraform.tfvars`

### Branch Protection Rules

Implement these GitHub branch protection rules for security:

1. Require pull request reviews
2. Require status checks to pass
3. Require signed commits
4. Include administrators in restrictions

Example GitHub protection rule implementation:

```hcl
resource "github_branch_protection" "main" {
  repository_id       = github_repository.app.node_id
  pattern             = "main"
  enforce_admins      = true
  require_signed_commits = true
  
  required_status_checks {
    strict   = true
    contexts = ["ci/jenkins", "security/snyk"]
  }
  
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}
```

## Jenkins Pipeline Configuration

### Jenkinsfile Template

Below is a sample Jenkinsfile that can be used as a starting point for your applications:

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-agent
spec:
  containers:
  - name: docker
    image: docker:latest
    command: ['cat']
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-socket
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    
    environment {
        ACR_SERVER = credentials('acr-server')
        ACR_CREDENTIALS = credentials('acr-credentials')
        KUBE_CONFIG = credentials('kube-config')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                container('docker') {
                    sh """
                    echo \${ACR_CREDENTIALS_PSW} | docker login \${ACR_SERVER} -u \${ACR_CREDENTIALS_USR} --password-stdin
                    docker build -t \${ACR_SERVER}/myapp:${env.BUILD_NUMBER} .
                    docker push \${ACR_SERVER}/myapp:${env.BUILD_NUMBER}
                    """
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                // Security scanning steps
                echo "Running security scans..."
            }
        }
        
        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                container('docker') {
                    sh """
                    kubectl --kubeconfig=\${KUBE_CONFIG} set image deployment/myapp myapp=\${ACR_SERVER}/myapp:${env.BUILD_NUMBER} -n dev
                    """
                }
            }
        }
        
        stage('Deploy to Prod') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?'
                container('docker') {
                    sh """
                    kubectl --kubeconfig=\${KUBE_CONFIG} set image deployment/myapp myapp=\${ACR_SERVER}/myapp:${env.BUILD_NUMBER} -n prod
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

### Extending Jenkins with Plugins

The Jenkins instance comes pre-installed with several plugins. Additional plugins can be installed by modifying the `jenkins_plugins` variable in `terraform.tfvars`.

## AKS Deployment Strategies

### Deployment Options

The CI/CD pipeline supports multiple deployment strategies:

1. **Rolling Update** (default)
   - Update pods gradually without downtime
   - Controlled by Kubernetes deployment settings

2. **Blue/Green**
   - Deploy new version alongside old version
   - Switch traffic when ready
   - Implemented with service selector changes

3. **Canary**
   - Deploy new version to subset of users
   - Gradually increase traffic to new version
   - Implemented with Istio or Azure Application Gateway

### Example Blue/Green Implementation

```yaml
# Green deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: green
  template:
    metadata:
      labels:
        app: myapp
        version: green
    spec:
      containers:
      - name: myapp
        image: ${ACR_SERVER}/myapp:${NEW_VERSION}
        ports:
        - containerPort: 8080

# Service (initially pointing to blue)
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    version: blue
  ports:
  - port: 80
    targetPort: 8080
```

To switch traffic to green:

```bash
kubectl patch service myapp -p '{"spec":{"selector":{"version":"green"}}}'
```

## Secrets Management

### Azure Key Vault Integration

Sensitive information is stored in Azure Key Vault and accessed during the CI/CD process:

1. Through Azure Key Vault to Kubernetes sync
2. Using the Azure Key Vault Jenkins plugin

Example of accessing a secret in a Jenkinsfile:

```groovy
withCredentials([azureKeyVault(credentialsId: 'key-vault-credentials', 
                              keyVaultURL: 'https://your-vault.vault.azure.net', 
                              secrets: [secret(name: 'db-password', variable: 'DB_PASSWORD')])]) {
    sh 'echo $DB_PASSWORD'
}
```

## Build Optimization

### Docker Build Cache

Optimize Docker builds by leveraging BuildKit and cache:

```bash
DOCKER_BUILDKIT=1 docker build --cache-from ${ACR_SERVER}/myapp:latest -t ${ACR_SERVER}/myapp:${BUILD_NUMBER} .
```

### Parallel Builds

Use Jenkins' parallel stages to speed up the pipeline:

```groovy
parallel {
    stage('Unit Tests') {
        steps {
            // Run unit tests
        }
    }
    stage('Static Analysis') {
        steps {
            // Run static code analysis
        }
    }
}
```

## Testing Framework

### Test Integration

The pipeline integrates with several testing frameworks:

1. **Unit Tests**: Run during build phase
2. **Integration Tests**: Run post-build
3. **End-to-End Tests**: Run after deployment to dev
4. **Security Tests**: Run in parallel with other tests

### Test Reports

Configure test result reporting in your Jenkinsfile:

```groovy
stage('Unit Tests') {
    steps {
        sh 'npm test'
    }
    post {
        always {
            junit 'test-results/*.xml'
        }
    }
}
```

## Quality Gates

### Required Quality Gates

All deployments must pass these quality gates:

1. Code coverage (minimum 80%)
2. No critical or high security vulnerabilities
3. Successful integration tests
4. Compliance with coding standards

### SonarQube Integration

Add SonarQube analysis to your pipeline:

```groovy
stage('SonarQube Analysis') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'mvn sonar:sonar'
        }
    }
}
```

## Monitoring and Observability

### Pipeline Metrics

Jenkins metrics are available through:
- Azure Monitor integration
- Jenkins Prometheus plugin
- Azure Application Insights

### Deployment Tracking

Track deployments with:

1. Deployment annotations in Kubernetes
2. Azure DevOps deployment markers
3. Automated slack notifications

### Example Deployment Tracking

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  annotations:
    kubernetes.io/change-cause: "Version ${BUILD_NUMBER}, deployed by Jenkins at $(date)"
```

## Conclusion

This CI/CD integration guide provides a foundation for implementing automated pipelines with the Azure AKS Jenkins GitHub infrastructure. For specific requirements or customizations, please contact the infrastructure team.