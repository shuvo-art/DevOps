# ============================================================================
# APPROACH 1: PostgreSQL as Docker Container (Development)
# ============================================================================

# Step 1: Create Docker volume for persistent storage
sudo docker volume create postgres_data

# Step 2: Run PostgreSQL container
sudo docker run -d \
  --name postgres \
  --restart unless-stopped \
  -e POSTGRES_DB=myapp_db \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=SecurePassword123 \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:15-alpine

# Step 3: Verify container
sudo docker ps
sudo docker logs postgres