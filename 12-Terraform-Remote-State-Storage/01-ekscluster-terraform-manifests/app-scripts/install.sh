#!/bin/bash
sudo hostnamectl set-hostname jenkins-server
sudo apt update
sudo apt install unzip wget openjdk-11-jdk openjdk-17-jdk -y

# Install Jenkins
wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sleep 10
/usr/bin/java --version
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt-get install jenkins -y
sudo systemctl start jenkins
# sudo systemctl status jenkins

sudo apt install maven curl fontconfig npm -y
sudo apt update

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

##Install Docker and Run SonarQube as Container
sudo apt-get update
# sudo apt install docker.io docker-ce docker-compose -y
sudo apt-get install docker-ce docker-ce-cli docker-compose containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ubuntu 
sudo usermod -aG docker jenkins  
sudo usermod -aG docker $USER
newgrp docker
sudo chmod 777 /var/run/docker.sock
bash

docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
docker run -d -p 8081:8081 --name nexus sonatype/nexus3

#install trivy
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y

# # Install Kubectl
# sudo apt update
# curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# kubectl version --client

# # Install  eksctl
# curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
# cd /tmp
# sudo mv /tmp/eksctl /bin
# eksctl version

# # Install helm
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
# sudo chmod 700 get_helm.sh
# sudo ./get_helm.sh
# helm version

# sleep 30

# Copy the docker-compose.yaml file to the VM
cat <<EOT > /home/$USER/docker-compose.yaml
version: '3.8'

services:
  nexus:
    image: sonatypecommunity/nexus3
    container_name: nexus
    ports:
      - "8081:8081"
    volumes:
      - nexus-data:/nexus-data
    environment:
      - INSTALL4J_ADD_VM_PARAMS=-Xms1200m -Xmx1200m
    restart: unless-stopped

  sonarqube:
    image: sonarqube:lts-community
    container_name: sonar
    ports:
      - "9000:9000"
    volumes:
      - sonarqube-conf:/opt/sonarqube/conf
      - sonarqube-data:/opt/sonarqube/data
      - sonarqube-logs:/opt/sonarqube/logs
      - sonarqube-extensions:/opt/sonarqube/extensions
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONARQUBE_JDBC_USERNAME=sonar
      - SONARQUBE_JDBC_PASSWORD=sonar
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:13
    container_name: sonarqube_db
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql:/var/lib/postgresql/data
    restart: unless-stopped

  artifactory:
    image: releases-docker.jfrog.io/jfrog/artifactory-pro:latest
    container_name: artifactory
    ports:
      - "8081:8081"
      - "8082:8082"
    volumes:
      - $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory
    restart: unless-stopped

volumes:
  nexus-data:
  sonarqube-conf:
  sonarqube-data:
  sonarqube-logs:
  sonarqube-extensions:
  postgresql:
EOT

# Start Docker containers
sudo docker-compose -f /home/$USER/docker-compose.yaml up -d
docker-compose -v
sleep 30

sudo chmod 777 /var/run/docker.sock
docker -v