# Cloud Solutions Inc. - Infrastructure as Code <!-- omit in toc -->

Production-ready AWS infrastructure for Cloud Solutions Inc., deployed using Terraform and Amazon EKS.

## Table of Contents <!-- omit in toc -->

- [Quick Links](#quick-links)
- [Features](#features)
- [Quick Start](#quick-start)
- [Security](#security)
- [Modules](#modules)
- [Outputs](#outputs)
- [Cleanup](#cleanup)
- [License](#license)


## Quick Links

- [ARCHITECTURE](docs/ARCHITECTURE.md) - Infrastructure components and design decisions
- [BOOTSTRAP](docs/BOOTSTRAP.md) - Remote state backend setup
- [DISCLAIMER](DISCLAIMER.md) - Important notes about the use of AI tools and development process
- [EKS](docs/EKS.md) - EKS deployment, configuration, and operations
- [TERRAFORM](docs/TERRAFORM.md) - Terraform module and variable reference

## Features

- **EKS Cluster**: Managed Kubernetes 1.31 with auto-scaling node groups
- **Multi-AZ**: High availability across 3 availability zones
- **End-to-End Encryption**: KMS-encrypted secrets and EBS volumes, TLS in transit
- **Network Isolation**: Private subnets for workloads, VPC Flow Logs
- **Storage**: S3 with lifecycle policies, EFS for shared storage, EBS CSI driver
- **Monitoring**: CloudWatch logs, metrics dashboard, SNS alerts
- **CI/CD**: GitHub Actions workflow for automated deployments
- **IRSA**: IAM Roles for Service Accounts with OIDC provider

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/your-username/cloud-solutions-inc.git
cd cloud-solutions-inc
```

### 2. Create Terraform State Bucket

```bash
./bootstrap-terraform-backend.sh
```

Or with custom settings:

```bash
export TF_STATE_BUCKET="my-terraform-state"
export AWS_REGION="eu-west-1"
./bootstrap-terraform-backend.sh
```

### 3. Configure Variables

Create `terraform.tfvars`:

```hcl
aws_region         = "eu-west-1"
environment        = "tech-challenge"
project_name       = "cloud-solutions"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# EKS Configuration
kubernetes_version  = "1.31"
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

### 4a. Manual Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4b. Automated Deploy

Automated deployments via GitHub Actions on `main` branch push. Customize workflow in `.github/workflows/deploy.yml`.

Required secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `TF_STATE_BUCKET`

See [CICD.md](docs/CICD.md) for more details.


## Security

All data encrypted at rest (KMS for secrets/EBS, AES-256 for S3) and in transit (TLS 1.2+). Key features:

- Customer-managed KMS keys with automatic rotation
- IMDSv2 enforced on all EC2 instances
- Network isolation with security groups
- VPC Flow Logs for auditing
- IRSA for pod-level IAM permissions

View encryption keys:
```bash
terraform output eks_kms_key_id
terraform output ebs_kms_key_id
```

See [ARCHITECTURE.md](docs/ARCHITECTURE.md#security-features) for comprehensive security documentation.

## Modules

See [TERRAFORM.md](docs/TERRAFORM.md) for detailed module documentation

## Outputs

```bash
# Cluster information
terraform output eks_cluster_name
terraform output eks_cluster_endpoint
terraform output configure_kubectl

# Security
terraform output eks_kms_key_id
terraform output ebs_kms_key_id

# Service accounts
terraform output aws_load_balancer_controller_role_arn
terraform output ebs_csi_driver_role_arn

# Sensitive outputs
terraform output -raw kubeconfig
terraform output -raw eks_cluster_arn
```

## Cleanup

```bash
kubectl delete svc --all
kubectl delete pvc --all
terraform destroy
```

## License

This project is licensed under the [MIT License](LICENSE).

---

**Built with ❤️ for Cloud Solutions Inc.**
