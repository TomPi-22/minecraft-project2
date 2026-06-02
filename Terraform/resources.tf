# AWS resources for the minecraft server
# Defines VPC, subnet, internet gw, route table, and instance resources
# Pulls variables decalred in Terraform/variables.tf

# Terraform providers and versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Standard resources below
provider "aws" {
  region = var.region
}

# Private key generation
resource "tls_private_key" "minecraft_server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Keeps private key in the SSM parameters for easy access
resource "aws_ssm_parameter" "minecraft_private_key" {
  name  = "/minecraft/private-key"
  type  = "SecureString"
  value = tls_private_key.minecraft_server_key.private_key_pem
  overwrite = true
}

# Create keypair on AWS using public key
resource "aws_key_pair" "minecraft_server_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.minecraft_server_key.public_key_openssh
}

# Instance VPC config
resource "aws_vpc" "minecraft_server_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "minecraft-server-vpc"
  }
}

# Subnet config
resource "aws_subnet" "minecraft_server_subnet" {
  vpc_id                  = aws_vpc.minecraft_server_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "minecraft-server-subnet"
  }
}

# Internet gateway config
resource "aws_internet_gateway" "minecraft_server_igw" {
  vpc_id = aws_vpc.minecraft_server_vpc.id
  tags = {
    Name = "minecraft-server-igw"
  }
}

# Route table config
resource "aws_route_table" "minecraft_server_routes" {
  vpc_id = aws_vpc.minecraft_server_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_server_igw.id
  }
  tags = {
    Name = "minecraft-server-routes"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "minecraft_server_rta" {
  subnet_id      = aws_subnet.minecraft_server_subnet.id
  route_table_id = aws_route_table.minecraft_server_routes.id
}

# Full instance config
resource "aws_instance" "minecraft_server" {
  ami                                  = var.ami_id
  instance_type                        = var.instance_type
  subnet_id                            = aws_subnet.minecraft_server_subnet.id
  vpc_security_group_ids               = [aws_security_group.minecraft_sg.id]
  key_name                             = aws_key_pair.minecraft_server_key.key_name
  associate_public_ip_address          = true
  instance_initiated_shutdown_behavior = "stop"

  depends_on = [aws_internet_gateway.minecraft_server_igw]

  tags = {
    Name = var.instance_name
  }
}
