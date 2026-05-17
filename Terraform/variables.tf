variable "aws_region" {
  description = "AWS region for infrastructure deployment"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource tagging"
  default     = "devops-demo"
}

variable "vpc_cidr" {
  description = "CIDR block for main VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "db_name" {
  description = "RDS database name"
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  default     = "adminuser"
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
  default     = "admin12345"
}