# Complete DevOps Guide

A comprehensive DevOps reference guide covering AWS infrastructure automation, container orchestration with Kubernetes, CI/CD pipelines with Jenkins, Infrastructure as Code with Terraform, configuration management with Ansible, and monitoring with Prometheus & Grafana.

## Table of Contents

1. [AWS CLI and Infrastructure](#aws-cli-and-infrastructure)
2. [Kubernetes and Container Orchestration](#kubernetes-and-container-orchestration)
3. [Jenkins and CI/CD Pipelines](#jenkins-and-cicd-pipelines)
4. [Terraform Infrastructure as Code](#terraform-infrastructure-as-code)
5. [Ansible Configuration Management](#ansible-configuration-management)
6. [Monitoring and Observability](#monitoring-and-observability)
7. [Best Practices](#best-practices)
8. [Project Structure](#project-structure)

---

## AWS CLI and Infrastructure

### AWS CLI Installation and Configuration

AWS CLI is the command-line interface for managing AWS services programmatically.

#### Installation on macOS

```bash
$ brew install awscli
$ aws --version
```

#### Installation on Ubuntu/Linux

```bash
$ sudo apt update
$ sudo apt install -y awscli
```

#### AWS Credentials Configuration

```bash
$ aws configure
# AWS Access Key ID [None]: YOUR_AWS_ACCESS_KEY_ID
# AWS Secret Access Key [None]: YOUR_AWS_SECRET_ACCESS_KEY
# Default region name [None]: us-east-1
# Default output format [None]: json
```

#### Verify Configuration

```bash
$ ls -l ~/.aws
# Output: config  credentials

$ cat ~/.aws/config
# [default]
# region = us-east-1
# output = json

$ cat ~/.aws/credentials
# [default]
# aws_access_key_id = YOUR_AWS_ACCESS_KEY_ID
# aws_secret_access_key = YOUR_AWS_SECRET_ACCESS_KEY
```

### EC2 Instance Management

#### Gather Necessary Information

```bash
# List available VPCs
$ aws ec2 describe-vpcs

# List available security groups
$ aws ec2 describe-security-groups

# List available subnets
$ aws ec2 describe-subnets
```

#### Create Security Group

```bash
$ aws ec2 create-security-group \
  --group-name my-sg \
  --description "My Security Group" \
  --vpc-id vpc-0254784d
# Returns: GroupId sg-89846598s78f
```

#### Configure Security Group Ingress Rules

Allow SSH access from specific IP:

```bash
$ aws ec2 authorize-security-group-ingress \
  --group-id sg-89846598s78f \
  --protocol tcp \
  --port 22 \
  --cidr 178.191.156.151/32
```

#### Create Key Pair

```bash
$ aws ec2 create-key-pair \
  --key-name MyKpCli \
  --query 'KeyMaterial' \
  --output text > MyKpCli.pem

$ chmod 400 MyKpCli.pem
$ ls -l MyKpCli.pem
```

#### Launch EC2 Instance

```bash
$ aws ec2 run-instances \
  --image-id ami-0c3d23d707737957d \
  --count 1 \
  --instance-type t2.micro \
  --key-name MyKpCli \
  --security-group-ids sg-89846598s78f \
  --subnet-id subnet-6e7f829e
```

#### Describe and List Instances

```bash
# List all instances
$ aws ec2 describe-instances

# Filter instances by type
$ aws ec2 describe-instances \
  --filters "Name=instance-type,Values=t2.micro" \
  --query "Reservations[].Instances[].InstanceId"

# Filter instances by tag
$ aws ec2 describe-instances \
  --filters "Name=tag:Type,Values=Web Server with Docker" \
  --query "Reservations[].Instances[].InstanceId"
```

#### Connect to EC2 Instance

```bash
$ ssh -i MyKpCli.pem ec2-user@35.180.23.198
```

### IAM User and Group Management

#### Create IAM User Group

```bash
$ aws iam create-group --group-name MyGroupCli
```

#### Create IAM User

```bash
$ aws iam create-user --user-name MyUserCli
```

#### Add User to Group

```bash
$ aws iam add-user-to-group \
  --user-name MyUserCli \
  --group-name MyGroupCli
```

#### Verify Group Membership

```bash
$ aws iam get-group --group-name MyGroupCli
```

#### Attach Policies to Group

Find and attach policies:

```bash
# Find EC2 Full Access Policy ARN
$ aws iam list-policies \
  --query 'Policies[?PolicyName==`AmazonEC2FullAccess`].{ARN:arn}' \
  --output text

# Attach policy to group
$ aws iam attach-group-policy \
  --group-name MyGroupCli \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
```

#### Create Custom Policy

Create a JSON policy file for password changes:

```bash
$ cat > changePwdPolicy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:GetAccountPasswordPolicy",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:ChangePassword",
            "Resource": "arn:aws:iam::664574038682:user/${aws:username}"
        }
    ]
}
EOF
```

#### Create and Attach Custom Policy

```bash
$ aws iam create-policy \
  --policy-name changePwd \
  --policy-document file://changePwdPolicy.json

$ aws iam attach-group-policy \
  --group-name MyGroupCli \
  --policy-arn arn:aws:iam::664574038682:policy/changePwd
```

#### Create Access Keys for Programmatic Access

```bash
# Create access keys for the user
$ aws iam create-access-key --user-name MyUserCli
# Save AccessKeyId and SecretAccessKey

# Verify user details
$ aws iam get-user --user-name MyUserCli
```

#### Configure AWS Credentials for New User

```bash
$ aws configure set aws_access_key_id your_access_key
$ aws configure set aws_secret_access_key your_secret_key

# Or use environment variables
$ export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
$ export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
$ export AWS_DEFAULT_REGION=us-west-2
```

---

## Kubernetes and Container Orchestration

### Minikube Setup on macOS

#### Installation

```bash
$ brew update
$ brew install hyperkit
$ brew install minikube
$ kubectl --version
```

#### Start Minikube Cluster

```bash
$ minikube start --vm-driver=hyperkit
$ minikube status
$ kubectl get nodes
```

### Kubernetes Basic Commands

#### Cluster Information

```bash
$ kubectl cluster-info
$ kubectl get nodes
$ kubectl get nodes -o wide
$ kubectl api-resources --namespace=false
$ kubectl api-resources --namespace=true
```

### Deployment Management

#### Create Deployment

```bash
# Imperative approach
$ kubectl create deployment nginx-depl --image=nginx

# View deployment
$ kubectl get deployment
$ kubectl get pod
$ kubectl get replicaset
```

#### Edit and Update Deployment

```bash
$ kubectl edit deployment nginx-depl
$ kubectl apply -f nginx-deployment.yaml
$ kubectl get deployment
$ kubectl get pod
$ kubectl get replicaset
```

#### Pod and Container Inspection

```bash
# View pod logs
$ kubectl logs [podname]

# Describe pod details
$ kubectl describe pod [podname]

# Execute commands inside pod
$ kubectl exec -it [podname] -- /bin/bash

# Watch pod changes
$ kubectl get pod --watch
```

### Service Management

#### Create and View Services

```bash
# Create service
$ kubectl apply -f nginx-service.yaml

# List services
$ kubectl get service
$ kubectl get svc

# Describe service details
$ kubectl describe service nginx-service

# View pod endpoints
$ kubectl get pod -o wide
```

#### Port Forwarding

```bash
# Forward local port to service
$ kubectl port-forward service/nginx-service 8080:80

# Forward to pod
$ kubectl port-forward [podname] 8080:80

# Forward to deployment
$ kubectl port-forward deployment/nginx-depl 8080:80
```

### ConfigMap and Secrets

#### Create ConfigMap

```bash
$ kubectl apply -f config-file.yaml
$ kubectl get configmap
$ kubectl describe configmap [configmap-name]
```

#### Create Secrets

```bash
# Encode sensitive data
$ echo -n 'username' | base64

# Create secret
$ kubectl apply -f secret-file.yaml
$ kubectl get secret
$ kubectl get secret -o yaml
```

### Namespace Management

#### Create and Manage Namespaces

```bash
$ kubectl get namespace
$ kubectl create namespace my-namespace
$ kubectl get namespace

# Apply resources to specific namespace
$ kubectl apply -f config.yaml -n my-namespace
$ kubectl get pod -n my-namespace
$ kubectl get all -n my-namespace
```

#### Switch Namespaces

Install and use kubectx:

```bash
$ brew install kubectx
$ kubens
$ kubens my-namespace
```

### Ingress Configuration

#### Enable Ingress

```bash
$ minikube addons enable ingress
$ kubectl get pod -n kube-system
```

#### Create Ingress Resource

```bash
$ kubectl apply -f dashboard-ingress.yaml
$ kubectl get ingress -n kubernetes-dashboard --watch
$ kubectl describe ingress dashboard-ingress -n kubernetes-dashboard
```

### Resource Management

#### Export Resource as YAML

```bash
$ kubectl get deployment -o yaml > nginx-deployment-result.yaml
```

#### Delete Resources

```bash
$ kubectl delete -f [filename]
$ kubectl delete deployment mongo-depl
$ kubectl delete -f nginx-deployment.yaml
```

#### Scale Deployments

```bash
$ kubectl scale deployment nginx --replicas=5
$ kubectl get pod
```

#### View All Resources

```bash
$ kubectl get all
$ kubectl get all | grep mongodb
```

---

## Jenkins and CI/CD Pipelines

### Jenkins Installation with Docker

#### Install Docker (Ubuntu/Linux)

```bash
sudo apt update
sudo apt install -y docker.io

sudo systemctl start docker
sudo systemctl enable docker
```

#### Create Jenkins Volume and Container

```bash
# Create persistent volume for Jenkins data
sudo docker volume create jenkins_home

# Run Jenkins container
sudo docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Get initial admin password
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

#### Restart Jenkins if Issues Occur

```bash
sudo docker restart jenkins
```

### Jenkins Pipeline with Docker Registry

#### Create Docker Registry Credentials

Access Jenkins at `http://localhost:8080/manage/credentials/`:

- **Kind:** Username with password
- **Scope:** Global
- **Username:** AWS (for ECR) or docker username
- **Password:** ECR token or Docker password
- **ID:** ecr-credentials

#### Jenkinsfile Example with Docker

```groovy
pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT = '664574038682'
        AWS_REGION = 'eu-central-1'
        ECR_REPO = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_NAME = "java-maven-app"
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${ECR_REPO}/${IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'ecr-credentials',
                                                      usernameVariable: 'AWS_USER',
                                                      passwordVariable: 'AWS_PASSWORD')]) {
                        sh "docker login -u ${AWS_USER} -p ${AWS_PASSWORD} ${ECR_REPO}"
                        sh "docker push ${ECR_REPO}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    }
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    sh '''
                        kubectl set image deployment/java-maven-app \
                          java-maven-app=${ECR_REPO}/${IMAGE_NAME}:${BUILD_NUMBER} \
                          --record
                    '''
                }
            }
        }
    }
}
```

### Jenkins with SSH Agent for Remote Deployment

#### Create SSH Credentials

Access Jenkins at `http://localhost:8080/manage/credentials/`:

- **Kind:** SSH Username with private key
- **ID:** ansible-server-key
- **Username:** root
- **Private Key:** Paste content from `~/.ssh/id_rsa`

#### Jenkinsfile with SSH Agent

```groovy
pipeline {
    agent any
    
    stages {
        stage('Copy Files to Ansible Server') {
            steps {
                script {
                    sshagent(['ansible-server-key']) {
                        sh '''
                            scp -o StrictHostKeyChecking=no \
                                -r ansible/ \
                                inventory_aws_ec2.yaml \
                                root@167.99.136.157:/root/
                        '''
                    }
                }
            }
        }
        
        stage('Execute Ansible Playbook') {
            steps {
                script {
                    sshagent(['ansible-server-key']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no \
                                root@167.99.136.157 \
                                "cd /root && ansible-playbook -i inventory_aws_ec2.yaml playbook.yaml"
                        '''
                    }
                }
            }
        }
    }
}
```

### Jenkins with Terraform

#### Install Terraform in Jenkins Container

```bash
$ docker exec -u 0 -it jenkins bash

root@jenkins:/# apt-get update
root@jenkins:/# apt-get install -y wget gnupg lsb-release

# Add HashiCorp repository
root@jenkins:/# wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

root@jenkins:/# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
root@jenkins:/# apt-get update
root@jenkins:/# apt-get install -y terraform
root@jenkins:/# terraform -v
root@jenkins:/# exit
```

#### Jenkinsfile with Terraform

```groovy
pipeline {
    agent any
    
    stages {
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan'
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { currentBuild.result == 'SUCCESS' && params.DESTROY == true }
            }
            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}
```

---

## Terraform Infrastructure as Code

### Terraform Installation

#### macOS Installation

```bash
$ brew install terraform
$ terraform -v

# Upgrade terraform
$ brew update
$ brew upgrade terraform
```

### Terraform Basics

#### Initialize Terraform

```bash
$ cd terraform-directory
$ terraform init
# Output: Terraform has been successfully initialized!
```

#### Plan Infrastructure Changes

```bash
$ terraform plan
# Shows resources to be created, changed, or destroyed
```

#### Apply Configuration

```bash
$ terraform apply
# Plan: 3 to add, 0 to change, 0 to destroy
# Enter a value: yes

# Auto-approve without prompting
$ terraform apply -auto-approve
```

#### Destroy Infrastructure

```bash
# Destroy all resources
$ terraform destroy

# Destroy specific resource
$ terraform destroy -target aws_subnet.dev-subnet-2

# Auto-approve destruction
$ terraform destroy -auto-approve
```

### Terraform State Management

#### State Commands

```bash
# List all resources in state
$ terraform state list

# Show specific resource details
$ terraform state show aws_subnet.dev-subnet-1

# Display full state
$ terraform state list
```

### Terraform Variables

#### Interactive Variables

```bash
$ terraform apply
# When prompted:
# var.subnet_cidr_block
# Enter a value: 10.0.20.0/24
```

#### Variables via Command Line

```bash
$ terraform apply -var "subnet_cidr_block=10.0.30.0/24"
```

#### Variables File

Create `terraform-dev.tfvars`:

```hcl
subnet_cidr_block = "10.0.20.0/24"
environment       = "dev"
instance_type     = "t2.micro"
```

Apply with variables file:

```bash
$ terraform apply -var-file terraform-dev.tfvars
$ terraform apply -var-file="terraform-dev.tfvars"
```

#### Environment Variables

```bash
# Set AWS credentials via environment
$ export AWS_SECRET_ACCESS_KEY=dkajla+KSkdsklfsowe897sdjfksd
$ export AWS_ACCESS_KEY_ID=AKJLKSOEIOWESDJFLKDI
$ terraform apply -var-file terraform-dev.tfvars

# Terraform-specific environment variables
$ export TF_VAR_avail_zone="eu-west-3a"
$ terraform apply -var-file terraform-dev.tfvars
```

### Terraform Outputs

#### Display Outputs

```bash
$ terraform output
$ terraform output dev-vpc-id
$ terraform output dev-subnet-id
```

### Terraform Modules

#### Module Structure

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
    ├── webserver/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── subnet/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

#### Using Modules

```hcl
module "webserver" {
  source = "./modules/webserver"
  
  instance_type = var.instance_type
  ami_id       = var.ami_id
}

module "network" {
  source = "./modules/subnet"
  
  vpc_id            = aws_vpc.main.id
  subnet_cidr_block = var.subnet_cidr_block
}
```

### Terraform Backends - S3 State Storage

#### Create S3 Bucket

In AWS Console:

- Bucket Name: myapp-bucket
- Region: your-region
- Block all public access: enabled
- Versioning: enabled

#### Configure S3 Backend

Create/Update `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "myapp-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

#### Initialize with Backend

```bash
$ terraform init
# Terraform will migrate state to S3
$ terraform state list
```

### Terraform AWS EKS

#### Create EKS Cluster Configuration

```hcl
provider "aws" {
  region = "eu-west-1"
}

# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "eks-vpc"
  }
}

# Subnets
resource "aws_subnet" "eks_subnet_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  
  tags = {
    Name = "eks-subnet-1"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "myapp-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn
  version  = "1.26"
  
  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet_1.id]
  }
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}
```

#### Deploy EKS Cluster

```bash
$ terraform plan
$ terraform apply -auto-approve

# Get kubeconfig
$ aws eks update-kubeconfig --name myapp-eks-cluster --region eu-west-1
$ kubectl get nodes
```

---

## Ansible Configuration Management

### Ansible Installation

#### macOS Installation

```bash
$ brew install ansible
$ ansible --version

# Requires Python
$ python --version
$ python3 --version
```

#### Ubuntu/Linux Installation

```bash
$ sudo apt update
$ sudo apt install -y software-properties-common
$ sudo add-apt-repository --yes --update ppa:ansible/ansible
$ sudo apt install -y ansible
$ ansible --version
```

### Ansible Inventory

#### Inventory File Configuration

Create `hosts` file:

```ini
[database]
134.209.255.142 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=root
134.209.255.155 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=root

[web]
159.89.1.54 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=root

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_user=root
```

#### Inventory with Group Variables

```ini
[droplet]
134.209.255.142
134.209.255.155

[droplet:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_user=root
```

#### EC2 Instance Inventory

```ini
[ec2]
ec2-15-188-239-5.eu-west-3.compute.amazonaws.com
ec2-35-188-204-130.eu-west-3.compute.amazonaws.com ansible_python_interpreter=/usr/bin/python3

[ec2:vars]
ansible_ssh_private_key_file=~/Downloads/ansible.pem
ansible_user=ec2-user
```

### Ansible Ad-Hoc Commands

#### Basic Commands

```bash
# Ping all hosts
$ ansible all -i hosts -m ping

# Ping specific group
$ ansible droplet -i hosts -m ping

# Ping specific host
$ ansible 134.209.255.155 -i hosts -m ping
```

### Ansible Playbooks

#### Basic Playbook Structure

Create `deploy-node.yaml`:

```yaml
---
- name: Deploy Node Application
  hosts: all
  become: yes
  
  tasks:
    - name: Update system packages
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Install Node.js
      apt:
        name: nodejs
        state: present
    
    - name: Create app directory
      file:
        path: /opt/app
        state: directory
        owner: node
        group: node
    
    - name: Copy application files
      copy:
        src: app-1.0.0.tgz
        dest: /opt/app/
    
    - name: Extract application
      unarchive:
        src: /opt/app/app-1.0.0.tgz
        dest: /opt/app/
        remote_src: yes
    
    - name: Start Node application
      shell: |
        cd /opt/app/package
        npm install
        node server.js &
      become_user: node
```

#### Execute Playbook

```bash
$ ansible-playbook -i hosts deploy-node.yaml

# With variables
$ ansible-playbook -i hosts deploy-node.yaml \
  -e "version=1.0.0 location=/path/to/app"
```

### Ansible Variables

#### Variable Files

Create `project-vars.yaml`:

```yaml
node_version: 16.0.0
app_port: 3000
app_user: nodejs
linux_name: shuvo
location: /opt/app
```

#### Using Variables in Playbooks

```yaml
---
- name: Deploy with Variables
  hosts: all
  vars_files:
    - project-vars.yaml
  
  tasks:
    - name: Create user
      user:
        name: "{{ app_user }}"
        shell: /bin/bash
    
    - name: Create app directory
      file:
        path: "{{ location }}"
        state: directory
        owner: "{{ app_user }}"
    
    - name: Copy app file
      copy:
        src: "{{ location }}/nodejs-app-{{ version }}.tgz"
        dest: "{{ location }}/"
```

### Host Key Checking

#### Disable Host Key Checking

Create `~/.ansible.cfg`:

```ini
[defaults]
host_key_checking = False
```

Or in project-specific `ansible.cfg`:

```ini
[defaults]
host_key_checking = False
inventory = ./hosts
```

#### Add Host Keys Manually

```bash
$ ssh-keyscan -H 165.22.201.197 >> ~/.ssh/known_hosts
$ ssh-copy-id root@188.166.30.219
```

### Ansible Roles

#### Role Structure

```
roles/
├── common/
│   ├── tasks/
│   │   └── main.yml
│   ├── handlers/
│   │   └── main.yml
│   ├── templates/
│   ├── files/
│   ├── vars/
│   │   └── main.yml
│   ├── defaults/
│   │   └── main.yml
│   └── meta/
│       └── main.yml
├── webserver/
└── database/
```

#### Create Role

```bash
$ ansible-galaxy role init common
$ ansible-galaxy role init webserver
```

#### Using Roles in Playbooks

```yaml
---
- name: Configure Servers
  hosts: all
  become: yes
  
  roles:
    - common
    - webserver
  
  vars:
    user_groups: adm,docker
```

#### Execute Playbook with Roles

```bash
$ ansible-playbook deploy-with-roles.yaml -i inventory_aws_ec2.yaml
```

### Dynamic Inventory with AWS

#### Install Requirements

```bash
$ pip install boto3 botocore
$ pip install ansible-core
```

#### Create Dynamic Inventory File

Create `inventory_aws_ec2.yaml`:

```yaml
plugin: aws_ec2
regions:
  - eu-west-1
filters:
  tag:Environment:
    - dev
    - prod
keyed_groups:
  - key: tags.Environment
    prefix: env
  - key: instance_type
    prefix: type
hostnames:
  - dns-name
  - private-ip-address
```

#### View Dynamic Inventory

```bash
# List hosts
$ ansible-inventory -i inventory_aws_ec2.yaml --list

# View graph structure
$ ansible-inventory -i inventory_aws_ec2.yaml --graph
```

#### Use Dynamic Inventory

```bash
$ ansible-playbook -i inventory_aws_ec2.yaml playbook.yaml

# Add to ansible.cfg for default usage
[defaults]
inventory = ./inventory_aws_ec2.yaml
```

### Ansible and Docker

#### Ansible Playbook for Docker

Create `deploy-docker.yaml`:

```yaml
---
- name: Install and Configure Docker
  hosts: all
  become: yes
  
  tasks:
    - name: Update package cache
      yum:
        name: "*"
        state: latest
    
    - name: Install Docker
      yum:
        name: docker
        state: present
    
    - name: Start Docker service
      systemd:
        name: docker
        state: started
        enabled: yes
    
    - name: Add user to docker group
      user:
        name: "{{ ansible_user }}"
        groups: docker
        append: yes
    
    - name: Reset ssh connection
      meta: reset_connection
    
    - name: Copy docker-compose file
      copy:
        src: docker-compose.yaml
        dest: /opt/
        owner: "{{ ansible_user }}"
        group: docker
    
    - name: Pull Docker image
      docker_image:
        name: shuvo83qn/demo-app:java-maven-2.0
        source: pull
    
    - name: Start Docker containers
      docker_compose:
        project_src: /opt/
        state: present
```

### Ansible and Kubernetes

#### Deploy to Kubernetes with Ansible

Create `deploy-to-k8s.yaml`:

```yaml
---
- name: Deploy Application to Kubernetes
  hosts: localhost
  gather_facts: no
  
  vars:
    k8s_namespace: my-app
  
  tasks:
    - name: Create namespace
      kubernetes.core.k8s:
        name: "{{ k8s_namespace }}"
        api_version: v1
        kind: Namespace
        state: present
    
    - name: Deploy application
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('template', 'deployment.yaml') }}"
    
    - name: Create service
      kubernetes.core.k8s:
        state: present
        definition: "{{ lookup('template', 'service.yaml') }}"
```

#### Install Kubernetes Module

```bash
$ pip3 install openshift --user
$ pip3 install PyYAML --user

# Verify installation
$ python3 -c "import openshift"
$ python3 -c "import yaml"
```

#### Set Kubernetes Configuration

```bash
$ export KUBECONFIG=~/path/to/kubeconfig.yaml
$ export K8S_AUTH_KUBECONFIG=~/path/to/kubeconfig.yaml
$ ansible-playbook deploy-to-k8s.yaml
```

---

## Monitoring and Observability

### Prometheus Introduction

#### Prometheus Components

- **Time Series Database:** Stores metrics with timestamps
- **Data Retrieval Worker:** Scrapes metrics from targets via HTTP
- **HTTP Server:** Accepts PromQL queries
- **AlertManager:** Sends alerts based on rules
- **Exporters:** Convert target metrics to Prometheus format

#### Prometheus Configuration

Create `prometheus.yaml`:

```yaml
global:
  scrape_interval: 15s        # How often to scrape targets
  evaluation_interval: 15s    # How often to evaluate rules

rule_files:
  - "alert-rules.yaml"

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: node_exporter
    scrape_interval: 1m
    scrape_timeout: 1m
    static_configs:
      - targets: ['localhost:9100']
  
  - job_name: redis
    static_configs:
      - targets: ['localhost:6379']
```

### Prometheus on Kubernetes with Helm

#### Add Prometheus Helm Repository

```bash
$ helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
$ helm repo update
```

#### Create Monitoring Namespace

```bash
$ kubectl create namespace monitoring
```

#### Install Prometheus Stack

```bash
$ helm install monitoring \
  prometheus-community/kube-prometheus-stack \
  -n monitoring

# Verify installation
$ kubectl --namespace monitoring get pods -l "release=monitoring"
$ kubectl get all -n monitoring
```

#### Access Prometheus UI

```bash
# Port-forward Prometheus
$ kubectl port-forward \
  service/monitoring-kube-prometheus-prometheus \
  -n monitoring 9090:9090

# Browser: http://127.0.0.1:9090
```

### Grafana Dashboard

#### Access Grafana

```bash
$ kubectl port-forward \
  service/monitoring-grafana \
  -n monitoring 8080:80

# Browser: http://127.0.0.1:8080
# Default credentials: admin / prom-operator
```

#### Import Pre-built Dashboards

In Grafana UI:

- Go to Dashboards > Import
- Enter Dashboard ID (e.g., 763 for Redis)
- Select Prometheus data source
- Import

#### Create Custom Dashboard

1. Create > Dashboard > Add empty panel
2. Enter PromQL query: `rate(http_request_operations_total[2m])`
3. Configure visualization (Graph, Table, etc.)
4. Save dashboard

### Alert Rules

#### Create Custom Alert Rules

Create `alert-rules.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: main-rules
  namespace: monitoring
spec:
  groups:
  - name: main.rules
    interval: 30s
    rules:
    - alert: HostHighCpuLoad
      expr: |
        (1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)) > 0.8
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU load on {{ $labels.instance }}"
        description: "CPU load is above 80% (current: {{ $value }}%)"
    
    - alert: HostMemoryAlmostFull
      expr: |
        (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.9
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Memory almost full on {{ $labels.instance }}"
        description: "Memory usage is above 90%"
```

#### Apply Alert Rules

```bash
$ kubectl apply -f alert-rules.yaml
$ kubectl get PrometheusRule -n monitoring

# Verify configuration reload
$ kubectl logs prometheus-monitoring-kube-prometheus-prometheus-0 \
  -n monitoring -c config-reloader
```

#### View Alerts in Prometheus

- Browser: http://127.0.0.1:9090/alerts
- Status shows: Inactive (green) or Firing (red)

### AlertManager Configuration

#### Configure Email Notifications

Create `alert-manager-configuration.yaml`:

```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: main-rules-alert-config
  namespace: monitoring
spec:
  route:
    groupBy: ['namespace', 'alertname']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
    receiver: 'email-receiver'
  
  receivers:
  - name: 'email-receiver'
    emailConfigs:
    - to: 'your-email@gmail.com'
      from: 'alerts@your-domain.com'
      smarthost: 'smtp.gmail.com:587'
      authUsername: 'your-email@gmail.com'
      authPassword: 'your_gmail_app_password'
      headers:
        Subject: 'Alert: {{ .GroupLabels.alertname }}'
      html: |
        {{ range .Alerts }}
          <strong>{{ .Labels.alertname }}</strong>
          {{ .Annotations.description }}
        {{ end }}
```

#### Apply AlertManager Configuration

```bash
$ kubectl apply -f alert-manager-configuration.yaml

# Verify configuration
$ kubectl logs alertmanager-monitoring-kube-prometheus-alertmanager-0 \
  -n monitoring -c config-reloader
```

#### Access AlertManager UI

```bash
$ kubectl port-forward \
  svc/monitoring-kube-prometheus-alertmanager \
  -n monitoring 9093:9093

# Browser: http://127.0.0.1:9093
```

### Redis Exporter

#### Install Redis Exporter with Helm

Create `redis-values.yaml`:

```yaml
redisAddress: redis-cart:6379
serviceMonitor:
  enabled: true
  labels:
    release: monitoring
```

#### Deploy Redis Exporter

```bash
$ helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts
$ helm repo update

$ helm install redis-exporter \
  prometheus-community/prometheus-redis-exporter \
  -f redis-values.yaml

# Verify deployment
$ kubectl get pod
$ kubectl get servicemonitor
```

### Application Monitoring

#### Expose Application Metrics

For Node.js applications, add Prometheus client library:

```bash
$ npm install prom-client
```

#### Application Metrics in Node.js

```javascript
const prometheus = require('prom-client');

// Create metrics
const httpRequestTotal = new prometheus.Counter({
  name: 'http_request_operations_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware to track requests
app.use((req, res, next) => {
  const startTime = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - startTime) / 1000;
    httpRequestTotal.inc({
      method: req.method,
      route: req.route.path,
      status_code: res.statusCode
    });
    httpRequestDuration.observe({
      method: req.method,
      route: req.route.path,
      status_code: res.statusCode
    }, duration);
  });
  
  next();
});

// Expose metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(prometheus.register.metrics());
});
```

#### Deploy Application to Kubernetes

Create `k8s-config.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
spec:
  selector:
    matchLabels:
      app: nodejs-app
  template:
    metadata:
      labels:
        app: nodejs-app
    spec:
      containers:
      - name: app
        image: your-repo/nodejs-app:latest
        ports:
        - containerPort: 3000
        - containerPort: 9090  # Metrics port

