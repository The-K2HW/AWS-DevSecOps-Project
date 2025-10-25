# Secure Cloud Architecture for a Research Website  
*(Based on the AWS Cloud Architecting Capstone Project Website)*

---

## Overview

This project implements a secure, scalable, and high-availability 3-tier architecture on Amazon Web Services (AWS) to host a PHP-based research website that provides global development statistics.  

---

## Cloud Architecture

We adopted the 3-Tier Architecture pattern, which separates the system into distinct layers for security and maintainability:

| Tier | Components | Purpose |
|------|-------------|----------|
| Presentation Tier (Web) | Application Load Balancer (ALB), Bastion Host (Public Subnets) | Handles external HTTP traffic and administrative access |
| Application Tier (Logic) | EC2 Auto Scaling Group (Private Subnets), IAM Roles, Secrets Manager | Runs the PHP application securely and retrieves credentials dynamically |
| Data Tier (Storage) | Amazon RDS MySQL (Primary + Read Replica, Private Subnets) | Stores and replicates research data across multiple Availability Zones |

---

## Architecture Diagram

![AWS 3-Tier Architecture](./assets/Architecture.png.png)

**Key Components:**
- VPC (10.0.0.0/16): Isolated network for all AWS resources  
- Subnets:  
  - 2 Public (for ALB and Bastion Host)  
  - 2 Private (for EC2 Application Tier)  
  - 2 Private (for RDS Database Tier)  
- Internet Gateway: Enables public access through the ALB  
- Auto Scaling Group: Ensures elasticity and fault tolerance  
- Secrets Manager: Stores RDS credentials securely  
- CloudWatch and GuardDuty: Centralized monitoring and threat detection  
- IAM Roles: Enforce least-privilege access to AWS resources  

---

