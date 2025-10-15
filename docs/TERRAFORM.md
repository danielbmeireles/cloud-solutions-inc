# 📘 Terraform Documentation <!-- omit in toc -->

Comprehensive Terraform module reference and configuration guide for the Cloud Solutions Inc. infrastructure.

## 📑 Table of Contents <!-- omit in toc -->

- [🏗️ Overview](#️-overview)
- [📁 Project Structure](#-project-structure)
- [🔧 Infrastructure Layer (Root Module)](#-infrastructure-layer-root-module)
- [☸️ Kubernetes Layer](#️-kubernetes-layer)
- [📦 Module Reference](#-module-reference)
- [⚙️ Configuration](#️-configuration)
- [🚀 Usage](#-usage)
- [✨ Best Practices](#-best-practices)

## 🏗️ Overview

This project uses a **two-layer Terraform architecture** with separate state files:

1. **Infrastructure Layer** (Root): AWS infrastructure (VPC, EKS, IAM, KMS, EFS, CloudWatch)
2. **Kubernetes Layer**: Kubernetes resources (ArgoCD, AWS Load Balancer Controller)

This separation provides:
- ✅ Independent deployments and rollbacks
- ✅ Reduced blast radius for changes
- ✅ Cleaner dependency management
- ✅ Better CI/CD workflows

## 📁 Project Structure

```
.
├── main.tf                      # Infrastructure layer main configuration
├── variables.tf                 # Infrastructure layer variables
├── outputs.tf                   # Infrastructure layer outputs
├── versions.tf                  # Provider version constraints
├── backend.tf                   # Terraform backend configuration
├── TERRAFORM_ROOT.md            # Auto-generated infrastructure docs
│
├── modules/                     # Reusable Terraform modules
│   ├── vpc/                     # VPC and networking
│   ├── eks/                     # EKS cluster and node groups
│   ├── kms/                     # KMS encryption keys
│   ├── efs/                     # EFS file system
│   ├── cloudwatch/              # CloudWatch monitoring
│   ├── alb/                     # ALB security groups
│   ├── acm/                     # ACM certificates
│   └── argocd/                  # ArgoCD Helm deployment
│
├── kubernetes/                  # Kubernetes layer
│   ├── main.tf                  # Kubernetes resources configuration
│   ├── variables.tf             # Kubernetes layer variables
│   ├── outputs.tf               # Kubernetes layer outputs
│   ├── data.tf                  # Remote state data sources
│   ├── iam.tf                   # IAM roles for Kubernetes
│   └── TERRAFORM_KUBERNETES.md  # Auto-generated Kubernetes docs
│
└── environments/                # Environment-specific configurations
    ├── production/
    │   ├── terraform.tfvars     # Production variables
    │   └── tfbackend.hcl        # Production backend config
    ├── staging/
    └── development/
```

## 🔧 Infrastructure Layer (Root Module)

The infrastructure layer deploys the foundational AWS resources.

### Components

- **VPC Module**: Virtual Private Cloud with public/private subnets across 3 AZs
- **EKS Module**: Managed Kubernetes cluster with auto-scaling node groups
- **KMS Module**: Customer-managed encryption keys for EKS and EBS
- **EFS Module**: Shared file system for persistent storage
- **CloudWatch Module**: Monitoring dashboards and log groups
- **ALB Module**: Security groups for Application Load Balancers

### Documentation

For complete variable reference, see [TERRAFORM_ROOT.md](../TERRAFORM_ROOT.md)

### Quick Example

```hcl
# environments/production/terraform.tfvars
aws_region         = "eu-west-1"
environment        = "production"
project_name       = "cloud-solutions"
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

kubernetes_version  = "1.34"
node_instance_types = ["t3.medium"]
desired_size        = 2
min_size            = 1
max_size            = 4
```

## ☸️ Kubernetes Layer

The Kubernetes layer deploys resources that run on the EKS cluster.

### Components

- **AWS Load Balancer Controller**: Automatic ALB/NLB provisioning
- **ArgoCD**: GitOps continuous delivery platform
- **ACM Module**: SSL/TLS certificates for custom domains
- **IAM Roles**: IRSA roles for Kubernetes service accounts

### Documentation

For complete variable reference, see [kubernetes/TERRAFORM_KUBERNETES.md](../kubernetes/TERRAFORM_KUBERNETES.md)

### Quick Example

```hcl
# kubernetes/environments/production/terraform.tfvars
environment  = "production"
aws_region   = "eu-west-1"
project_name = "cloud-solutions"

# AWS Load Balancer Controller
install_aws_load_balancer_controller = true

# ArgoCD with custom domain and ACM certificate
argocd_domain           = "argocd.yourdomain.com"
acm_certificate_enabled = true
```

## 📦 Module Reference

Each module has auto-generated documentation with inputs, outputs, and examples.

### Infrastructure Modules

| Module | Description | Documentation |
|--------|-------------|---------------|
| **VPC** | Virtual Private Cloud with multi-AZ subnets | [modules/vpc/README.md](../modules/vpc/README.md) |
| **EKS** | Managed Kubernetes cluster and node groups | [modules/eks/README.md](../modules/eks/README.md) |
| **KMS** | Customer-managed encryption keys | [modules/kms/README.md](../modules/kms/README.md) |
| **EFS** | Elastic File System for shared storage | [modules/efs/README.md](../modules/efs/README.md) |
| **CloudWatch** | Monitoring dashboards and log groups | [modules/cloudwatch/README.md](../modules/cloudwatch/README.md) |
| **ALB** | Security groups for load balancers | [modules/alb/README.md](../modules/alb/README.md) |

### Kubernetes Modules

| Module | Description | Documentation |
|--------|-------------|---------------|
| **ACM** | AWS Certificate Manager for SSL/TLS | [modules/acm/README.md](../modules/acm/README.md) |
| **ArgoCD** | GitOps deployment via Helm | [modules/argocd/README.md](../modules/argocd/README.md) |

## ⚙️ Configuration

### Backend Configuration

Each layer uses separate backend configurations:

**Infrastructure Layer**: `environments/production/tfbackend.hcl`
```hcl
bucket       = "cloud-solutions-terraform-state"
key          = "production/infra/terraform.tfstate"
region       = "eu-west-1"
use_lockfile = true
encrypt      = true
```

**Kubernetes Layer**: `kubernetes/environments/production/tfbackend.hcl`
```hcl
bucket       = "cloud-solutions-terraform-state"
key          = "production/kubernetes/terraform.tfstate"
region       = "eu-west-1"
use_lockfile = true
encrypt      = true
```

### Remote State Data Source

The Kubernetes layer reads outputs from the Infrastructure layer:

```hcl
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "${var.environment}/infra/terraform.tfstate"
    region = var.aws_region
  }
}

# Usage
cluster_name = data.terraform_remote_state.infra.outputs.eks_cluster_name
vpc_id       = data.terraform_remote_state.infra.outputs.vpc_id
```

## 🚀 Usage

### Initial Setup

1. **Bootstrap Terraform Backend**
   ```bash
   ./scripts/bootstrap-terraform-backend.sh
   ```

2. **Deploy Infrastructure Layer**
   ```bash
   terraform init -backend-config=environments/production/tfbackend.hcl
   terraform plan -var-file=environments/production/terraform.tfvars
   terraform apply -var-file=environments/production/terraform.tfvars
   ```

3. **Deploy Kubernetes Layer**
   ```bash
   cd kubernetes
   terraform init -backend-config=environments/production/tfbackend.hcl
   terraform plan -var-file=environments/production/terraform.tfvars
   terraform apply -var-file=environments/production/terraform.tfvars
   ```

### Updating Infrastructure

```bash
# Update infrastructure
terraform plan -var-file=environments/production/terraform.tfvars
terraform apply -var-file=environments/production/terraform.tfvars

# Update Kubernetes resources
cd kubernetes
terraform plan -var-file=environments/production/terraform.tfvars
terraform apply -var-file=environments/production/terraform.tfvars
```

### Creating New Environments

1. Create environment directory:
   ```bash
   mkdir -p environments/staging
   mkdir -p kubernetes/environments/staging
   ```

2. Copy and modify configuration files:
   ```bash
   cp environments/production/*.{tfvars,hcl} environments/staging/
   cp kubernetes/environments/production/*.{tfvars,hcl} kubernetes/environments/staging/
   ```

3. Update values in the new environment files

4. Deploy following the same process as production

## ✨ Best Practices

### 1. Version Pinning

Always pin provider versions in `versions.tf`:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}
```

### 2. Variable Validation

Use validation blocks for critical variables:

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}
```

### 3. Tagging Strategy

Consistent tagging across all resources:

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Repository  = "cloud-solutions-inc"
  }
}
```

### 4. State Management

- Use S3 backend with versioning enabled
- Enable state locking with DynamoDB (optional)
- Separate states per environment and layer
- Never commit state files to version control

### 5. Secrets Management

- Never hardcode sensitive values
- Use AWS Secrets Manager or Parameter Store
- Reference secrets via data sources:

```hcl
data "aws_secretsmanager_secret_version" "example" {
  secret_id = "my-secret"
}
```

### 6. Module Versioning

When using external modules, always specify versions:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"
  # ...
}
```

### 7. Plan Before Apply

Always review plan output before applying:

```bash
terraform plan -out=tfplan -var-file=environments/production/terraform.tfvars
# Review the plan carefully
terraform apply tfplan
```

### 8. Import Existing Resources

If you need to manage existing AWS resources:

```bash
terraform import aws_vpc.main vpc-12345678
```

### 9. State Operations

Common state management commands:

```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_vpc.main

# Move resource to different address
terraform state mv aws_vpc.old aws_vpc.new

# Remove resource from state
terraform state rm aws_vpc.main
```

### 10. Workspace Usage

For environment separation (alternative to separate directories):

```bash
terraform workspace new staging
terraform workspace select staging
terraform workspace list
```

## 💡 Practical Examples

### Example 1: Multi-Environment Deployment

Deploy the same infrastructure across multiple environments with different configurations:

**1. Create environment-specific tfvars files:**

```hcl
# environments/development/terraform.tfvars
environment        = "development"
vpc_cidr           = "10.1.0.0/16"
kubernetes_version = "1.34"
desired_size       = 1
min_size           = 1
max_size           = 2
node_instance_types = ["t3.small"]
```

```hcl
# environments/production/terraform.tfvars
environment        = "production"
vpc_cidr           = "10.0.0.0/16"
kubernetes_version = "1.34"
desired_size       = 3
min_size           = 2
max_size           = 6
node_instance_types = ["t3.medium"]
```

**2. Deploy to each environment:**

```bash
# Deploy development
terraform init -backend-config=environments/development/tfbackend.hcl
terraform apply -var-file=environments/development/terraform.tfvars

# Deploy production
terraform init -backend-config=environments/production/tfbackend.hcl -reconfigure
terraform apply -var-file=environments/production/terraform.tfvars
```

### Example 2: Disaster Recovery Procedure

Recover infrastructure from Terraform state backup:

**1. Identify the corrupted state:**

```bash
# Check current state
terraform state list
# Error: Failed to load state

# List available S3 versions
aws s3api list-object-versions \
  --bucket cloud-solutions-terraform-state \
  --prefix production/infra/terraform.tfstate
```

**2. Restore from previous version:**

```bash
# Download specific version
aws s3api get-object \
  --bucket cloud-solutions-terraform-state \
  --key production/infra/terraform.tfstate \
  --version-id <version-id> \
  terraform.tfstate.restored

# Backup current state (if accessible)
terraform state pull > terraform.tfstate.backup

# Upload restored state
aws s3 cp terraform.tfstate.restored \
  s3://cloud-solutions-terraform-state/production/infra/terraform.tfstate
```

**3. Verify restoration:**

```bash
terraform init -backend-config=environments/production/tfbackend.hcl -reconfigure
terraform plan -var-file=environments/production/terraform.tfvars
# Should show no changes if restoration was successful
```

### Example 3: Scaling Node Groups

Scale EKS node groups to handle increased load:

**Option A: Update tfvars and apply (permanent change):**

```hcl
# environments/production/terraform.tfvars
desired_size = 5  # Changed from 3
min_size     = 3  # Changed from 2
max_size     = 10 # Changed from 6
```

```bash
terraform apply -var-file=environments/production/terraform.tfvars
```

**Option B: Manual scaling via AWS CLI (temporary):**

```bash
# Get Auto Scaling Group name
aws autoscaling describe-auto-scaling-groups \
  --query "AutoScalingGroups[?contains(Tags[?Key=='eks:cluster-name'].Value, 'cloud-solutions-production')].AutoScalingGroupName" \
  --output text

# Scale the ASG
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name <asg-name> \
  --desired-capacity 5

# Verify scaling
kubectl get nodes -w
```

### Example 4: Adding a New Module

Add a new RDS database module to the infrastructure:

**1. Create the module:**

```bash
mkdir -p modules/rds
```

**2. Define module resources (modules/rds/main.tf):**

```hcl
resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-${var.environment}"
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_encrypted      = true
  kms_key_id            = var.kms_key_arn

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  username = var.master_username
  password = var.master_password

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot = var.environment != "production"

  tags = var.tags
}
```

**3. Use the module in main.tf:**

```hcl
module "rds" {
  source = "./modules/rds"

  project_name  = var.project_name
  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  kms_key_arn   = module.kms.key_arn

  engine_version     = "15.4"
  instance_class     = "db.t3.medium"
  allocated_storage  = 100

  master_username = "dbadmin"
  master_password = data.aws_secretsmanager_secret_version.db_password.secret_string

  tags = local.common_tags
}
```

**4. Generate module documentation:**

```bash
terraform-docs markdown table --output-file README.md --output-mode inject modules/rds
```

### Example 5: Migrating State Between Backends

Move state from local to S3 backend:

**1. Current local state (backend.tf):**

```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

**2. Create new S3 backend configuration:**

```hcl
# backend.tf
terraform {
  backend "s3" {
    # Configuration will be provided via backend-config file
  }
}
```

**3. Perform migration:**

```bash
# Initialize with new backend
terraform init -backend-config=environments/production/tfbackend.hcl

# Terraform will detect the change and prompt to migrate
# Answer "yes" when prompted: "Do you want to copy existing state to the new backend?"

# Verify migration
terraform state list
aws s3 ls s3://cloud-solutions-terraform-state/production/infra/terraform.tfstate
```

**4. Clean up old state:**

```bash
# Backup local state
cp terraform.tfstate terraform.tfstate.local.backup

# Remove local state (after verifying S3 state works)
rm terraform.tfstate terraform.tfstate.backup
```

### Example 6: Cost Optimization Scenario

Reduce costs by right-sizing resources:

**1. Analyze current costs:**

```bash
# Use Infracost to estimate current costs
infracost breakdown --path .

# Sample output:
# t3.medium x 3 nodes = $91/month
# EFS storage = $30/month
# Total: ~$121/month
```

**2. Optimize configuration:**

```hcl
# environments/production/terraform.tfvars

# Option 1: Use smaller instance types during off-hours
node_instance_types = ["t3.small"]  # Changed from t3.medium

# Option 2: Reduce minimum node count
desired_size = 2  # Changed from 3
min_size     = 1  # Changed from 2

# Option 3: Enable EFS lifecycle policy
efs_lifecycle_policy = {
  transition_to_ia = "AFTER_30_DAYS"
}
```

**3. Estimate new costs:**

```bash
# Compare costs
infracost diff --path .

# Sample output showing savings:
# t3.small x 2 nodes = $36/month
# Savings: ~$55/month (45% reduction)
```

**4. Apply changes during maintenance window:**

```bash
terraform apply -var-file=environments/production/terraform.tfvars
```

### Example 7: Blue-Green Deployment for EKS Upgrade

Perform zero-downtime Kubernetes version upgrade:

**1. Create new node group with updated version:**

```hcl
# In main.tf or variables, add a second node group
eks_node_groups = {
  green = {
    instance_types = ["t3.medium"]
    desired_size   = 3
    min_size       = 2
    max_size       = 6
    kubernetes_version = "1.35"  # New version
  }
  blue = {
    instance_types = ["t3.medium"]
    desired_size   = 3
    min_size       = 2
    max_size       = 6
    kubernetes_version = "1.34"  # Current version
  }
}
```

**2. Deploy green node group:**

```bash
terraform apply -var-file=environments/production/terraform.tfvars
```

**3. Cordon and drain blue nodes:**

```bash
# Cordon old nodes to prevent new pods
kubectl cordon -l eks.amazonaws.com/nodegroup=blue

# Drain pods from old nodes
kubectl drain -l eks.amazonaws.com/nodegroup=blue \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --grace-period=300
```

**4. Verify workloads on green nodes:**

```bash
kubectl get pods -o wide
kubectl get nodes -l eks.amazonaws.com/nodegroup=green
```

**5. Remove blue node group:**

```hcl
# Remove blue node group from configuration
eks_node_groups = {
  green = {
    instance_types = ["t3.medium"]
    desired_size   = 3
    min_size       = 2
    max_size       = 6
    kubernetes_version = "1.35"
  }
}
```

```bash
terraform apply -var-file=environments/production/terraform.tfvars
```

## 📚 Related Documentation

- [Architecture](ARCHITECTURE.md) - Infrastructure design and decisions
- [Bootstrap](BOOTSTRAP.md) - Terraform state backend setup
- [CI/CD](CICD.md) - Automated deployment workflows
- [EKS](EKS.md) - EKS cluster operations
- [Kubernetes](KUBERNETES.md) - Kubernetes layer deployment

## 🔗 External Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [terraform-docs](https://terraform-docs.io/) - Documentation generator

---

**Built with ❤️ for Cloud Solutions Inc.**
