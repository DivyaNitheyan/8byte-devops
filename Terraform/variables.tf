variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "devops"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  default = "t3.micro"
}

variable "db_name" {
  default = "devopsdb"
}

variable "db_username" {
  default = "dbuser"
}

variable "db_password" {
  sensitive = true
  default   = "Admin12345"
}