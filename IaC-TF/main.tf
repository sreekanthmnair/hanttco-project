
#Define the Resource creations 

# VPC Creation
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# Public Subnet Creation
resource "aws_subnet" "public" {
  for_each = tomap(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-Pub-Sub-${each.key}"
    Project = var.project_name
  }
}

# Private Subnet Creation
resource "aws_subnet" "private" {
  for_each = tomap(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    Name = "${var.project_name}-Priv-Sub-${each.key}"
    Project = var.project_name
  }
}

# Internet Gateway Creation
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-internet-gateway"
    Project = var.project_name
  }
}

# Route Table creation for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # internet-bound traffic Route to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
    Project = var.project_name
  }
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Reserve an Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
    Project = var.project_name
  }
}

# NAT Gateway in Public Subnet and assign reserved elastic ip
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["us-east-1a"].id 

  tags = {
    Name = "${var.project_name}-nat-gateway"
    Project = var.project_name
  }
}


# Route Table for Public Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Route to the Local Traffic to Nat Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-route-table"
    Project = var.project_name
  }
}

# Associate Route Table with Private  Subnets
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Extract Public Subnet ID for EC2

output "public_subnet_ids" {
  value = tomap({ for key, subnet in aws_subnet.public : key => subnet.id })
}

#EC2 Resource creation along with Security group

# Security Group Creation in VPC

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_security_group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  # Inbound rules to allow SSH from Anywhere, (restrict for production, Define only Corporate subnets here)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # Inbound rules to allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules to Allow all outbound traffic 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2 Security Group"
    Project = var.project_name
  }
}

# EC2 Instance Creation

resource "aws_instance" "ec2_hantt" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public["us-east-1a"].id 
  key_name      = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # Associate with Security Group
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

 user_data = templatefile("${path.module}/templates/user_data.tpl", {
    instance_name = var.instance_name
  })

  tags = {
    Name = "${var.project_name}-ubuntu"
    Project = var.project_name
  }
}