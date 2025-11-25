# Ansible Collections & Project Organization

## Collection Directory Structure

Ansible Collections follow a standardized directory structure for organizing playbooks, roles, modules, and plugins.

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

## Collection Metadata (galaxy.yml)

```yaml
# filepath: collection/galaxy.yml
namespace: myorganization
name: myproject
version: 1.0.0
readme: README.md
authors:
  - Your Name <your.email@example.com>
description: Custom collection for infrastructure automation
license:
  - Apache-2.0
tags:
  - docker
  - kubernetes
  - aws
  - database
repository: https://github.com/myorg/ansible-collection
documentation: https://github.com/myorg/ansible-collection
issues: https://github.com/myorg/ansible-collection/issues
```

## Key Components Explained

### 1. **Roles** - Reusable automation units
```
roles/
├── docker-setup/              # Role for Docker installation
├── jenkins-deploy/            # Role for Jenkins deployment
├── postgres-setup/            # Role for PostgreSQL
├── kubernetes-cluster/        # Role for K8s cluster
└── monitoring-stack/          # Role for Prometheus & Grafana
```

Each role contains:
- `tasks/` - Main tasks to execute
- `handlers/` - Event handlers
- `templates/` - Jinja2 configuration templates
- `files/` - Static files to copy
- `vars/` - Role-specific variables
- `defaults/` - Default variables
- `meta/` - Role dependencies

### 2. **Playbooks** - Orchestration workflows
```yaml
# filepath: playbooks/site.yml
---
- name: Deploy Complete Infrastructure
  hosts: all
  become: yes
  
  pre_tasks:
    - name: Update system packages
      apt:
        update_cache: yes
        cache_valid_time: 3600

  roles:
    - docker-setup
    - jenkins-deploy
    - postgres-setup
    - kubernetes-cluster

  post_tasks:
    - name: Verify deployment
      debug:
        msg: "Infrastructure deployed successfully"
```

### 3. **Inventory Management**
```ini
# filepath: inventory/hosts
[docker_servers]
docker-host-1 ansible_host=10.0.1.10
docker-host-2 ansible_host=10.0.1.11

[database_servers]
db-primary ansible_host=10.0.2.10
db-replica ansible_host=10.0.2.11

[k8s_masters]
k8s-master-1 ansible_host=10.0.3.10
k8s-master-2 ansible_host=10.0.3.11

[k8s_workers]
k8s-worker-1 ansible_host=10.0.3.20
k8s-worker-2 ansible_host=10.0.3.21

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/ansible.pem
ansible_python_interpreter=/usr/bin/python3
```

### 4. **Variables Organization**
```yaml
# filepath: vars/common.yml
---
# Common variables used across all environments
docker_version: "24.0.0"
kubernetes_version: "1.28.0"
postgresql_version: "15"

# filepath: vars/production.yml
---
# Production-specific variables
environment: production
replicas: 3
enable_monitoring: true
backup_retention_days: 30
```

### 5. **Templates** - Configuration management
```jinja2
# filepath: templates/nginx.conf.j2
server {
    listen {{ nginx_port }};
    server_name {{ server_hostname }};
    
    location / {
        proxy_pass http://{{ backend_host }}:{{ backend_port }};
    }
}
```

## Collection Management Commands

```bash
# List installed collections
ansible-galaxy collection list

# Install collection from Galaxy
ansible-galaxy collection install amazon.aws

# Install specific version
ansible-galaxy collection install amazon.aws:==5.0.0

# Install from requirements file
ansible-galaxy collection install -r requirements.yml

# Create new collection
ansible-galaxy collection init myorganization.myproject

# Build collection for distribution
ansible-galaxy collection build

# Publish to Galaxy (after login)
ansible-galaxy collection publish
```

## Playbook Execution

```bash
# Run playbook with inventory
ansible-playbook -i inventory/hosts playbooks/site.yml

# Run specific playbook in specific environment
ansible-playbook -i inventory/hosts_prod playbooks/deploy.yml

# Dry-run (check mode)
ansible-playbook -i inventory/hosts playbooks/site.yml --check

# Run with verbose output
ansible-playbook -i inventory/hosts playbooks/site.yml -vvv

# Run specific tags only
ansible-playbook -i inventory/hosts playbooks/site.yml --tags docker

# Run playbook on specific hosts
ansible-playbook -i inventory/hosts playbooks/site.yml -l docker_servers
```

## Best Practices

1. **Use Collections** - Organize code into reusable collections
2. **Version Control** - Maintain galaxy.yml versions
3. **Role Dependencies** - Declare dependencies in meta/main.yml
4. **Variable Hierarchy** - Follow precedence: defaults → vars → inventory → extra
5. **Testing** - Include test playbooks for validation
6. **Documentation** - Maintain comprehensive README files
7. **Idempotency** - Ensure tasks are idempotent
8. **Handlers** - Use handlers for restart/reload events
9. **Facts Gathering** - Cache facts for performance
10. **Error Handling** - Implement proper error handling with blocks

## Integration with CI/CD

```yaml
# filepath: playbooks/deploy.yml
---
- name: Deploy to Production
  hosts: production
  vars:
    deployment_version: "{{ lookup('env', 'CI_COMMIT_SHA') }}"
  
  roles:
    - { role: docker-setup, tags: [docker] }
    - { role: app-deploy, tags: [deploy] }
    - { role: health-check, tags: [verify] }
```

## Collection Publishing Workflow

1. Create collection structure
2. Develop roles and modules
3. Write documentation
4. Test playbooks
5. Version in galaxy.yml
6. Build: `ansible-galaxy collection build`
7. Publish: `ansible-galaxy collection publish`
8. Share via Ansible Galaxy Hub