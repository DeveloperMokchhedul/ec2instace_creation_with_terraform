provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# VPC
resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "test_gw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test_gw"
  }
}

# Public Subnet
resource "aws_subnet" "test_pb_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "us-east-1a" # Change to your preferred AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "test_pb_subnet"
  }
}

# Route Table
resource "aws_route_table" "test_route" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_gw.id
  }

  tags = {
    Name = "test_route"
  }
}

# Route Table Association
resource "aws_route_table_association" "test_public_asso" {
  subnet_id      = aws_subnet.test_pb_subnet.id
  route_table_id = aws_route_table.test_route.id
}

# Security Group
resource "aws_security_group" "test_security_group" {
  name        = "test_security_group"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test_security_group"
  }
}

# EC2 Instance
resource "aws_instance" "server1" {
  ami                         = "ami-0705384c0b33c194c" # Use valid AMI for your region
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.test_pb_subnet.id
  vpc_security_group_ids      = [aws_security_group.test_security_group.id]
  associate_public_ip_address = true
  key_name                    = "your-key-name" # Replace with your SSH key

  tags = {
    Name = "server1"
  }
}
