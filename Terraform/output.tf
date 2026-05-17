output "alb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "ec2_instance_id" {
  value = aws_instance.devops.id
}

output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}