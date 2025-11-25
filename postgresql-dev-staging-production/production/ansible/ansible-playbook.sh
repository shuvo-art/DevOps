# ============================================================================
# ANSIBLE: Infrastructure as Code for Database Management
# ============================================================================

# Run Ansible playbook
ansible-playbook ansible-postgres.yml -i inventory.ini

# ============================================================================
# DEVOPS WORKFLOW SUMMARY
# ============================================================================

# 1. LOCAL DEVELOPMENT (Docker)
docker-compose up -d  # PostgreSQL + Application

# 2. STAGING (Kubernetes)
kubectl apply -f k8s-postgres-pv.yaml
kubectl apply -f k8s-app-deployment.yaml

# 3. PRODUCTION (AWS RDS + EKS)
terraform apply  # Deploy RDS
kubectl apply -f k8s-app-deployment.yaml  # Deploy app connecting to RDS

# 4. MONITORING
# Prometheus scrapes postgres-exporter metrics
# Grafana visualizes dashboards
# CloudWatch logs for RDS

# 5. CI/CD PIPELINE (Jenkins)
# Build → Test → Push to ECR → Deploy to EKS → Connect to RDS