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

