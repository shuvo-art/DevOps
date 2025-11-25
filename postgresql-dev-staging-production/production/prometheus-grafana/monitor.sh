# ============================================================================
# MONITORING: Prometheus + Grafana for Database Monitoring
# ============================================================================

# Install Prometheus PostgreSQL Exporter
sudo docker run -d \
  --name postgres-exporter \
  --restart unless-stopped \
  -e DATA_SOURCE_NAME="postgresql://admin:password@137.184.124.136:5432/myapp_db?sslmode=disable" \
  -p 9187:9187 \
  prometheuscommunity/postgres-exporter

# Add to Prometheus config
# prometheus.yml:
# - job_name: 'postgres'
#   static_configs:
#   - targets: ['localhost:9187']