---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app
spec:
  selector:
    app: nodejs-app
  ports:
  - name: http
    port: 3000
    targetPort: 3000
  - name: metrics
    port: 9090
    targetPort: 9090
  type: LoadBalancer

---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nodejs-app-monitor
spec:
  selector:
    matchLabels:
      app: nodejs-app
  endpoints:
  - port: metrics
    interval: 30s
```

#### Deploy and Monitor

```bash
$ kubectl apply -f k8s-config.yaml
$ kubectl get pod
$ kubectl get servicemonitor

# Access application
$ kubectl port-forward svc/nodejs-app 3000:3000

# View metrics endpoint
$ curl http://127.0.0.1:9090/metrics

# In Prometheus
$ kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090
# Search: http_request_operations_total
```

---

## Best Practices

### Infrastructure as Code

- **Version Control:** Keep all code (Terraform, Ansible, Kubernetes manifests) in git
- **State Management:** Use remote backends for Terraform state (S3, Terraform Cloud)
- **Secrets Management:** Never commit secrets to repositories; use secret managers
- **Code Review:** Implement peer review for infrastructure changes
- **Testing:** Test configurations in dev/staging before production

### CI/CD Pipeline

- **Automated Testing:** Run tests for every commit
- **Build Artifacts:** Push only tested and versioned artifacts
- **Progressive Deployment:** Use rolling updates and canary deployments
- **Monitoring:** Monitor deployments and roll back automatically on failure
- **Documentation:** Document deployment processes and runbooks

### Kubernetes Best Practices

- **Resource Limits:** Set CPU and memory limits for all containers
- **Health Checks:** Implement liveness and readiness probes
- **Security:** Use NetworkPolicies, RBAC, and Pod Security Policies
- **Logging:** Centralize logs for better debugging
- **Versioning:** Always specify container image versions (never use `latest`)

### Security

- **IAM Roles:** Use least privilege principle
- **Encryption:** Encrypt data in transit and at rest
- **Secrets:** Rotate secrets regularly
- **Scanning:** Scan images and dependencies for vulnerabilities
- **Compliance:** Audit and monitor for compliance requirements

---

## Project Structure

```
DevOps /
├── README.md                          # This file
├── ansible.sh                         # Ansible commands and lessons
├── ansible/
│   ├── ansible-project-struc-collec-docs.sh
│   ├── ansible.cfg
│   ├── hosts
│   ├── my-playbook.yaml
│   └── ...
├── ansible-basic/
│   ├── ansible-playbooks-nginx/
│   ├── docker-module/
│   ├── jenkins-module/
│   ├── playbook/
│   └── postgres-module/
├── ansible-ec2/
│   ├── docker-compose.yaml
│   ├── ansible/
│   └── terraform/
├── ansible-eks/
│   ├── ansible/
│   ├── ansible-java-maven-app/
│   ├── ansible-roles/
│   ├── k8s-files/
│   └── terraform-eks-project/
├── ansible-node/
│   ├── ansible.cfg
│   ├── deploy-nexus.yaml
│   ├── deploy-node-onestep.yaml
│   ├── deploy-node.yaml
│   ├── hosts
│   ├── nexus.sh
│   └── project-vars.yaml
├── charts/
│   ├── microservice/
│   └── redis/
├── complete-ci-cd-pipeline/
│   ├── Jenkinsfile
│   └── kubernetes/
├── java-maven-app/
│   └── deploy-on-k8s/
├── java-maven-app-ec2/
│   ├── docker-compose.yaml
│   ├── Dockerfile
│   ├── Jenkinsfile
│   ├── server-cmds.sh
│   └── terraform/
├── kubeconfig-connect-eks/
│   └── config.yaml
├── kubernetes/
│   ├── authentication/
│   ├── configmap-secret/
│   ├── ecr-k8s/
│   ├── helm/
│   ├── ingress/
│   ├── labels/
│   ├── linode/
│   ├── mongo-db/
│   ├── mongo-express/
│   ├── mysql/
│   ├── nginx/
│   ├── service/
│   └── volumes/
├── postgresql-dev-staging-production/
│   ├── dev/
│   ├── production/
│   └── staging/
├── prom-client/
│   ├── Dockerfile
│   ├── k8s-config.yaml
│   └── app/
├── prometheus/
│   └── monitoring/
├── python-boto3/
│   ├── main.py
│   └── ssh.py
├── terraform/
│   ├── main.tf
│   ├── terraform-dev.tfvars
│   └── provider/
├── terraform-ec2-project/
│   ├── entry-script.sh
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── modules/
├── terraform-eks-project/
│   ├── eks-cluster.tf
│   ├── eks-status-check.py
│   ├── README.md
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── vpc.tf
├── tf-boto3/
│   ├── add-env-tags.py
│   ├── cleanup-snapshots.py
│   ├── ec2-status-check.py
│   ├── eks-status-check.py
│   ├── main.tf
│   ├── monitor-website.py
│   ├── restore-volume.py
│   ├── terraform.tfvars
│   └── volume-backups.py
├── values/
│   ├── ad-service-values.yaml
│   ├── cart-service-values.yaml
│   ├── checkout-service-values.yaml
│   ├── currency-service-values.yaml
│   ├── email-service-values.yaml
│   ├── frontend-values.yaml
│   ├── payment-service-values.yaml
│   ├── productcatalog-service-values.yaml
│   ├── recommendation-service-values.yaml
│   └── ...
└── vars/
    └── ...
```

---

## Getting Started

### Prerequisites

- AWS Account with appropriate IAM permissions
- Docker installed locally
- kubectl configured
- Terraform installed
- Ansible installed
- Helm installed

### Quick Start

1. **Configure AWS Credentials:**
   ```bash
   $ aws configure
   ```

2. **Initialize Terraform:**
   ```bash
   $ cd terraform-eks-project
   $ terraform init
   $ terraform apply -auto-approve
   ```

3. **Configure kubectl:**
   ```bash
   $ aws eks update-kubeconfig --name myapp-eks-cluster --region us-east-1
   $ kubectl get nodes
   ```

4. **Deploy Monitoring Stack:**
   ```bash
   $ kubectl create namespace monitoring
   $ helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
   ```

5. **Deploy Applications:**
   ```bash
   $ kubectl apply -f kubernetes/
   ```

---

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [Prometheus Documentation](https://prometheus.io/docs)
- [AWS Documentation](https://docs.aws.amazon.com)
- [Jenkins Documentation](https://www.jenkins.io/doc)

---

## License

This project is provided as-is for educational and reference purposes.

## Support

For questions or issues, refer to the respective project documentation or contact your DevOps team.

---

**Last Updated:** December 6, 2025
