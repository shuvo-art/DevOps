provider "aws" {
    //region = "eu-west-3"
    // access_key = "AKJLKSOEIOWESDJFLKDI"
    // secret_key = "dkajla+KSkdsklfsowe897sdjfksd"
}

variable "cidr_blocks" {
    description = "subnet cidr block"
    type = list(string)
}

variable "cidr_blocks" {
    description = "subnet cidr blocks and name tags for vpc and subnets"
    type = list(object({
        cidr_block = string
        name = string
    }))
}

variable avail_zone {}

variable "subnet_cidr_block" {
    description = "subnet cidr block"
    default = "10.0.10.0/24"
    type = string
}

variable "vpc_cidr_block" {
    description = "vpc cidr block"
}

variable "environment" {
    description = "deployment environment"
}

resource "aws_vpc" "development-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name: var.cidr_blocks[0].name,
        vpc_env: "dev"
    }
}

resource "aws_vpc" "development-vpc" {
    cidr_block = var.cidr_blocks[0]
    tags = {
        Name: var.environment,
        vpc_env: "dev"
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: var.cidr_blocks[1].name
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = "eu-west-3a"
    tags = {
        Name: var.cidr_blocks[1].name
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.cidr_blocks[1]
    availability_zone = "eu-west-3a"
    tags = {
        Name: "subnet-1-dev"
    }
}

data "aws_vpc" "existing_vpc" {
    default = true  
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "eu-west-3a"
    tags = {
        Name: "subnet-2-default"
    }
}

output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
    value = aws_subnet.dev-subnet-1.id
}