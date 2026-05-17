terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.project_name}-public1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "${var.project_name}-public2"
  }
}
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.project_name}-private1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "${var.project_name}-private2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_name}-route_table"
  }
}
resource "aws_route_table_association" "route_public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "route_public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_security_group" "load_balancer" {
  name   = "alb-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ec2" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "rds" {
  name   = "rds-sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "devops" {
  ami             = "ami-091138d0f0d41ff90"
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private1.id
  security_groups = [aws_security_group.ec2.id]
  key_name        = "practice"
  tags = {
    Name = "${var.project_name}-ec2"
  }
}
resource "aws_db_subnet_group" "subnets" {
  name       = "subnet_group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}
resource "aws_db_instance" "rds" {
  instance_class         = "db.t3.micro"
  engine                 = "postgres"
  engine_version         = "14"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.subnets.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  tags = {
    Name = "${var.project_name}-db"
  }
}
resource "aws_lb" "lb" {
  name               = "devops-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}
resource "aws_lb_target_group" "target_group" {
  name     = "devops-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.devops.id
  port             = 80
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "8byte-devops-terraform-state"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}
