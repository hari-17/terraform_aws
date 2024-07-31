variable "access_key"{
  description = "value of access key"
  type =string
}
variable "secret_key" {
    description = "value of secret key"
  type =string

}

provider "aws" {
  region = "us-east-2"
 
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraformVPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "TerraformIGW"
  }
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "TerraformRT"
  }
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "TerraformSubnet"
  }
}

# Subnet Route Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# Security Group
resource "aws_security_group" "web" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TerraformSG"
  }
}

# EC2 Instance
resource "aws_instance" "example" {
  ami           = "ami-0a31f06d64a91614b" # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name      = "terraform" # Replace with your key pair name

  subnet_id              = aws_subnet.main.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install  httpd -y
    sudo chmod 777 /var/www/html -R
    aws configure set aws_access_key_id ${var.access_key}
    aws configure set aws_secret_access_key ${var.secret_key}
    aws configure set default.region us-west-2
    aws s3 cp s3://harihari-unique-bucket-name/index.html /var/www/html/index.html
    service httpd start
    EOF

  tags = {
    Name = "web-instance"
  }
}

output "ec2_public_ip" {
  value = aws_instance.example.public_ip
}

module "s3_bucket" {
  source         = "./s3_bucket"
  bucket_name    = "harihari-unique-bucket-name"
  region         = "us-east-2"
  
}



output "output_from_child" {
  value = var.access_key
}

