# ============================================================================
# APPROACH 3: AWS RDS PostgreSQL (PRODUCTION - INDUSTRY STANDARD)
# ============================================================================

# This is the RECOMMENDED approach for production environments
# Why AWS RDS?
# - Managed service (AWS handles backups, patching, scaling)
# - Automated failover (Multi-AZ)
# - Read replicas for scaling
# - Automated backups and point-in-time recovery
# - Enhanced monitoring and security
# - Compliance and encryption built-in

# Create RDS using Terraform using ./terraform/postgres.tf

# Deploy RDS with Terraform
cd terraform/
terraform init
terraform plan
terraform apply

# ============================================================================
# APPROACH 4: Connect Kubernetes App to AWS RDS
# ============================================================================

# Create ConfigMap with RDS endpoint
kubectl create configmap postgres-config \
  --from-literal=POSTGRES_HOST=myapp-postgres-db.xxxxxx.us-east-1.rds.amazonaws.com \
  --from-literal=POSTGRES_PORT=5432 \
  --from-literal=POSTGRES_DB=myapp_db \
  -n default

# Create Secret with credentials from AWS Secrets Manager
kubectl create secret generic postgres-credentials \
  --from-literal=POSTGRES_USER=admin \
  --from-literal=POSTGRES_PASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id myapp/postgres/password \
    --query SecretString --output text) \
  -n default

# Use in Kubernetes deployment k8s-app-deployment.yaml

# Deploy application
kubectl apply -f k8s-app-deployment.yaml


