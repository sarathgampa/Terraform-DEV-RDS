terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.61.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc-cdir
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "my-pubsubnet1" {
  cidr_block        = var.subnet-cdir[0]
  availability_zone = var.azs[0]
  vpc_id            = aws_vpc.myvpc.id
  tags = {
    Name = "${var.env}-pub-subnet1"
  }
}

resource "aws_subnet" "my-privsubnet1" {
  cidr_block        = var.subnet-cdir[1]
  availability_zone = var.azs[1]
  vpc_id            = aws_vpc.myvpc.id
  tags = {
    Name = "${var.env}-priv-subnet1"
  }
}

resource "aws_subnet" "my-privsubnet2" {
  cidr_block        = var.subnet-cdir[2]
  availability_zone = var.azs[2]
  vpc_id            = aws_vpc.myvpc.id
  tags = {
    Name = "${var.env}-priv-subnet2"
  }
}
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-pub-rt" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route" "r-int" {
  route_table_id         = aws_route_table.my-pub-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my-igw.id
}

resource "aws_route_table_association" "pubsunet-rt-assc" {
  subnet_id      = aws_subnet.my-pubsubnet1.id
  route_table_id = aws_route_table.my-pub-rt.id
}
resource "aws_security_group" "sg" {
  name        = "allow_ssh_http"
  description = "Allows port 22 and 80"
  vpc_id      = aws_vpc.myvpc.id
}

resource "aws_security_group_rule" "sg-ig-ssh" {
  type              = "ingress"
  from_port         = 0
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "sg-ig-http" {
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_security_group_rule" "sg-eg-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}

resource "aws_instance" "web-Server" {
  ami               = "ami-0a23ccb2cdd9286bb"
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.my-privsubnet1.id
  availability_zone = var.azs[1]
  security_groups   = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF

  tags = {
    Name = "web_instance"
  }

  volume_tags = {
    Name = "web_instance"
  }
}
