output "load_balancer_dns" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.frontend_alb.dns_name
}

output "application_server_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "database_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres_db.endpoint
}

output "vpc_id" {
  description = "Main VPC ID"
  value       = aws_vpc.main_vpc.id
}
output "ec2_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.app_server.public_ip
}
