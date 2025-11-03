pipeline {
    agent {
        label 'linux'
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'prod', 'dr-pilot-light'], description: 'Environment to deploy')
        booleanParam(name: 'PLAN_ONLY', defaultValue: true, description: 'Plan only, do not apply')
        booleanParam(name: 'SKIP_SECURITY_SCAN', defaultValue: false, description: 'Skip security scanning')
    }
    
    environment {
        TF_IN_AUTOMATION = 'true'
        AZURE_CREDENTIALS = credentials('azure-credentials')
        ENVIRONMENT_PATH = "environments/${params.ENVIRONMENT}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh '''
                    # Azure CLI login
                    az login --service-principal -u $AZURE_CREDENTIALS_CLIENT_ID -p $AZURE_CREDENTIALS_CLIENT_SECRET --tenant $AZURE_CREDENTIALS_TENANT_ID
                    
                    # Install tools
                    pip install checkov
                    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
                '''
            }
        }
        
        stage('Lint') {
            steps {
                sh '''
                    terraform fmt -check -recursive
                    tflint --init
                    tflint --config=.tflint.hcl --recursive
                '''
            }
        }
        
        stage('Security Scan') {
            when {
                expression { return !params.SKIP_SECURITY_SCAN }
            }
            steps {
                sh '''
                    mkdir -p reports/checkov
                    checkov -d . --config-file .checkov.yaml
                '''
            }
            post {
                always {
                    archiveArtifacts artifacts: 'reports/checkov/*', allowEmptyArchive: true
                }
            }
        }
        
        stage('Validate') {
            steps {
                dir(ENVIRONMENT_PATH) {
                    sh '''
                        terraform init -backend=false
                        terraform validate
                    '''
                }
            }
        }
        
        stage('Plan') {
            steps {
                dir(ENVIRONMENT_PATH) {
                    sh '''
                        terraform init
                        terraform plan -input=false -out=tfplan
                    '''
                }
            }
            post {
                always {
                    dir(ENVIRONMENT_PATH) {
                        archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
                    }
                }
            }
        }
        
        stage('Apply') {
            when {
                allOf {
                    expression { return !params.PLAN_ONLY }
                    branch 'main'
                }
            }
            steps {
                dir(ENVIRONMENT_PATH) {
                    sh '''
                        terraform apply -input=false -auto-approve tfplan
                    '''
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}