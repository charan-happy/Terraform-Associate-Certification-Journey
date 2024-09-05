# configure AWS provider

provider "AWS" {
  region = "us-east-1"
}

# Retrieve the list of Az in the current AWS Region

data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# Define VPC 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
    Environment = "demo_environment"
    Terraform = "true"
  }
}

# private subnets deployments 

resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name = each.key
    Terraform = "true"
  }
}

# Deploy public subnets 

resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets
  vpc_id = aws_vpc.vpc.id 
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name = each.key
    Terraform = "true"
  }

}

# Deploy route tables for public and private subnets 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id 
  #natnat_gateway_id = aws_nat_gateway.nat_gateway.id 
  }
  tags = {
    Name = "demo_public_rtb"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id = aws_internet_gateway.internet_gateway.id 
    nat_gateway_id = aws_nat_gateway.nat_gateway.id 
}
    tags = {
        Name = "demo_private_rtb"
        Terraform = "true"
    }
}

# Create route table associataions 

resource "aws_route_table_association" "public" {
    depends_on = [aws_subnet.public_subnets]
    route_table_id = aws_route_table.public_route_table
    for_each = aws_subnet.public_subnets
    subnet_id = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table
  for_each = aws_subnet.private_subnets
  subnet_id = each.value.id
}

# create Internet Gateway 

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id 
  tags = {
    Name = "demo_igw"
  }
}

# Create EIP for NAT Gateway 

# Create NAT Gateway 

