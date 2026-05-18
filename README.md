# 8byte DevOps Assignment

## Overview
This project demonstrates a complete DevOps setup including infrastructure provisioning, CI/CD pipelines, and monitoring.

## Architecture
- **VPC** with public and private subnets across two availability zones
- **EC2** instance running nginx application in public subnet
- **RDS PostgreSQL** database in private subnet
- **ALB** load balancer in public subnets
- **S3** for Terraform state management

## Part 1 - Infrastructure Setup

### Prerequisites
- Terraform installed
- AWS CLI configured
- AWS account with appropriate permissions

### How to run
```bash
cd Terraform
terraform init
terraform plan
terraform apply
```

### Architecture decisions
- EC2 over ECS — simpler to manage and explain for this scope
- Flat Terraform structure over modules — more readable and easier to debug
- S3 backend for state — centralized and accessible from any machine
- EC2 in public subnet — allows direct deployment via SSH from CI/CD

### Security considerations
- RDS in private subnet — not accessible from internet
- Security groups restrict traffic — ALB to EC2 to RDS chain
- No hardcoded credentials — all sensitive values in variables
- SSH access restricted to deployment only

### Cost optimization
- t3.micro EC2 — free tier eligible
- db.t3.micro RDS — free tier eligible
- Single AZ deployment — reduces cost for non-production

## Part 2 - CI/CD Pipeline

### Pipeline flow
- PR created → CI runs — builds Docker image and scans with Trivy
- Merge to main → CD runs — builds, pushes to Docker Hub and deploys to EC2
- Production deployment requires manual approval

### How to trigger
- CI → create a PR to main branch
- CD staging → merge PR to main
- CD production → go to Actions tab and approve

## Part 3 - Monitoring

### Stack
- Prometheus — metrics collection
- Node Exporter — infrastructure metrics
- Loki — centralized logging
- Promtail — log shipping agent
- Grafana — visualization

### How to run monitoring
```bash
cd monitoring
docker compose up -d
```

### Dashboards
- Dashboard 1 — Node Exporter Full (ID: 1860) — CPU, memory, disk metrics
- Dashboard 2 — Logs Dashboard

### Accessing monitoring
- Grafana → http://EC2-IP:3000 (admin/admin)
- Prometheus → http://EC2-IP:9090

### Database metrics
- RDS metrics available via AWS CloudWatch automatically
- CPU, connections, storage monitored out of the box

## Part 4 - Security and Best Practices

### Secret management
- Database credentials stored in Terraform variables
- CI/CD secrets stored in GitHub Secrets
- In production — AWS Secrets Manager would be used

### Backup strategy
- RDS automated snapshots enabled
- S3 bucket versioning enabled for state file history

## Challenges faced

1. **SSM agent not working on private subnet EC2**
   - Problem: GitHub Actions couldn't connect to EC2 via SSM
   - Reason: EC2 in private subnet has no internet access to reach SSM endpoints
   - Resolution: Moved EC2 to public subnet and used SSH for deployment

2. **Docker not available on Ubuntu AMI**
   - Problem: `docker.io` package not found on Ubuntu
   - Reason: Ubuntu uses different package repository
   - Resolution: Installed `docker-ce` from Docker's official repository

3. **Terraform state locked in S3**
   - Problem: State file conflict when switching between local and S3 backend
   - Resolution: Used `terraform init -migrate-state` to cleanly migrate state

4. **GitHub push failing due to large .terraform folder**
   - Problem: `.terraform` folder with 685MB provider binary was being pushed
   - Resolution: Cleaned git history using `git filter-branch` and added proper `.gitignore`

5. **RDS username conflict**
   - Problem: `admin` is a reserved word in PostgreSQL
   - Resolution: Changed username to `dbuser`

6. **Security group ingress type mismatch**
   - Problem: Used `cidr_blocks` instead of `security_groups` for EC2 and RDS ingress
   - Resolution: Changed to `security_groups` to reference ALB and EC2 security groups

7. **ALB showing 503 error**
   - Problem: ALB had no healthy targets
   - Resolution: Added `aws_lb_target_group_attachment` to register EC2 to target group

8. **Docker Hub authentication failing in CI**
   - Problem: Access token format was incorrect
   - Resolution: Regenerated token with Read & Write permissions

9. **SSH timeout in CD pipeline**
   - Problem: Port 22 was not open in EC2 security group
   - Resolution: Added SSH ingress rule to EC2 security group

10. **S3 bucket name conflict**
    - Problem: Bucket name was already taken globally
    - Resolution: Used unique bucket name with project prefix