provider "aws" {
  region = "us-east-1"
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "postgres-subnet-group"
  }
}

# Create Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name   = "postgres-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "postgres-rds-sg"
  }
}

# Create RDS Instance
resource "aws_db_instance" "postgres" {
  identifier           = "myapp-postgres-db"
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp3"
  
  db_name              = "myapp_db"
  username             = "admin"
  password             = random_password.db_password.result
  
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  # High Availability
  multi_az             = true
  
  # Backups
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  # Security
  storage_encrypted    = true
  kms_key_id           = aws_kms_key.rds_key.arn
  
  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  
  # Performance Insights
  performance_insights_enabled = true
  
  # Backup
  skip_final_snapshot = false
  final_snapshot_identifier = "myapp-postgres-final-snapshot"
  
  tags = {
    Name = "myapp-postgres-db"
  }

  depends_on = [aws_security_group.rds_sg]
}

# Generate random password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "myapp/postgres/password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# Output RDS endpoint
output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS PostgreSQL endpoint"
}