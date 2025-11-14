# Configure the AWS Provider
provider "aws" {
    version = "~> 2.0"
    region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "example" {
    cidr_block = "10.0.0.0/16"
}

# Configure the Kubernetes Provider
provider "kubernetes" {
    config_context_auth_info = "ops"
    config_context_cluster   = "mycluster"
}

resource "kubernetes_namespace" "example" {
    metadata {
        name = "my-first-namespace"
    }
}

