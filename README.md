# Cloud Solutions Inc. - Infrastructure as Code <!-- omit in toc -->

Production-ready AWS infrastructure for Cloud Solutions Inc., deployed using Terraform and Amazon EKS with a modern two-pipeline architecture.

## Table of Contents <!-- omit in toc -->

- [Quick Links](#quick-links)
- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Quick Start](#quick-start)
- [Security](#security)
- [Modules](#modules)
- [Outputs](#outputs)
- [Cleanup](#cleanup)
- [License](#license)


## Quick Links

- [ARCHITECTURE](docs/ARCHITECTURE.md) - Infrastructure components and design decisions
- [ARGOCD](docs/ARGOCD.md) - ArgoCD deployment and access guide
- [AWS LOAD BALANCER CONTROLLER](docs/ALB_CONTROLLER.md) - ALB/NLB controller documentation
- [BOOTSTRAP](docs/BOOTSTRAP.md) - Remote state backend setup
- [CICD](docs/CICD.md) - CI/CD pipeline documentation
- [DISCLAIMER](docs/DISCLAIMER.md) - Important notes about the use of AI tools and development process
- [EKS](docs/EKS.md) - EKS deployment, configuration, and operations
- [EXAMPLES](docs/EXAMPLES.md) - Sample application deployment examples
- [KUBERNETES](docs/KUBERNETES.md) - Kubernetes infrastructure deployment
- [TERRAFORM](docs/TERRAFORM.md) - Terraform module and variable reference

## Features

- **Two-Pipeline Architecture**: Separate infrastructure and Kubernetes resource deployments
- **Multi-environment**: Separate configurations for development, staging, and production
- **EKS Cluster**: Managed Kubernetes 1.34 with auto-scaling node groups
- **Multi-AZ**: High availability across 3 availability zones
- **End-to-End Encryption**: KMS-encrypted secrets and EBS volumes, TLS in transit
- **Network Isolation**: Private subnets for workloads, VPC Flow Logs
- **Storage**: EFS for shared storage, EBS CSI driver
- **Monitoring**: CloudWatch logs, metrics dashboard, SNS alerts
- **CI/CD**: Automated GitHub Actions workflows with two-stage deployment
- **GitOps**: ArgoCD for declarative application deployment
- **IRSA**: IAM Roles for Service Accounts with OIDC provider
- **Custom Helm Charts**: Professional wrapper charts for better maintainability

## Architecture Overview

This project uses a **two-pipeline, two-state architecture** for better separation of concerns:

```
┌───────────────────────────────────┐
│  Pipeline 1: terraform-deploy     │
│  Infrastructure Layer             │
│  - VPC, EKS, IAM                  │
│  - KMS, EFS, ALB, CloudWatch      │
│  State: {env}/infra/tfstate       │
└──────────────┬───────────────────-┘
               │
               │ triggers on success
               ▼
┌───────────────────────────────────┐
│  Pipeline 2: kubernetes-deploy    │
│  Kubernetes Resources Layer       │
│  - AWS Load Balancer Controller   │
│  - ArgoCD                         │
│  State: {env}/kubernetes/tfstate  │
└───────────────────────────────────┘
```

**Benefits:**
- ✅ Separation of infrastructure and applications
- ✅ Independent deployments and rollbacks
- ✅ Reduced blast radius for changes
- ✅ Follows HashiCorp best practices

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed information.

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/your-username/cloud-solutions-inc.git
cd cloud-solutions-inc
```

### 2. Create Terraform State Bucket

```bash
./scripts/bootstrap-terraform-backend.sh
```

Or with custom settings:

```bash
export TF_STATE_BUCKET="my-terraform-state"
export AWS_REGION="eu-west-1"
./scripts/bootstrap-terraform-backend.sh
```

### 3. Configure Variables

Create `environments/production/terraform.tfvars`:

```hcl
aws_region         = "eu-west-1"
environment        = "production"
project_name       = "cloud-solutions"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# EKS Configuration
kubernetes_version  = "1.34"
node_instance_types = ["t3.medium"]
capacity_type       = "ON_DEMAND"
node_disk_size      = 20

# Scaling
desired_size = 2
min_size     = 1
max_size     = 4

# Optional: Email alerts
# alarm_email = "ops@cloudsolutions.com"
```

### 4a. Manual Deploy - Infrastructure

```bash
# Deploy infrastructure layer
terraform init -backend-config="environments/production/tfbackend.hcl"
terraform plan -var-file="environments/production/terraform.tfvars"
terraform apply -var-file="environments/production/terraform.tfvars"
```

### 4b. Manual Deploy - Kubernetes Resources

```bash
# Deploy Kubernetes resources
cd kubernetes
terraform init -backend-config="environments/production/tfbackend.hcl"
terraform plan -var-file="environments/production/terraform.tfvars"
terraform apply -var-file="environments/production/terraform.tfvars"
```

### 4c. Automated Deploy via CI/CD

Automated deployments via GitHub Actions on `main` branch push. The deployment happens in two stages:

1. **terraform-deploy**: Deploys infrastructure (VPC, EKS, etc.)
2. **kubernetes-deploy**: Deploys Kubernetes resources (triggered automatically on success)

Required secrets:
- `AWS_ROLE_ARN`

Required variables:
- `AWS_REGION`
- `TF_VERSION`

See [CICD.md](docs/CICD.md) for detailed information.


## Security

All data encrypted at rest (KMS for secrets/EBS) and in transit (TLS 1.2+). Key features:

- Customer-managed KMS keys with automatic rotation
- IMDSv2 enforced on all EC2 instances
- Network isolation with security groups
- VPC Flow Logs for auditing
- IRSA for pod-level IAM permissions
- Separate IAM roles for infrastructure and Kubernetes resources

View encryption keys:
```bash
terraform output eks_kms_key_id
terraform output ebs_kms_key_id
```

See [ARCHITECTURE.md](docs/ARCHITECTURE.md#security-features) for comprehensive security documentation.

## Modules

This project is organized into two main layers:

### Infrastructure Layer (Root)
- **kms**: Encryption key management
- **vpc**: Network infrastructure
- **eks**: EKS cluster and node groups
- **alb**: Security groups for load balancers
- **efs**: Shared file system
- **cloudwatch**: Monitoring and logging

### Kubernetes Layer (kubernetes/)
- **Custom Charts**: Helm chart wrappers for better maintainability
- **IAM Roles**: IRSA roles for Kubernetes service accounts
- **ArgoCD**: GitOps deployment from shared module

See [TERRAFORM.md](docs/TERRAFORM.md) for detailed module documentation.

## Outputs

### Infrastructure Layer Outputs

```bash
# Cluster information
terraform output eks_cluster_name
terraform output eks_cluster_endpoint
terraform output configure_kubectl

# Security
terraform output eks_kms_key_id
terraform output ebs_kms_key_id

# OIDC for IRSA
terraform output eks_oidc_provider
terraform output eks_oidc_provider_arn

# Sensitive outputs
terraform output -raw eks_cluster_arn
```

### Kubernetes Layer Outputs

```bash
cd kubernetes

# ArgoCD information
terraform output argocd_namespace
terraform output argocd_server_url

# Load Balancer Controller
terraform output aws_load_balancer_controller_role_arn
```

## Cleanup

**Important**: Delete resources in reverse order to avoid orphaned AWS resources.

```bash
# 1. Delete all Kubernetes-created AWS resources (while controllers are still running)
kubectl delete ingress --all --all-namespaces
kubectl delete svc --all --all-namespaces
kubectl delete pvc --all --all-namespaces

# 2. Delete Kubernetes resources (removes controllers and ArgoCD)
cd kubernetes
terraform destroy

# 3. Delete infrastructure (removes EKS cluster and VPC)
cd ..
terraform destroy
```

## License

This project is licensed under the [MIT License](LICENSE).

---

**Built with ❤️ for Cloud Solutions Inc.**
