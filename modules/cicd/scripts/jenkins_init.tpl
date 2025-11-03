#!/bin/bash

# Update package lists
apt-get update -y

# Install prerequisites
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker ${admin_user}

# Install Java
apt-get install -y openjdk-11-jdk

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins
usermod -aG docker jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update
apt-get install -y terraform

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Configure Jenkins user home directory
mkdir -p /var/lib/jenkins/.azure /var/lib/jenkins/.kube
chown -R jenkins:jenkins /var/lib/jenkins/.azure /var/lib/jenkins/.kube
chmod -R 700 /var/lib/jenkins/.azure /var/lib/jenkins/.kube

# Configure Azure CLI for Jenkins
cat > /var/lib/jenkins/acr-login.sh << 'EOF'
#!/bin/bash
az acr login --name ${acr_name}
EOF
chmod +x /var/lib/jenkins/acr-login.sh
chown jenkins:jenkins /var/lib/jenkins/acr-login.sh

# Install Jenkins plugins using Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O /tmp/jenkins-cli.jar || true

# Wait for Jenkins to start up
echo "Waiting for Jenkins to start up..."
until $(curl --output /dev/null --silent --head --fail http://localhost:8080); do
  printf '.'
  sleep 5
done

# Restart Jenkins
systemctl restart jenkins

echo "Jenkins setup completed"