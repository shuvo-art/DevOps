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
