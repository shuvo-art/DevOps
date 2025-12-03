# Industry-standard approach using Docker to Install Jenkins

# Step 1: Ensure Docker is installed if not installed.
sudo apt install -y docker.io

# Step 2: Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Step 3: Create Jenkins data volume (persistent storage)
sudo docker volume create jenkins_home

# Step 4: Run Jenkins container
sudo docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Step 5: Get initial admin password
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Step 6: If install docker Jenkins not works 
sudo docker restart jenkins


// Lesson-222 ( Install Ansibel )
brew install ansible // Local Install and ansibel requirements: python needs to be installed
ansible 
ansible --version

# Industry-standard approach for Ubuntu/Linux
# SSH into remote server
ssh root@137.184.124.136

# Then run these commands on the remote server:
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
ansible --version

// Lesson-223 ( Setup Managed Server )
# Create Two Droplet Managed Server on Digital Ocean and managed by ansible, Checked python installed
ls /usr/bin/python3
exit

// Lesson-224 ( Ansible Inventory )
# Grouping hosts
# - you can put each host in more than one group
# you can create group that track
# - WHERE: a datacenter/region, e.g. east, west
# - WHAT: e.g. database servers, web servers etc
# - WHEN: which stage, e.g. dev, test, prod environment

$ vim hosts
[database]
134.209.255.142 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=root
134.209.255.155 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=root

[web]
...
...

:wq

# Ansible ad-hoc commands
# [pattern] = targeting hosts and groups, - "all" = default group, which contains every host 
$ ansible [pattern] -m [module] -a "[module options]" 
$ ansible all -i hosts -m ping

$ vim hosts
[droplet]
134.209.255.142 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=root
134.209.255.155 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_user=root

$ ansible droplot -i hosts -m ping
$ ansible 134.209.255.155 -i hosts -m ping

# other options
$ vim hosts
[droplet]
134.209.255.142
134.209.255.155 

