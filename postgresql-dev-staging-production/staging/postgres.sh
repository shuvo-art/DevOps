# ============================================================================
# APPROACH 2: PostgreSQL on Kubernetes (Medium Scale - Better Reliability)
# ============================================================================

# Create namespace
kubectl create namespace database

# Step 1: Create PersistentVolume (PV) using k8s-postgres-pv.yaml

# Deploy to Kubernetes
kubectl apply -f k8s-postgres-pv.yaml
kubectl get pv
kubectl get pvc -n database
kubectl get pod -n database
kubectl logs -n database postgres-0