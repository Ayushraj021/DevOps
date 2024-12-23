terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.0"
    }
  }

  backend "s3" {
    bucket = "abcddiuwhdu"
    key    = "terraform/state/terraform.tfstate"
    region = "ap-south-1"
  }
}

# AWS provider configuration
provider "aws" {
  region = "ap-south-1"
}

# Generate a key pair using the TLS provider
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

# Create a local file to save the private key
resource "local_file" "private_key_pair" {
  content  = tls_private_key.generated.private_key_pem
  filename = "${path.module}/ec2_private_key.pem"
}

# Local block
locals {
  env = "prod"
}

# Create a VPC
resource "aws_vpc" "one" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${local.env}-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "one" {
  cidr_block = "10.0.0.0/24"
  vpc_id     = aws_vpc.one.id
  tags = {
    Name = "${local.env}-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "two" {
  vpc_id = aws_vpc.one.id
  tags = {
    Name = "${local.env}-gateway"
  }
}

# Create a route table
resource "aws_route_table" "three" {
  vpc_id = aws_vpc.one.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.two.id
  }

  tags = {
    Name = "${local.env}-route-table"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.one.id
  route_table_id = aws_route_table.three.id
}

# Create an EC2 instance
resource "aws_instance" "fourth" {
  subnet_id      = aws_subnet.one.id
  ami            = "ami-078264b8ba71bc45e"
  instance_type  = "t2.micro"
  key_name       = "devops"
  tags = {
    Name = "${local.env}-instance"
  }
}

# Output the private key for reference (Optional)
output "private_key_pem" {
  value     = tls_private_key.generated.private_key_pem
  sensitive = true
}

# Local file resource to save the private key (Optional)
resource "local_file" "private_key" {
  content  = tls_private_key.generated.private_key_pem
  filename = "${path.module}/ec2_private_key.pem"
}