[droplet:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_user=root

:wq
$ ansible droplet -i hosts -m ping

// Lessaon-225 ( Add EC2 instance to Inventory )
# Create two EC2 instances on AWS with instead of providing our key to aws
# Aws created key pair: ansible.pem download on local machine

$ vim hosts
[droplet]
134.209.255.142
134.209.255.155 

[droplet:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_user=root

[ec2]
ec2-15-188-239-5.eu-west-3.compute.amazonaws.com
ec2-35-188-204-130.eu-west-3.compute.amazonaws.com ansible_python_interpreter=/usr/bin/python3

[ec2:vars]
ansible_ssh_private_key_file=~/Downloads/ansible.pem
ansible_user=ec2-user

:wq

# Private IPv4 address or DNS
$ ssh -i ~/Downloads/ansible.pem ec2-user@ec2-15-188-239-5.eu-west-3.compute.amazonaws.com
$ ls -l ~/Downloads/ansible.pem
# Only read permission
$ chmod 400 ~/Downloads/ansible.pem
$ ssh -i ~/Downloads/ansible.pem ec2-user@ec2-15-188-239-5.eu-west-3.compute.amazonaws.com
$ python
>>> exit()
$ sudo yum install python3
$ python3
>>> exit()
$ exit

$ ansible ec2 -i hosts -m ping
# Remove EC2 instances

// Lesson-226 ( Managing Host Key Checking )
# Managing Host key checking: Authorized keys & Known hosts
# "long-lived" or "ephemeral/temporary" servers
$ cat ~/.ssh/known_hosts
# remote server host key added to ~/.ssh/known_hosts file
$ ssh-keyscan -H 165.22.201.197 >> ~/.ssh/known_hosts
# server authenticate our machine using ~/.ssh/id_rsa.pub when created droplet
$ ssh root@165.22.201.197
$ cat .ssh/authorized_keys

# If Creating Droplet using password, then add SSH public key to Droplet
$ ssh-keyscan -H 188.166.30.219 >> ~/.ssh/known_hosts
$ ssh-copy-id root@188.166.30.219 # then provide password only for first time
$ ssh root@188.166.30.219

$ vim hosts
[droplet]
134.209.255.142
134.209.255.155 
165.22.201.197
188.166.30.219

[droplet:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_user=root

$ ansible droplet -i hosts -m ping

# Disable Host key Checking, less secure
# Ephemeral Infrastructure
# Servers are dynamically created and destroyed, like: Scaleup, Scaledown
# Create new droplet for Disable host key checking on Ansible configuration file
$ ls /etc/ansible
# config file default two location: "/etc/ansible/ansible.cfg" or "~/.ansible.cfg"
$ vim ~/.ansible.cfg
[defaults]
host_key_checking = False

:wq

$ vim hosts
# for new droplet or server not host key checking
$ ansible droplet -i hosts -m ping

# In ansible project directory
$ vim ansible.cfg
[defaults]
host_key_checking = False

// Lesson-227 ( Ansible Playbook )
$ mkdir ansible
# 2 minimum requirements: managed nodes to target and at least one task to execute
# ordered list of tasks
# plays & tasks runs in order from top to bottom

# Playbook can have multiple Plays
# Play is a group of tasks

# 1 Play for Database Servers
# 1 Play for Webservers

# ansible folder
$ ansible-playbook -i hosts my-playbook.yaml

# "Gathering Facts" Module: auto called, gather useful varibles about remote hosts that will be used
$ ssh root@134.209.255.142
$ ps aux | grep nginx
$ nginx -v

#      name: nginx= 1.28.0-6ubuntu1 //specfic version
#      state: present

#      name: nginx= 1.28* //any version that start with 1.28
#      state: present

$ ansible-playbook -i hosts my-playbook.yaml

# Idempotency: module check that desired state already achieved and then exit without performing any actions
# Compare Actual vs Desired state

$ ansible-playbook -i hosts my-playbook.yaml
# Check chnages
$ ansible-playbook -i hosts my-playbook.yaml
# 2nd time run to check for idempotency

// Lesson-228 ( Modules Overview )
# https://docs.ansible.com/projects/ansible/2.9/modules/modules_by_category.html
# Version:2.9 where latest:ansible-core 2.19/Ansible 12
# https://docs.ansible.com/projects/ansible/latest/collections/index_module.html

// Lesson-229 ( Ansible Collection )
# ansible-base package & ansible package (Collection : Playbook, Modules & plugins... in a single bundle)
# A packaging format for bundling and distributing Ansible content
# All modules are part of a collection.
# Plugins: pieces of code that add to Ansible's functionality or modules
$ ansible-galaxy collection list
# Galaxy: Online hub for finding and sharing ansible collections. Compare: Like registry, npm repo, terraform registry, Pip..
$ ansible-galaxy install <collection name>

# To update a specific collection
$ ansible-galaxy collection install amazon.aws

# Check update collection
$ ansible-galaxy collection list

# For Bigger Project: Create Own collection with a Standard Structure:
### Standard Collection Layout

```
collection/
├── docs/                          # Documentation files
│   └── README.md
├── galaxy.yml                     # Collection metadata
├── meta/
│   └── runtime.yml               # Runtime configuration
├── plugins/
│   ├── modules/                  # Custom modules
│   │   └── module1.py
│   ├── inventory/               # Dynamic inventory plugins
│   ├── filter/                  # Custom filters
│   └── lookup/                  # Custom lookup plugins
├── roles/                        # Reusable roles
│   ├── role1/
│   │   ├── tasks/
│   │   ├── handlers/
│   │   ├── templates/
│   │   ├── files/
│   │   ├── vars/
│   │   ├── defaults/
│   │   └── meta/
│   ├── role2/
│   └── .../
├── playbooks/                    # Playbooks
│   ├── site.yml
│   ├── deploy.yml
│   └── .../
├── inventory/                    # Inventory files
│   ├── hosts
│   ├── hosts_prod
│   └── hosts_dev
├── vars/                         # Variable files
│   ├── common.yml
│   └── environment.yml
├── templates/                    # Jinja2 templates
│   └── config.j2
├── tests/                        # Test files
│   ├── test_playbook.yml
│   └── test_inventory
└── README.md
```

// Lesson-230 ( Project: Part 1 - Automate Node App Deployment )
# Create a Droplet
$ anisble-playbook -i hosts deploy-node.yaml

# Check unpack succesfully or not on remote server
$ ssh root@159.89.1.54
$ ls
$ ls package/

# remove file and only one step for copy & unarchieve
$ rm app-1.0.0.tgz
$ rm -rf package/

# rerun the new file
$ anisble-playbook -i hosts deploy-node.yaml
$ anisble-playbook -i hosts deploy-node-one.yaml

// Lesson-231 ( Project: Part 2 - Automate Node App Deployment )
# Start Node App
# Where each task executed: Local Machine(Control Node) or Remote Server(Managed Node)
# Go to server and check dependencies installed or not
$ ls package/
$ cd package/
$ ps aux | grep node # check node app running or not

# Shell Module: pipe "|", redirects ">" "<", boolean "&&" "||", env-vars $HOME (Comapared to command module)
$ ansible-playbook -i hosts deploy-node-one.yaml

// Lesson-232 ( Project: Part 3 - Automate Node App Deployment )
# Execute task as a non-root user
# User for Each app or Each team member
$ ansible-playbook -i hosts deploy-node-one.yaml

// Lesson-233 ( Variables in Ansible Playbooks )
# registered variables
$ ansible-playbook -i hosts deploy-node-one.yaml

#       register: app_status
#    - debug: msg={{ app_status.stdout_lines}}
Task [debug]**************************************
ok: [159.89.1.54] => {
    "msg": {
        "append": false,
        "changed": false,
        "comment": "shuvo admin",
        "failed": false,
        "group": 116,
        "home": "/home/shuvo",
        "move_home": false,
        "name": "shuvo",
        "shell": "/bin/sh",
        "state": "present",
        "uid": 1000
    }
}

# Parametrize playbooks using variables
# Set values for test environment => Ansible playbook => TEST environment
# Set values for production environment => Ansible playbook => PRODUCTION environment
# "{{ node_file_location }}" => variable
# /Users/shuvo83qn/Demo-projects/Bootcamp/nodejs-app/nodejs-app-{{version}}.tgz
# "{{ location }}/nodejs-app/nodejs-app-{{version}}.tgz" => parameterized with variable
# --extra-vars or -e flag to pass variables at runtime
$ ansible-playbook -i hosts deploy-node-one.yaml -e "version=1.0.0 location=/Users/shuvo83qn/Demo-projects/Bootcamp"
$ ansible-playbook -i hosts deploy-node-one.yaml -e "version=1.0.0 location=/Users/shuvo83qn/Demo-projects/Bootcamp linux_name=shuvo"

# Create a variable file: project-vars.yaml
$ ansible-playbook -i hosts deploy-node-one.yaml

// Lesson-234 ( Project: Automate Nexus Deployment )
# Manual Process: Create Droplet, SSH into Droplet, Install Java, Download Nexus, Unpack Nexus, Start Nexus
$ ansible-playbook -i hosts deploy-nexus.yaml

# Check Nexus running or not
$ ssh root@134.122.73.78
$ ls /opt/
$ java
$ netstat
$ ls /opt/
$ rm -rf /opt/sonatype-work # remove all

# Rename folder
$ mv nexus-3.30.0-01 nexus

# "find" module => return a list of file based on sepcific criteria
# shell command executed when: not true => False => shell command not executed

// Lesson-235 (  Project: Automate Nexus Deployment )
# For checking nexus user to own nexus folder
$ ansible-playbook -i hosts deploy-nexus.yaml
$ ls -l /opt/

$ su - nexus
$ pwd
$ exit
$ ls -l /opt/nexus

$ vim /opt/nexus/bin/nexus.rc
#run_as_user=""
run_as_user="nexus"

:q!

# Do the task with ansible
$ ansible-playbook -i hosts deploy-nexus.yaml
$ vim /opt/nexus/bin/nexus.rc
#run_as_user=""
# BEGIN ANSIBLE MANAGED BLOCK
run_as_user="nexus"
# END ANSIBLE MANAGED BLOCK

# Delete 3 line to check "lineinfile" module
$ ansible-playbook -i hosts deploy-nexus.yaml

$ ps aux | grep nexus
$ /opt/nexus/bin/nexus run

# For nexus create bigger size droplet
# For new droplet execute
$ ansible-playbook -i hosts deploy-nexus.yaml

$ ssh root@134.122.77.88
$ ps aux | grep nexus
$ kill 16479

# Rerun playbook
$ ansible-playbook -i hosts deploy-nexus.yaml

# Pause and Waitfor modules documentation check

// Lesson-236 ( Git and Default Inventory )
# Create new repo and push

// Lesson-237 ( Ansible and Docker )
# Create AWS EC2 Instance with Terraform
# Configure Inventory file to connect to AWS EC2 Instance
# Write Ansible Playbook: Install Docker & docker-compose & Copy docker-compose file to server
# Start Docker containers to run application
# Using main.tf file
$ terraform init
$ terraform plan
$ terraform apply -auto-approve

# output publice_ip_address
$ ssh root@35.181.5.225
$ apt => not found
$ yum

# become_user: root => by default
$ ansible-playbook deploy-docker.yaml
# python => version2 => exit() => python3
$ docker
# no package docker-compose available in yum repository => sudo yum install docker-compose

# Download docker-compose
$ sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
# On ec2 Instance
$ uname -s
$ uname -m

# Jinja 2 template
$ ansible-playbook deploy-docker.yaml
$ docker-compose

# To check docker running
$ docker pull redis

# start docker-deamon
$ sudo systemctl start docker

# To run without sudo
$ sudo usermod -aG docker ec2-user
# But ec2-user not added to docker group to the current session
$ exit
# Then this time ec2-user added into docker group
$ sudo docker pull redis

# To check current user already added which groups
$ groups

# remove user from groups
$ sudo gpasswd -d ec2-user docker

# For testing exit then reconnect

# Check using ansible-playbook
$ ansible-playbook deploy-docker.yaml => not work for permission

# After fixing meta: reset_connection
$ ansible-playbook deploy-docker.yaml

// Lesson-238 ( Ansible and Docker: "community.docker" Ansible Collection )
# command and shell use only, when there is no appropiate Ansible module available, not Idempotent
# community.docker.docker_image
# <namespace>.<collection>.<module/plugin>
# Fully Qualified Collection Name: FQCN
$ ansible-playbook deploy-docker.yaml

# Install python docker module corresponding ansible module
# pull private image
$ docker pull shuvo83qn/demo-app:java-maven-2.0

# Interactive input: prompts
# prompting the user for variables lets you avoid recording sensitive data like passwords
$ docker pull shuvo83qn/demo-app:java-maven-2.0
$ ls ~/.docker/config.json

$ ansible-playbook deploy-docker.yaml
# run docker-compose
$ docker-compose -f docker-compose.yaml up
$ docker images
$ docker rmi shuvo83qn/demo-app:java-maven-2.0

# rerun playbook
$ ansible-playbook deploy-docker.yaml

# docker-compose python module needed
$ docker ps

# Check ansible-playbook completely new server
$ terraform destroy -auto-approve

# Create a new Ec2
$ terraform apply -auto-approve
# Copy new ip_address and paste it to hosts

# check new server
$ ssh ec2-user@35.180.25.170
$ docker ps

// Lesson-239 ( Ansible and Terraform )
# Provisioning server using Terraform, Configuring server using Ansible
# Get the ip_address from tf, update hosts, execute ansible command manually
# tf hand over to ansible, only one command to execute terraform apply
# Destroy the current setup
$ terraform destroy -auto-approve

# Tf provisioner: local-exe, remote-exec, file
# --inventory takes a file location as a parameter or "," seperated ip addresses
$ terraform apply 

$ ssh ec2-user@15.237.41.0
$ sudo docker ps

# Wait for Ec2 fully initialized
# Ansible needs to check first, whether EC2 is ready or not
# wait_for module logic true, before executing the next task
$ ssh ec2-user@15.237.41.0
$ sudo docker ps

# Using null_resource from tf
$ terraform init
$ terraform apply

// Lesson-240 ( Dynamic Inventory )
# Managing an inventory, spinning up and down for auto-scaling to accomodate load-balancing
# hard-coding ip_addresses on hosts set dynamically
# Create 3 Ec2 instances with tf and dynamically connect to these instance without hardcoding Ip addresses on Ansible playbook hosts
$ terraform init
$ terraform apply

# Dynamic Inventory plugins vs Inventory script
# Functionality: connects to AWS account and get server information
# plugins make use of Ansible features like: State management, written in yaml format, where scripts in python
# Plugins/Scripts specific to Infrastructure provider: For AWS, you need aws specific plugins/scripts
$ ansible-doc -t inventory -l

# aws_ec2 inventory
$ pip install boto3
$ pip install botocore

# Used to display ansible-inventory configured information
$ ansible-inventory -i inventory_aws_ec2.yaml --list
$ ansible-inventory -i inventory_aws_ec2.yaml --graph

# Assign public dns name to conncect ec2 outside the vpc
$ terraform destroy -auto-approve
$ terraform apply -auto-approve
$ ansible-inventory -i inventory_aws_ec2.yaml --graph

# Configure Ansible to use dynamic inventory
$ ansible-playbook -i inventory_aws_ec2.yaml deploy-docker-new-user.yaml

# If new server added or removed to tf same playbook command do the staff
$ ansible-playbook -i inventory_aws_ec2.yaml deploy-docker-new-user.yaml

# if added invertory:inventory_aws_ec2.yaml to ansible.cfg 
$ ansible-playbook deploy-docker-new-user.yaml

# Target specific server
$ terraform destroy -auto-approve

# Two dev & Two prod
# Specific ansible playbook for dev or prod server
# filter attributes: image-id, instance-state-name etc.
$ ansible-inventory -i inventory_aws_ec2.yaml --graph

# Group: aws_ec2, Group: dev_servers, Group: prod_servers
# keyed_group: used key:tags value that get from any attribute came from ansible-inventory -i inventory_aws_ec2.yaml --list output
$ ansible-playbook deploy-docker-new-user.yaml

# Grouping based instance_type
$ ansible-inventory -i inventory_aws_ec2.yaml --graph

// Lesson-241 ( Automate Deployment into k8s cluster )
# Create k8s cluster on AWS EKS using tf
# Configure Ansible to connect to EKS cluster
# Deploy Deployment and Service component

# In ansible-eks/terraform-eks-project folder
$ terraform init
$ terraform apply

# Create a Namespace in EKS cluster
# To connect to the eks-cluster using kubectl with kubeconfig_myapp-eks-cluster with ansible
# community.kubernetes.k8s module to run kubectl command
# Which cluster and how to connect? needs clusters-address and credentials
# Openshift Python client is used to perform CRUD operations on k8s objects
# PyYAML = YAML parser and emitter for Python
$ python3 -c "import openshift"
$ python3 -c "import yaml"

# pip defaults to installing Python packages to a system directory(/usr/local/libpython3.7) => requires root access
# --user makes pip install packages in your home directory instead => no need special previleges
$ pip3 install openshift --user
$ pip3 install PyYAML --user

# Check
$ python3 -c "import openshift"
$ python3 -c "import yaml"

# Run playbook
$ ansible-playbook deploy-to-k8s.yaml

# Connect k8s cluster and check
$ export KUBECONFIG=~/f/Shanto_PC/BdCalling/online-shop-microservices/ansible-eks/terraform-eks-project/kubeconfig_myapp-eks-cluster/kubeconfig_myapp-eks-cluster
$ kubectl get ns # check my-app exists or not

# Deploy app in new namespace
$ ansible-playbook deploy-to-k8s.yaml
$ kubectl get pod -n my-app
$ kubectl get svc -n my-app # AWS assign public_dns and public_ip with it, search in browser using that

# using definition: attribute you can write same k8s yaml file inside ansible playbook
# Set environment variable for kubeconfig

# Using local terminal where ansible-playbook execute:
$ export K8S_AUTH_KUBECONFIG=~/f/Shanto_PC/BdCalling/online-shop-microservices/ansible-eks/terraform-eks-project/kubeconfig_myapp-eks-cluster/kubeconfig_myapp-eks-cluster
$ ansible-playbook deploy-to-k8s.yaml

// Lesson-242 ( Ansible Integration in Jenkins Pipeline Project - Part 1 )
# Create a DO server for Jenkins => Installed tools(tf,kubectl,...) inside Jenkins server/container => then commands available for Jenkins jobs
# Create dedicated server for Ansible & Install Ansible on that server(Control Node), two seperate DO droplet
# Execute Ansible Playbook from Jenkins Pipeline to configure 2 EC2 Instance
# Create 2 EC2 Instance
# Configure everything from scratch with Ansible
# Create a Pipeline in Jenkins
# Connect pipeline to Java Maven Project
# Create Jenkinsfile that executes Ansible Playbook on the remote Ansible server
$ ssh root@167.99.136.157
$ apt update
$ apt install ansible
$ ansible

# Install boto3 and botocore
$ apt install python3-pip
$ python3
exit()

$ pip3 install boto3 botocore # Not works
# Fix options
# Option 1: Recommended: Install distro packages on the control node (recommended for Ansible control node)
sudo apt update
sudo apt install -y python3-boto3 python3-pip python3-venv
# verify
python3 -c "import boto3,botocore; print(boto3.__version__, botocore.__version__)"

# Option 2:Create a Python virtual environment and install packages there (recommended if you want isolated pip)
sudo apt update
sudo apt install -y python3-venv python3-pip
python3 -m venv /opt/ansible-venv
sudo chown -R $(id -u):$(id -g) /opt/ansible-venv
source /opt/ansible-venv/bin/activate
pip install --upgrade pip
pip install boto3 botocore
# run ansible from the venv so it uses installed libraries:
pip install ansible-core  # or ansible
ansible --version
deactivate
# If Ansible runs from the control node outside the venv, configure the inventory or ansible.cfg to use venv interpreter:
# ansible.cfg (or inventory vars)
[defaults]
interpreter_python = /opt/ansible-venv/bin/python

# Ensure AWS credentials are available to Ansible to get dynamic inventory using plugin aws_ec2 hosts:
ansible-inventory -i inventory_aws_ec2.yaml --graph
ansible-playbook -i inventory_aws_ec2.yaml --list-hosts

$ mkdir .aws
$ cd .aws/
$ vim credentials
# IAM role for the control node or
# AWS CLI configured (~/.aws/credentials) like local: cat .aws/credentials 
# Environment variables: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION
$ exit

# Create 2 EC2 Instances
# Create new key pair: Download Key Pair: ansible-jenkins.pem => this private key needs to provide Ansible server to connect to the EC2 Instances

// Lesson-243 ( Jenkinsfile: Copy Files from Jenkins to Ansible Server )
# Create a new branch in java-maven-app => git checkout -b feature/ansible
# Jenkins Server ---------(trigger to execute ansible-playbook cmd to )------------> Ansible Server:Control Node
# So that Jenkins has to copy these files(ansible.cfg, inventory_aws_ec2.yaml, my-playbook.yaml, ansible-jenkins.pem) from project repo to remote ansible server

# SSH Agent used using ssh key to connect remote server and then copy files using scp command
# Install SSH Agent plugins on Jenkins server
# http://137.184.124.136:8080/manage/pluginManager/
# Manage Credentials: http://137.184.124.136:8080/manage/credentials/store/system/domain/_/newCredentials
# Kind: SSH Username with private key
# ID: ansible-server-key
# Username: root
# Private Key: paste ssh private key content: $ cat ~/.ssh/id_rsa => ------BEGIN OPENSSH PRIVATE KEY----- => If not supported, then
# Old Format:  ------BEGIN RSA PRIVATE KEY-----
$ ssh-keygen -p -f .ssh/id_rsa -m pem -P "" -N "" # Classic openssh format
# Copy content: cat .ssh/ssh_key_rsa_format to Credentials
# Go back to Jenkins file write logic to connect and copy files to ansible server

# To connect ec2 instances from ansible-playbook Create ec2-server-key credentials same way following ansible-server-key using ansible-jenkins.pem file
$ cat Downloads/ansible-jenkins.pem

# withCredentials copy ec2-server-key context to ansible server

# Create jenkins pipeline to execute jenkins for branch: feature/ansible 
$ git checkout -b feature/ansible
$ git push --set-upstream origin feature/ansible

# New Item: Enter an item name: ansible-pipeline
# select: pipeline 
# configure: Pipeline: Pipeline script from scm
# SCM: Git
# Repository URL: https://github.com/shuvo-art/DevOps.git
# Credentials: Select existing or create new
# Branch Name: feature/ansible
# Save and Build Now

# Check ansible files and ssh-key.pem file available or not
$ ssh root@167.99.136.157
$ ls

# git commit -m "Fix security warning for pem file"
sh 'scp $keyfile root@167.99.136.157:/root/ssh-key.pem' => sh "scp ${keyfile} root@167.99.136.157:/root/ssh-key.pem"

# Build Now pipeline again
# Check Console Output logs any warnings exists or not

# Another Jenkins plugin: SSH Pipeline Steps needs to run ansible-playbook cmd on ansible server

# New commit for remote execution with cmd: "ls -l; ansible-playbook my-playbook.yaml"
# push to repo and Build Now

// Lesson-244 ( Ansible Integration in Jenkins )
# Optimization

// Lesson-245 ( Ansible Roles )
# When lots of Infrastructure, Networks, Applications, then it becomes complex and not maintainable
# Group your content in roles # Break up large playbooks into smaller manageable files
# Like a package for your tasks # Extracting tasks from Playbooks
# Extract tasks and bundle in a role package
# Re-use roles in different Plays # Much cleaner Plays

# Example of roles:
- name: Create a linux user
  hosts: all
  become: yes
  vars:
    user_groups: adm,docker
  roles:
    - create_user

- name: Start docker containers
  hosts: all
  become: yes
  become_user: nana
  vars_files:
    - project-vars
  roles:
    - start_containers

# Tasks that the role executes => tasks/main.yml                         #
# Static Files that the role deploys => files/my-file.yml                #
# (Default) Variables for the tasks => vars/main.yml, defaults/main.yml  # => Package
# Custom modules, which are used within this role => library/my_module.py#
# Like small applications, standard file structure                       #

collection/

├── galaxy.yml                     # Collection metadata
├── meta/
│   └── runtime.yml               # Runtime configuration
├── plugins/
│   ├── modules/                  # Custom modules
│   │   └── module1.py
│   ├── inventory/               # Dynamic inventory plugins
│   ├── filter/                  # Custom filters
│   └── lookup/                  # Custom lookup plugins
├── roles/                        # Reusable roles
│   ├── common/
│   │   ├── tasks/
│   │   ├── handlers/
│   │   ├── templates/
│   │   ├── files/
│   │   ├── vars/
│   │   ├── defaults/
│   │   └── meta/
│   ├── webservers/
│   └── .../
├── playbooks/                    # Playbooks
│   ├── site.yml
│   ├── webservers.yml
│   └── fooservers.yml
├── inventory/                    # Inventory files
│   ├── hosts
│   ├── hosts_prod
│   └── hosts_dev
├── vars/                         # Variable files
│   ├── common.yml
│   └── environment.yml
├── templates/                    # Jinja2 templates
│   └── config.j2
├── tests/                        # Test files
│   ├── test_playbook.yml
│   └── test_inventory
└── README.md
```

# Default Variables: Parameterize role, but execute without having to define variables
# Possiblity to overwrite default variables
# Use existing Roles from community like: Mysql database configuration, Install Nginx on Ubuntu, etc..
# Ansible Galaxy: To find Collections or Roles
# Git Repository: To find Roles

# Create Roles & use Roles in your Playbook
# Like Function: extract common logic, use function in different places with different parameters

# Check out roles creation we need ec2 servers
$ terraform apply --auto-approve
$ ansible-playbook deploy-docker-with-roles.yaml -i inventory_aws_ec2.yaml

# check existing deployment
$ ssh ec2-user@ec2-15-188-80-52.eu-west-3.compute.amazonaws.com
$ sudo docker ps

# Rurun for docker-compose.yaml in files folder
$ ansible-playbook deploy-docker-with-roles.yaml -i inventory_aws_ec2.yaml

# Customize Roles with Variables
# Variable Precedence: from least to greatest (the last listed variables override all other variables)
# CLI arguments extra vars (for example: -e "user=my-user")
# roles.start_containers.vars.main.yaml file variables
# If user's not mentioned variables anywhere defaults.main.yaml files executes
$ ansible-playbook deploy-docker-with-roles.yaml -i inventory_aws_ec2.yaml

// Lesson-246 (Premetheus)
# Create a K8s cluster with EKS
# Deploy Microservice app
# Deploy Prometheus Monitoring Stack
# Monitor Cluster worker Nodes(cpu,ram,storage)
# Monitor K8s components(Workloads,pods,deployment,services)
# Monitor 3rd-party application Redis # Deploy Redis Exporter
# Monitor own application
# Infrastructure level, Platform level, Application level
# pull metrics above 3 level and data visualization using Prometheus UI(Grafana)
# Alertmanager send Email using alert rules configuring Receiver

// Lesson-247 (Premetheus - Intro)
# Error monitoring: Downtime, Latency, Traffic, Saturation, Errors
# Example: Memory outage: kicks container, database pod dies, backend and frontend not works
# prometheus monitor and notify, logs: Available Space vs ElasticSearch Consumption
# Monitoring networks loads, alerting

# Prometheus Server: Storage:Time Series Database: Store metrics data of cpus, exception and storages info
#                    Retrival:Data Retrival Worker: pulls metrics data from application, services, server: Store them on Storage
#                    HTTP Server: Accept PromQL queries: API request to fetch data from Storage and Show in Dashboard Or Grafana

# Monitor: Linux/Windows Server, Apache Server, Single Application, Service:Database
# Units: CPU Status, Memory/Disk space, Exception Count, Requests Count, Request Duration In Metrices

# Metrics: HELP: description of what the metrics is..
#          TYPE: Counter: How many times x happend?
#                Gauge: Current Value of x?
#                Histogram: how long or how big request?

# Collecting Metrics Data from Targets: pulls over HTTP, hostaddress/metrics endpoint, correct format
# Exporter: fetches metrics from Target service, convert correct format, expose /metrics endpoint for Data Retrival Worker

# Monitor Linux Server: Download node exporter, untar & execute, converts metrics of server, expose /metrics endpoint, configure prometheus to scrape that endpoint
# Exporter available as Docker images: Like mysql db are running with a sidercar mysql exporter container

# Monitor own applications: how many request, how many exceptions, server resource? => Using client libraries expose /metrics endpoint

# Amazon Cloud Watch/New Relic: Applications/Servers push to a centralized collection platform
# Prometheus targets/Pushgateway(short lived job)
# prometheus.yaml: 
global:
  scrape_interval: 15s        # how often prometheus will scrape its targets
  evaluation_interval: 15s    # how often rules applied

rule_files:
  # - "first.rules"
  # - "second.rules"     # Rules for aggregating metric values for creating alerts when condition met

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']  # What resource prometheus monitors with /metrics endpoint
  - job_name: node_exporter
    scrape_interval: 1m               # default for each job
    scrape_timeout: 1m                # metrics_path: "/metrics"
    static_configs:                   # scheme: "http"  
      - targets: ['localhost:9100']

# Prometheus Server: push alert based on alert rules from the config files: Alertmanager:notify Slack or Email
# Prometheus Data Storage: PromQL query through Grafana
# Example: http_requests_total{status!~"4.."}: rate(http_requests_total[5m])[30m:]

# Prometheus Federation: Allows a Prometheus server to scrape data from other Prometheus servers

// Lesson-248 (Setup Prometheus in EKS Cluster)
# Non efficient: Create all configuration YAML file and execute right order(sts,cm,secret,deploy) Prometheus, Grafana, Alertmanager
# Efficient: Using an operator: Manager of all prometheus components: Find Prometheus operator, deploy on k8s
# Most efficient: Using Helm chart to deploy operator: Helm + Operator
# Steps: Create EKS cluster, Deploy MS application, Deploy Prometheus Stack, Monitor K8s cluster, Monitor MS application
# Create an IAM user or role with EKS permissions (AmazonEKSFullAccess or granular policies: eks:, ec2:, iam:, cloudformation:, autoscaling:, elb:, route53:, ecr:)
# Configure AWS credentials locally: aws configure
# Tools: Install eksctl, kubectl, aws CLI, and Helm
sudo apt update
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
  | tar xz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
sudo apt install -y awscli
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Basic quick cluster (dev/test):
# quick cluster using managed nodegroup
eksctl create cluster \
  --name my-eks-cluster \
  --region us-east-1 \
  --version 1.26 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 2 \
  --nodes-max 5 \
  --managed

# Production-grade cluster with YAML config
$ eksctl create cluster -f cluster.yaml
# eksctl will update kubeconfig automatically, or use aws
aws eks update-kubeconfig --name my-production-cluster --region us-east-1
kubectl get nodes
kubectl get pods -A

# Associate IAM OIDC provider (if not enabled; eksctl can do it during create)
eksctl utils associate-iam-oidc-provider --cluster my-production-cluster --approve

# Install required addons (IRSA, Load Balancer controller, CSI, metrics, autoscaler)
# Create IAM Service Account for ALB (or use eksctl helper)
eksctl create iamserviceaccount \
  --cluster my-production-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::aws:policy/AWSLoadBalancerControllerPolicy \
  --approve
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-production-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# Install EBS CSI driver
eksctl create addon --name aws-ebs-csi-driver --cluster my-production-cluster --force

# Install metrics-server and cluster-autoscaler
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
eksctl create iamserviceaccount --cluster my-production-cluster --namespace kube-system --name cluster-autoscaler \
  --attach-policy-arn arn:aws:iam::aws:policy/AutoScalingFullAccess --approve
# Deploy cluster-autoscaler using Helm or manifest and annotate service account

# Ensure StorageClass exists for EBS CSI driver, verify dynamic provisioning:
kubectl get storageclass

# Nana Video-248
$ eksctl create cluster # default region, default AWS credentials, 2 Worker Nodes
$ kubectl get node # two nodes as output
# ip-192-168-18-35.eu-west-3.compute.internal
# ip-192-168-82-254.eu-west-3.compute.internal

# Deploy Microservices Application
$ kubectl apply -f config-microservices.yaml # config.yaml file
$ kubectl get pod # default ns

# Deploy Prometheus stack using Helm
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
$ kubectl create namespace monitoring
$ helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring
$ kubectl --namespace monitoring get pods -l "release=monitoring"
$ kubectl get all -n monitoring

# Understanding All Prometheus Staffs
# 2 Statefull set: .../prometheus-monitoring-kube-prometheus-prometheus & alertmanager-monitoring-kube-prometheus-alertmanager
# 3 Deployments: .../monitoring-kube-prometheus-operator(Created Prometheus & Alertmanager sts), Grafana, .../kube-state-metrics(scraps k8s components)
# 3 replicaset: Created based on 3 deployments(.../monitoring-kube-prometheus-operator(Created Prometheus & Alertmanager sts), Grafana, .../kube-state-metrics(scraps k8s components))
# 1 Node Exporter DaemonSet: runs on every worker node(Connect to server, translates worker node metrics to prometheus metrics.ex:cpu usage, load)
# 7 pods: from Deployments and StatefullSets
# 8 services: each components has its own
# worker nodes & k8s components monitored

# From where the above configuration come from?
$ kubectl get configmap -n monitoring
# bunch of staff managed by operator, connect to default metrics using rulefiles
$ kubectl get secret -n monitoring
# Custom resource definition: extension of k8s api
$ kubectl get crd -n monitoring
$ kubectl get statefulset -n monitoring
$ kubectl describe statefulset prometheus-monitoring-kube-prometheus-prometheus -n monitoring > prom.yaml
$ kubectl describe statefulset alertmanager-monitoring-kube-prometheus-prometheus -n monitoring > alert.yaml

$ kubectl get deployment -n monitoring
$ kubectl describe deployment monitoring-kube-prometheus-operator -n monitoring > oper.yaml

# prom.yaml > Containers: prometheus: Images, Port, Args, Mounts(where prometheus gets its configuration data) => everything mounted into prometheus pod => Configuration file: What endpoints to scrape /metrics => Rules Configuration files:Alerting
# config-reloader: responsible for reloading when configuration files changes
# From where configuration files and rules files come from?
# Args => Mounts => Volumes:config
$ kubectl get secret -n monitoring prometheus-monitoring-kube-prometheus-prometheus -o yaml > secret.yaml
$ kubectl get configmap -n monitoring prometheus-monitoring-kube-prometheus-prometheus-rulefiles-0 -o yaml > config.yaml

# alert.yaml => Containers: alert manager: Args, Mounts, config-reloader
# oper.yaml => Containers: alert manager: Args, Mounts, config-reloader
# orchestrator of whole monitoring stack

# Need to know: How to add/adjust alert rules?
# How to adjust Prometheus configuration?    # For new endpoints....for scraping....

// Lesson-249 (Data Visualization)
# Cluster Nodes(2worker node): k8s cluster(application): k8s components(sts,pod,svc): cpu spikes, Insufficient storage, High load, Unauthorized requests..
$ kubectl port-forward service/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090 
# Browser: 127.0.0.1:9090: Status: Tagrgets => you need to add the "target" to redis, to monitor.
# SearchBox expression (METRICS NAMES: apiserver_request_total,container_processes,..cpu..)
# Status: Configuration(scrape_config: - job_name: => list of job_name) => goto targets:expand one target:ex.apiserver:endpoint/Instance:collection of Instances used for same purpose using labes: job="apiserver", Runtime & Build Information
# SearchBox: apiserver_request_total{job="apiserver",instance="192.168.126.249:443"}

// Lesson-250 (Grafana)
# service/monitoring-grafana running on ClusterIP:10.100.112.33 on Port:80
$ kubectl port-forward service/monitoring-grafana 8080:80 -n monitoring 
# Browxer: 127.0.0.1:8080: Default Cred: user:admin, pwd:prom-operator
# Dashboards: Manage: General: Kubernetes/Compute Resources/Cluster
# Rows are used to group panels together # Folders => Dashboards => Rows => Panels
# For a specific spike: Dashboards: Manage: General: Kubernetes/Compute Resources/Node (Pods) # You can select specific node or nodes, specific time frame,
# Panel Edit: PromQL to fetch data to visualize
# Create own Dashboard: Add an empty panel => PromQL query/Metrics Browser(respective labels) => Use query => Table/Graph view => Apply...
# Dashboards: Manage: General: Nodes
# Dashboards: Manage: General: Kubernetes/Compute Resources/Workload
# Dashboards: Manage: General: Kubernetes/Compute Resources/Pod
$ kubectl run curl-test --image=radial/busyboxplus:curl -i --tty --rm
[ root@curl-test:/ ]$ ls
[ root@curl-test:/ ]$ vi test.sh
for i in $(seq 1 10000)
do
  curl http://a2478368742s87fs9aa8fg98f7a9f-327834982379.eu-west-3.elb.amazonaws.com > text.txt
done
[ root@curl-test:/ ]$ chmod +x test.sh
[ root@curl-test:/ ]$ ./test.sh
$ kubectl get svc => frontend-external: a2478368742s87fs9aa8fg98f7a9f-327834982379.eu-west-3.elb.amazonaws.com => Search in Browser
# Check: Dashboards: Manage: General: Kubernetes/Compute Resources/Node (Pods)
# Access Grafana: Configuration:Users, Configuration:Data sources, if you want add other sources,
# Explore: For different query

// Lesson-251 ( Alert Rules in Premetheus )
# 2 steps: Alert rules: cpu usage, pod can't restart & alertmanager sends mail
# Prometheus dashboard UI: Alerts: alertmanager.rules group, etcd group, kubernetes-apps...
# AlertmanagerFailedReload, AlertmanagerFailedToSendAlerts, AlertmanagerConfigInconsistent...
# etcd for control nodes
# KubePodCrashLooping, KubePodNotReady, KubeStatefulSetReplicasMismatch..
# Green: inactive or condition not met, Red: Firing. Condition is met(KubeSchedulerDown)
# expr: PromQL logic..
# max_over_time(alertmanager_config_last_reload_successful{job="monitoring-kube-prometheus-alertmanager",namespace="monitoring"}[5m]) == 0
# labels: severity: critical, warning => allows specifying a set of additional labels to attach to alert
# Slack: critical rules, Emails: warning rules, dev namespace rules, application abc rules,
# for: 10m => pending state => to resolve itself => firing state
name: AlertmanagerFailedReload
expr: max_over_time(alertmanager_config_last_reload_successful{job="monitoring-kube-prometheus-alertmanager",namespace="monitoring"}[5m]) == 0
for: 10m
labels:
  severity: critical
annotations:
  description: Configuration has failed to load for {{ $labels.namespace }}/{{ $labels.pod }}
  runbook_url: https://github.com/kubernetes-monitoring/kubernetes-mixin/tree/master/runbook.md#alert-name-alertmanagerfailedreload
  summary: Reloading an alertmanager configuration has failed.

// Lesson-253 (Create Own Alert Rules - Part2)
# Prometheus Operator extends the k8s API, we create custom k8s resources, Operator takes our custom k8s resource and tells prometheus to reload alert rules
$ kubectl apply -f alert-rules.yaml
$ kubectl get PrometheusRule -n monitoring # check main-rules including or not

# To check Prometheus reloaded configuration with new rules
$ kubectl get pod -n monitoring  #prometheus-monitoring-kube-prometheus-prometheus-0 #2container: prometheus or sidecar(config_reloader)
$ kubectl logs prometheus-monitoring-kube-prometheus-prometheus-0 -n monitoring # error
$ kubectl logs prometheus-monitoring-kube-prometheus-prometheus-0 -n monitoring -c config-reloader # reloaded with current times
$ kubectl logs prometheus-monitoring-kube-prometheus-prometheus-0 -n monitoring -c prometheus # msg="Completed loading of configuration files" # with current time
# Finally Check 127.0.0.1:9090/alerts => main.rules group

// Lesson-254 (Test Created Own Alert Rules - Part3)
# Cpu stress docker container
docker run -it --name cpustress --rm containerstack/cpustress --cpu 4 --timeout 30s --metrics-brief
# Translate it into kubectl
$ kubectl run cpu-test --image=containerstack/cpustress -- --cpu 4 --timeout 30s --metrics-brief
$ kubectl get pod # check cpu test
# Dashboards: Manage: General: Kubernetes/Compute Resources/Cluster
# General: Kubernetes/Compute Resources/Node (Pods)
# Check 127.0.0.1:9090/alerts => HostHighCpuLoad => Firing State

// Lesson-255 (Alertmanager - Part 1)
# Firing => pull metrics from cpu, cluser components = Prometheus server = send the alert to Alertmanager = Email
$ kubectl port-forward svc/monitoring-kube-prometheus-alertmanager -n monitoring 9093:9093 & [3] 81527 # what's this part "& [3] 81527"?
# 127.0.0.1:9093 => Alerts, Silences, Status, Help => status: config: global, route(which alert goes where), receiver
global:
  resolve_timeout: 5m
  http_config:
    follow_redirects: true
  smtp_hello: localhost
  smtp_require_tls: true
  pagerduty_url: https://events.pagerduty.com/v2/enqueue
  opsgenie_api_url: https://api.opsgenie.com/
  wechat_api_url: https://qyapi.weixin.qq.com/cgi-bin/
  victorops_api_url: https://alert.victorops.com/integrations/generic/20131114/alert/
route:
  receiver: "null"  # Any Alert
  group_by:
  - job
  continue: false
  routes:            # Specific Alerts
  - receiver: "null"
    match:
      alertname: Watchdog
    continue: false
  group_wait: 30s    # send notifications for a group of alerts
  group_interval: 5m
  repeat_interval: 12h # how long wait sending again
receiver: 
- name: "null"
templates:
- /etc/alertmanager/config/*.tmpl


// Lesson-256 ( Configure Alertmanager )
# /etc/alertmanager/config from config-volume (ro)
# config-volume: Type: Secret, SecretName: alertmanager-monitoring-kube-prometheus-alertmanager-generated 
$ kubectl get secret alertmanager-monitoring-kube-prometheus-alertmanager-generated -n monitoring -o yaml | less
apiVersion: v1
data:
  alertmanager.yaml: Z2skdlLKFW9R0W9EJFDSKLD......
kind: Secret
metadata:
  creationTimestamp: "2021-07-02T07:53:54Z"
  labels:
    managed-by: prometheus-operator
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        .: {}
        f:alertmanager.yaml: {}
        ......

$ echo Z2skdlLKFW9R0W9EJFDSKLD...... | base64 -D | less
# Output:
global:
  resolve_timeout: 5m
  http_config:
    follow_redirects: true
  smtp_hello: localhost
  smtp_require_tls: true
  pagerduty_url: https://events.pagerduty.com/v2/enqueue
  opsgenie_api_url: https://api.opsgenie.com/
  wechat_api_url: https://qyapi.weixin.qq.com/cgi-bin/
  victorops_api_url: https://alert.victorops.com/integrations/generic/20131114/alert/
route:
  receiver: "null"  # Any Alert
  group_by:
  - job
  continue: false
  routes:            # Specific Alerts
  - receiver: "null"
    match:
      alertname: Watchdog
    continue: false
  group_wait: 30s    # send notifications for a group of alerts
  group_interval: 5m
  repeat_interval: 12h # how long wait sending again
receiver: 
- name: "null"
templates:
- /etc/alertmanager/config/*.tmpl

# Create alert-manager-configuration.yaml & email-secret.yaml
$ kubectl apply -f email-secret.yaml
$ kubectl apply -f alert-manager-configuration.yaml
$ kubectl get alertmanagerconfig -n monitoring # main-rules-alert-config as output
$ kubectl get pod -n monitoring # alertmanager-monitoring-kube-prometheus-alertmanager-0 # 2 Containers => alertmanager & config_reloader
$ kubectl logs alertmanager-monitoring-kube-prometheus-alertmanager-0 -n monitoring
$ kubectl logs alertmanager-monitoring-kube-prometheus-alertmanager-0 -n monitoring -c config-reloader # reloaded with current times
# Check existing configuration merge with our configuration #127.0.0.1:9093/#/status
# monitoring-main-rules-alert-config-email
# - send_resolved: false # notification that the issue was resolved
# Check Label "alertname:HostHighCpuLoad", Label "namespace:monitoring" => send to receiver

// Lesson-257 ( Test Email Notification )
$ kubectl delete pod cpu-test
$ kubectl run cpu-test --image=containerstack/cpustress -- --cpu 4 --timeout 60s --metrics-brief
# HostHighCpuLoad firing
# 127.0.0.2:9093/api/v2/alerts => JSON

# Alertmanager logs:
$ kubectl logs alertmanager-monitoring-kube-prometheus-alertmanager-0 -n monitoring -c alertmanager # Username and Password not accepted
$ kubectl get pod # cpu-test => CrashLoopBackOff => 5times => KubernetesPodCrashLooping Firing & send mail
# Prometheus sends alert => Alertmanager => Check Labels: monitorings, alertname.. => send the mail to receiver.

// Lesson-258 ( Monitor 3rd Party Redis Application )
# Exporter gets metrics data from service(redis) => translates to prometheus understandable metrics to /metrics endpoint.
# ServiceMonitor needs to deployed with Exporter.

// Lesson-259 ( Monitor 3rd Party Redis Application - Part 2 )
# redis-cart <-- redis-exporter(/metrics) <-- pull metrics to Prometheus Server --> push metrics to Alertmanager
# https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-redis-exporter

$ kubectl get servicemonitor -n monitoring
$ kubectl get servicemonitor -n monitoring monitoring-kube-prometheus-alertmanager -o yaml | less # check release:monitoring labels

$ kubectl get svc | grep redis
$ kubectl get pod # check redis

# Install Helm Chart for Redis-exporter
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo add stable https://charts.helm.sh/stable
$ helm repo update

$ helm install redis-exporter prometheus-community/prometheus-redis-exporter -f redis-values.yaml

# New Documentation:
# helm install redis-exporter oci://ghcr.io/prometheus-community/charts/prometheus-redis-exporter

$ helm ls
$ kubectl get pod # check redis-exporter
$ kubectl get servicemonitor # check redis-exporter-prometheus-redis-exporter
$ kubectl get servicemonitor redis-exporter-prometheus-redis-exporter -o yaml | less  # check labels: release: monitoring # check spec: endpoints: - targetPort: 9121
# 127.0.0.1:9090/targets => serviceMonitor/default/redis-exporter-prometheus-redis-exporter
# Go to home page => secrchbox: redis metrics available

// Lesson-260 ( Alerting and Grafana Dashboard for Redis )
# Redis is down or too many connections
$ kubectl apply -f redis-rules.yaml
$ kubectl get prometheusrule # check redis-rules exist
# 127.0.0.1:9090/alerts => new redis.rules => RedisDown, RedisTooManyConnections

# Trigger redis down alert
$ kubectl get pod
$ kubectl edit deployment redis-cart # set spec: replicas: 0 => :wq
$ kubectl get pod # check redis-cart down or not
# redis-exporter get the metrics redis-cart not available # wait # serviceMonitor: interval: 30s then firing
# alertmanager is configured to send this alert to receiver
$ kubectl edit deployment redis-cart # set spec: replicas: 1 => :wq

# Create Redis Dashboard in Grafana
# localhost:8080/dashboard/import => ID: 763 => Load => Name: Redis Exporter Dashboard => General Folder => Prometheous data source => Import
$ kubectl describe svc redis-exporter-prometheus-redis-exporter # Endpoints: 192.168.89.60:9121 => Dashboard Instance:192.168.89.60:9121 => Last 3 hours => hover: PromQL

// Lesson-261 ( Monitor own application - Part 1 )
# Monitor Resource Consumption on the nodes(cluster nodes)
# Monitor Kubernetes components
# Monitor Prometheus Stack
# Monitor Third-Party Application(Redis)
# Monitor own application(Nodejs App) # No exporter available for metrics

# Choose a Prometheus client library according to language(python, java, nodejs) => abstract interface to expose your metrics
# Libraries implement the Prometheus metric types: Counter, Gauge, Histogram, Summary

# Expose metrics for our Nodejs application using Nodejs client library
# Deploy Nodejs in the cluster
# Configure Prometheus to scrape new target(ServiceMonitor)
# Visualize scraped metrics in Grafana Dashboard 
#### k8s_cluster(nodejs-app(/metrics) <= pull metrics == Prometheus Server <= query metrics == Grafana)

$ node app/server.js => localhost:3000
# nodejs <= Browser # two metrics: number of requests, duration of requests(if slow response)
# using "prom-client" dependencies in package.json, configure above two metrics

# Build Docker Image & Push to private Docker repository dockerhub
$ docker build -t shuvo83qn:demo-app:nodeapp .
$ docker login # Username & Password
$ docker push shuvo83qn:demo-app:nodeapp

# For CI/CD pipeline, push code to git repo => trigger a build => push to Docker repo 
# Deploy App(docker artifact) into k8s cluster
$ docker info # To get docker-registry url
$ kubectl create secret docker-registry my-registry-key --docker-server=https://index.docker.io/v1/ --docker-username=shuvo83qn --docker-password=your_docker_password
# secret/my-registry-key created
$ kubectl apply -f k8s-config.yaml # deployment.apps/nodeapp created, service/nodeapp created
$ kubectl get pod # nodeapp.., redis-exporter-prometheus...
$ kubectl get svc # kubernetes, nodeapp, redis-exporter-prometheus..

$ kubectl port-forward svc/nodeapp 3000:3000 # Cluster IP:PORT => 10.100.229.99:3000 forward to localhost:3000
# check 127.0.0.1:3000/metrics

// Lesson-262 ( Configure Prometheus Server to scrape nodejs-app(/metrics) endpoint )
# ServiceMonitor actually tells prometheus this is the endpoints: "/metrics" you need to scrape
# localhost:9090/targets => check currently registered targets
$ kubectl apply -f k8s-config.yaml # check serviceMonitor/default/monitoring-node-app => new target => http_request_operations_total metrics available
# localhost:9090/config => scrape_config: - job_name: serviceMonitor/default/monitoring-node-app/0 => newly created

# Create new Grafana Dashboard:
# localhost:8080 => Create => Dashboard => Add an empty panel => PromQL => rate(http_request_operations_total[2m]) => Way to Dashboard name: Node App Telemetry => Save => Request Per Second label
# Add another panel: PromQL: rate(http_request_duration_seconds_sum[2m]) => Request duration for incoming request

