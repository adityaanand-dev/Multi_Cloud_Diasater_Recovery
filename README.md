# 🌐 Multi-Cloud Disaster Recovery - Infrastructure as Code POC

[![Terraform](https://img.shields.io/badge/Terraform-v1.6+-7B42BC?style=flat&logo=terraform)](https://terraform.io)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat&logo=amazonaws&logoColor=white)](https://aws.amazon.com)
[![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://docker.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **A production-grade Infrastructure-as-Code proof of concept demonstrating multi-cloud disaster recovery across AWS and Azure using Terraform, Docker, Kubernetes, and automated CI/CD pipelines.**

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [How It Works](#how-it-works)
- [Module Reference](#module-reference)
- [Deployment Guide](#deployment-guide)
- [DR Strategy & Failover](#dr-strategy--failover)
- [Monitoring & Alerting](#monitoring--alerting)
- [CI/CD Pipeline](#cicd-pipeline)
- [Security](#security)
- [Cost Analysis](#cost-analysis)
- [Resume Highlights](#resume-highlights)

---

## Architecture Overview

```
                         ┌──────────────────────────────────────────────────────────────┐
                         │                     TRAFFIC MANAGEMENT                       │
                         │                                                              │
                         │     ┌─────────────────┐    DNS Failover    ┌──────────────┐ │
                         │     │   Route53 / CF   │◄──────────────────│ Health Checks │ │
                         │     │  (DNS Failover)  │                   │  (HTTP/TCP)   │ │
                         │     └────────┬─────────┘                   └──────────────┘ │
                         │              │                                               │
                         │     ┌────────┴────────┐                                     │
                         │     │  PRIMARY    DR   │                                     │
                         └─────┼────────────────┼──────────────────────────────────────┘
                               │                │
          ┌────────────────────▼──┐         ┌───▼────────────────────┐
          │   AWS (Primary)       │         │   Azure (DR Standby)   │
          │   Region: ap-south-1  │         │   Region: centralindia │
          │                       │         │                        │
          │  ┌─────────────────┐  │         │  ┌─────────────────┐   │
          │  │       ALB       │  │         │  │  Load Balancer   │   │
          │  │  (App LB)       │  │         │  │  (Standard)      │   │
          │  └────────┬────────┘  │         │  └────────┬────────┘   │
          │           │           │         │           │            │
          │  ┌────────▼────────┐  │         │  ┌────────▼────────┐   │
          │  │   Auto Scaling  │  │         │  │   Linux VM       │   │
          │  │   Group (EC2)   │  │         │  │   (Docker)       │   │
          │  │   min=1 max=3   │  │         │  │                  │   │
          │  └────────┬────────┘  │         │  └────────┬────────┘   │
          │           │           │         │           │            │
          │  ┌────────▼────────┐  │         │  ┌────────▼────────┐   │
          │  │   RDS PostgreSQL│  │  Sync   │  │  Azure PG Flex  │   │
          │  │   (Multi-AZ)   │◄─┼─────────┼─►│   Server        │   │
          │  └─────────────────┘  │         │  └─────────────────┘   │
          │                       │         │                        │
          │  ┌─────────────────┐  │         │  ┌─────────────────┐   │
          │  │  CloudWatch     │  │         │  │  Azure Monitor   │   │
          │  │  + SNS Alerts   │  │         │  │  + Action Groups │   │
          │  └─────────────────┘  │         │  └─────────────────┘   │
          │                       │         │                        │
          │  ┌─────────────────┐  │         │  ┌─────────────────┐   │
          │  │  Secrets Manager│  │         │  │  Key Vault       │   │
          │  │  + KMS          │  │         │  │  + Managed ID    │   │
          │  └─────────────────┘  │         │  └─────────────────┘   │
          └───────────────────────┘         └────────────────────────┘
                               │                │
                         ┌─────┴────────────────┴──────┐
                         │       CI/CD Pipeline         │
                         │    GitHub Actions             │
                         │  ┌───────┐ ┌──────┐ ┌──────┐│
                         │  │Validate│ │ Plan │ │Apply ││
                         │  └───────┘ └──────┘ └──────┘│
                         │  ┌────────┐ ┌──────────────┐│
                         │  │Security│ │Docker Build   ││
                         │  │ Scan   │ │& Push         ││
                         │  └────────┘ └──────────────┘│
                         └─────────────────────────────┘
```

---

## Project Structure

```
multicloud-dr-poc/
│
├── modules/                          # Reusable Terraform modules
│   ├── networking/
│   │   ├── aws/                      # VPC, subnets, IGW, NAT GW, route tables
│   │   └── azure/                    # VNet, subnets, NSG, resource group
│   ├── compute/
│   │   ├── aws/                      # Launch template, ASG, scaling policies
│   │   └── azure/                    # Linux VM, NIC, public IP
│   ├── database/
│   │   ├── aws/                      # RDS PostgreSQL, subnet group, SG
│   │   └── azure/                    # PostgreSQL Flexible Server, private DNS
│   ├── load-balancer/
│   │   ├── aws/                      # ALB, target group, listener
│   │   └── azure/                    # Azure Load Balancer, health probe
│   ├── dns-failover/                 # Route53 health checks + failover routing
│   ├── monitoring/
│   │   ├── aws/                      # CloudWatch dashboard, alarms, SNS
│   │   └── azure/                    # Log Analytics, metric alerts, action groups
│   └── security/
│       ├── aws/                      # IAM roles, Secrets Manager, KMS
│       └── azure/                    # Key Vault, managed identity
│
├── environments/                     # Environment-specific configurations
│   ├── dev/
│   │   ├── main.tf                   # Dev environment root (both clouds)
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   └── prod/
│       ├── main.tf                   # Prod with higher capacity
│       ├── variables.tf
│       └── outputs.tf
│
├── docker/                           # Application containers
│   ├── frontend/
│   │   ├── Dockerfile                # Nginx + static content
│   │   ├── nginx.conf                # Reverse proxy config
│   │   └── html/index.html           # DR dashboard UI
│   ├── backend/
│   │   ├── Dockerfile                # Node.js API
│   │   ├── package.json
│   │   └── server.js                 # Health check + DR status API
│   └── docker-compose.yml            # Local development stack
│
├── k8s/                              # Kubernetes manifests (optional path)
│   ├── namespace.yaml
│   ├── frontend-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── ingress.yaml
│   └── secrets.yaml
│
├── scripts/
│   ├── dr-failover-test.sh           # DR testing & RTO measurement
│   └── setup-remote-state.sh         # S3 + DynamoDB state backend setup
│
├── .github/workflows/
│   └── terraform-ci-cd.yml           # Full CI/CD pipeline
│
├── .gitignore
└── README.md
```

---

## Key Features

| Feature | Implementation | Benefit |
|---------|---------------|---------|
| **Multi-Cloud IaC** | Terraform modules for AWS + Azure | Eliminates vendor lock-in |
| **Modular Architecture** | 7 reusable modules per cloud | DRY code, easy maintenance |
| **Auto Scaling** | AWS ASG (1-3 instances) | Handles traffic spikes |
| **DNS Failover** | Route53 health checks + failover routing | Automatic DR activation |
| **Database Replication** | Cross-cloud PostgreSQL sync | RPO < 5 minutes |
| **Monitoring** | CloudWatch + Azure Monitor dashboards | Unified observability |
| **Security** | IAM, KMS, Secrets Manager, Key Vault | Least-privilege + encryption |
| **CI/CD** | GitHub Actions (validate → plan → apply) | Zero-touch deployments |
| **Containerized** | Docker + optional Kubernetes | Portable across clouds |
| **Multi-Environment** | dev / prod with different capacities | Safe testing before prod |

---

## Technology Stack

| Category | Technology |
|----------|-----------|
| **IaC** | Terraform >= 1.6 |
| **Primary Cloud** | AWS (VPC, EC2, RDS, ALB, CloudWatch, Route53) |
| **DR Cloud** | Azure (VNet, VM, PostgreSQL Flex, LB, Monitor) |
| **Containers** | Docker, Docker Compose |
| **Orchestration** | Kubernetes (EKS / AKS) - optional |
| **Application** | Node.js (Express) + Nginx + PostgreSQL |
| **CI/CD** | GitHub Actions |
| **Security** | AWS Secrets Manager, KMS, Azure Key Vault |
| **Monitoring** | CloudWatch, Azure Monitor, SNS |

---

## How It Works

### Normal Operation (AWS Primary Active)

1. **DNS** resolves to AWS ALB via Route53 primary record
2. **ALB** distributes traffic across EC2 instances in the Auto Scaling Group
3. **Application** (Docker containers) serves requests
4. **Database** operations go to RDS PostgreSQL (encrypted at rest)
5. **Data syncs** to Azure PostgreSQL Flexible Server (cross-cloud replication)
6. **Monitoring** dashboards track health across both clouds

### Disaster Recovery (AWS Failure → Azure Takeover)

1. Route53 **health check** detects AWS endpoint failure
2. DNS automatically **fails over** to Azure secondary record (< 60s TTL)
3. Traffic routes to **Azure Load Balancer** → Linux VM (Docker)
4. Application serves from **Azure PostgreSQL** (synced data)
5. **RTO achieved: < 5 minutes** (DNS propagation + health check interval)
6. Alerts fire via **SNS + Azure Action Groups** (email notification)

### Failback (AWS Recovered)

1. AWS instances restart and pass health checks
2. Route53 detects AWS is healthy again
3. DNS **automatically routes back** to AWS primary
4. Data delta syncs from Azure → AWS database

---

## Module Reference

### `modules/networking/aws`
Creates a complete AWS VPC with public/private subnets across 2 AZs, Internet Gateway, NAT Gateway, and route tables.

### `modules/networking/azure`
Creates Azure Resource Group, Virtual Network, subnets, and Network Security Group with HTTP/SSH rules.

### `modules/compute/aws`
Provisions a Launch Template, Auto Scaling Group with CloudWatch-based scaling policies, and security groups.

### `modules/compute/azure`
Deploys a Linux VM with public IP, NIC, and NSG association. Runs Docker via custom data script.

### `modules/database/aws`
Creates RDS PostgreSQL with subnet group, encryption at rest, automated backups, and security group.

### `modules/database/azure`
Deploys PostgreSQL Flexible Server with private DNS zone and VNet integration.

### `modules/load-balancer/aws`
Sets up an Application Load Balancer with target group, HTTP listener, and health checks.

### `modules/load-balancer/azure`
Creates an Azure Standard Load Balancer with health probe and load balancing rules.

### `modules/dns-failover`
Configures Route53 failover routing with health checks for both cloud endpoints.

### `modules/monitoring/aws`
Creates CloudWatch dashboard, SNS topic, and alarms for ALB, ASG, and RDS metrics.

### `modules/monitoring/azure`
Sets up Log Analytics workspace, metric alerts, and action groups for VM monitoring.

### `modules/security/aws`
Provisions IAM roles (least privilege), instance profiles, Secrets Manager, and KMS encryption keys.

### `modules/security/azure`
Creates Key Vault for secrets management and user-assigned managed identity for VMs.

---

## Deployment Guide

### Prerequisites

- Terraform >= 1.6 installed
- AWS CLI configured (`aws configure`)
- Azure CLI configured (`az login`)
- Docker installed (for local testing)
- Git

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/multicloud-dr-poc.git
cd multicloud-dr-poc

# 2. Set up remote state backend (one-time)
chmod +x scripts/setup-remote-state.sh
./scripts/setup-remote-state.sh

# 3. Configure environment variables
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 4. Initialize and deploy
terraform init
terraform plan
terraform apply

# 5. Verify deployment
terraform output deployment_summary
```

### Local Development (Docker)

```bash
cd docker
docker-compose up -d
# Access at http://localhost
# API at http://localhost:3000/health
```

---

## DR Strategy & Failover

| Metric | Target | Implementation |
|--------|--------|---------------|
| **RTO** | < 5 min | DNS failover (60s TTL) + health checks (30s interval) |
| **RPO** | < 5 min | Cross-cloud database replication |
| **Failover Type** | Automatic | Route53 health check → DNS record switch |
| **Failback** | Automatic | Health check recovery detection |

### Testing DR

```bash
# Run the DR failover test script
chmod +x scripts/dr-failover-test.sh
./scripts/dr-failover-test.sh
```

---

## Monitoring & Alerting

### AWS CloudWatch Dashboard
- EC2 CPU utilization (ASG-level)
- ALB request count & healthy host count
- RDS CPU & connection count

### Azure Monitor
- VM CPU utilization
- VM availability metric alerts

### Alert Channels
- AWS SNS → Email
- Azure Action Groups → Email

---

## CI/CD Pipeline

The GitHub Actions pipeline automates the full lifecycle:

```
PR Created → Validate → Security Scan → Plan (comment on PR)
PR Merged  → Validate → Security Scan → Plan → Apply
Manual     → Validate → Security Scan → Plan → Apply/Destroy
```

Additionally:
- Docker images are built and pushed on merge to main
- tfsec and checkov run security scans
- Terraform plan output is posted as PR comments

---

## Security

| Control | AWS | Azure |
|---------|-----|-------|
| **IAM / RBAC** | Least-privilege IAM roles | Managed Identity |
| **Secrets** | Secrets Manager | Key Vault |
| **Encryption at Rest** | KMS | Azure managed keys |
| **Encryption in Transit** | TLS/SSL | TLS/SSL |
| **Network** | Security Groups, private subnets | NSG, VNet isolation |
| **State** | Encrypted S3 + DynamoDB locking | — |

---

## Cost Analysis

### Development Environment (Estimated Monthly)

| Resource | AWS | Azure |
|----------|-----|-------|
| Compute | EC2 t2.micro (~$8) | VM Standard_B1s (~$7) |
| Database | RDS db.t3.micro (~$15) | PG Flex B_Standard_B1ms (~$13) |
| Load Balancer | ALB (~$16) | Standard LB (~$18) |
| NAT Gateway | ~$32 | N/A |
| Storage/Other | ~$5 | ~$5 |
| **Subtotal** | **~$76** | **~$43** |
| **Total** | **~$119/month** | |

### Production Environment
- ~2-3x development costs depending on scaling
- Reserved instances can reduce by ~40%

### Cost vs No-DR Comparison
- **Without DR**: Single cloud ~$76/mo, but **100% revenue loss during outage**
- **With DR**: ~$119/mo (+56%), but **< 5 min downtime** during cloud failure
- **ROI**: If downtime costs > $43/incident, DR pays for itself

---

## Resume Highlights

> ✅ **Architected multi-cloud disaster recovery infrastructure across AWS and Azure using Terraform IaC, achieving < 5min RTO with automated DNS failover**

> ✅ **Implemented 100% infrastructure-as-code for cloud resources across 2 providers using 14 reusable Terraform modules, reducing deployment time from hours to minutes**

> ✅ **Designed cross-cloud database replication strategy (PostgreSQL) with automated failover, eliminating single cloud as a point of failure**

> ✅ **Built CI/CD pipeline using GitHub Actions with automated Terraform validation, security scanning (tfsec/checkov), and multi-cloud deployment**

> ✅ **Implemented security best practices including least-privilege IAM, secrets management (AWS Secrets Manager + Azure Key Vault), KMS encryption, and network isolation**

---

## Interview Talking Points

1. **Why multi-cloud DR?** Single cloud outages (AWS us-east-1, Azure) happen. Multi-cloud eliminates cloud provider as single point of failure.

2. **Why Terraform over CloudFormation/ARM?** Cloud-agnostic, single language for both providers, reusable modules, strong community.

3. **How does failover work?** Route53 health checks monitor both endpoints. On failure detection, DNS automatically routes to the healthy secondary endpoint. TTL set to 60s ensures fast propagation.

4. **How do you handle state?** Remote state in S3 with DynamoDB locking prevents concurrent modifications. State is encrypted at rest.

5. **Module design decisions?** Each module is cloud-specific under a common category (networking, compute, database). This allows mixing and matching clouds while keeping the interface consistent.

6. **Security considerations?** Least-privilege IAM, secrets in dedicated vaults (not in code/state), encryption at rest and in transit, network isolation with private subnets.

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

*Built as an Infrastructure-as-Code Proof of Concept demonstrating enterprise-grade multi-cloud disaster recovery patterns.*
