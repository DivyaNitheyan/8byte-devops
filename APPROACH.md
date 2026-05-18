# Approach Documentation

## Overview
This document explains the technical decisions and approach taken for the 8byte DevOps assignment.

## Infrastructure Approach (Terraform)

### Why Terraform
- Industry standard for infrastructure as code
- Declarative approach — define what you want, not how to get it
- State management ensures infrastructure is always in sync

### Why flat structure over modules
- Easier to read and understand for this scope
- Modules make sense when reusing infrastructure across multiple environments
- For a single environment flat structure is more transparent

### Why EC2 over ECS
- Simpler to manage and debug
- Easier to demonstrate in live demo
- ECS adds complexity with task definitions and clusters
- EC2 is sufficient for this application scope

### Why S3 for state management
- Centralized state accessible from any machine
- Versioning enabled for state history

### Network design
- ALB in public subnet — needs internet access
- EC2 in public subnet — needed for SSH deployment from GitHub Actions
- RDS in private subnet — database should never be publicly accessible
- Security groups follow least privilege — each resource only talks to who it needs to

## CI/CD Approach (GitHub Actions)

### Why GitHub Actions
- Native integration with GitHub repository
- No separate CI/CD server needed
- Free for public repositories

### Why Docker Hub over ECR
- Simpler setup — no AWS configuration needed for registry
- Free tier available
- ECR would be used in production for better security and integration

### Why Trivy for scanning
- Free and open source
- Scans both dependencies and container images
- Easy to integrate with GitHub Actions
- Industry standard tool

### Deployment via SSH
- Simple and straightforward
- EC2 is in public subnet so SSH is accessible

## Monitoring Approach

### Why Prometheus and Grafana
- Industry standard monitoring stack
- Prometheus for metrics collection
- Grafana for visualization
- Both are open source and free

### Why Loki for logging
- Native integration with Grafana
- Same query language as Prometheus

### Why Docker Compose for monitoring
- All monitoring services run together
- Easy to start and stop
- Single file defines entire monitoring stack