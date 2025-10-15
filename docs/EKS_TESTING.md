# 🧪 EKS Module Testing <!-- omit in toc -->

Comprehensive testing guide for the EKS module using Terraform's official testing framework.

## 📑 Table of Contents <!-- omit in toc -->

- [🏗️ Overview](#️-overview)
- [📋 Prerequisites](#-prerequisites)
- [🚀 Running Tests](#-running-tests)
- [✨ Test Coverage](#-test-coverage)
- [⚙️ Test Architecture](#️-test-architecture)
- [🔧 Troubleshooting](#-troubleshooting)
- [📚 Related Documentation](#-related-documentation)

## 🏗️ Overview

The EKS module includes comprehensive unit tests using Terraform's native testing framework (introduced in Terraform 1.6+). These tests validate module configuration without creating actual AWS resources.

**Key Benefits:**
- ✅ Fast execution (runs in seconds)
- ✅ No AWS credentials required
- ✅ No infrastructure costs
- ✅ Repeatable and deterministic results
- ✅ Run locally before committing

**Test Location:** `modules/eks/tests/eks.tftest.hcl`

## 📋 Prerequisites

### Required

- **Terraform 1.6.0+** - Testing framework support

```bash
terraform version
```

### Optional

- **Checkov** - For security scanning (runs in CI/CD automatically)

```bash
pip install checkov
```

## 🚀 Running Tests

### Basic Test Execution

Navigate to the EKS module directory and run all tests:

```bash
cd modules/eks
terraform test
```

Expected output:
```
tests/eks.tftest.hcl... in progress
  run "validate_cluster_naming"... pass
  run "validate_oidc_provider"... pass
  run "validate_csi_driver_roles"... pass
  run "validate_node_group"... pass
  run "validate_security_outputs"... pass
  run "validate_cluster_arn_format"... pass
  run "validate_kubernetes_version"... pass
tests/eks.tftest.hcl... tearing down
tests/eks.tftest.hcl... pass

Success! 7 passed, 0 failed.
```

### Verbose Output

For detailed test execution information:

```bash
terraform test -verbose
```

Shows:
- Test initialization steps
- Variable values
- Assertion evaluations
- Resource mock calls
- Detailed error messages (if any)

### Run Specific Tests

Execute a single test by filter:

```bash
terraform test -filter=validate_cluster_naming
```

Filter by pattern:

```bash
terraform test -filter='validate_*_roles'
```

### From Project Root

Run tests without changing directories:

```bash
terraform -chdir=modules/eks test
```

## ✨ Test Coverage

The test suite includes 7 comprehensive test scenarios:

### 1. validate_cluster_naming

**Purpose:** Validates EKS cluster naming conventions

**What it tests:**
- Cluster name follows pattern: `{project_name}-{environment}-cluster`
- Cluster ID is not empty
- Cluster endpoint is not empty

**Example assertion:**
```hcl
assert {
  condition     = output.cluster_name == "cloud-solutions-test-cluster"
  error_message = "Cluster name should follow the pattern: {project_name}-{environment}-cluster"
}
```

### 2. validate_oidc_provider

**Purpose:** Validates OIDC provider configuration for IRSA

**What it tests:**
- OIDC provider ARN exists
- OIDC provider URL exists
- Cluster OIDC issuer URL exists

**Why it matters:** IRSA (IAM Roles for Service Accounts) depends on OIDC configuration

### 3. validate_csi_driver_roles

**Purpose:** Validates IAM roles for CSI drivers

**What it tests:**
- EBS CSI driver role ARN exists
- EFS CSI driver role ARN exists
- Node group role ARN exists

**Why it matters:** CSI drivers require proper IAM roles for AWS API access

### 4. validate_node_group

**Purpose:** Validates EKS node group configuration

**What it tests:**
- Node group ID exists
- Node group ARN exists
- Different instance types are supported
- Scaling configuration works

**Test variables:**
```hcl
node_instance_types = ["t3.large"]
desired_size        = 3
min_size            = 2
max_size            = 6
```

### 5. validate_security_outputs

**Purpose:** Validates security-related outputs

**What it tests:**
- Cluster security group ID exists
- Certificate authority data exists
- Custom CIDR block configuration works

**Test variables:**
```hcl
cluster_endpoint_public_access_cidrs = ["10.0.0.0/8"]
```

### 6. validate_cluster_arn_format

**Purpose:** Validates the format of cluster ARN

**What it tests:**
- ARN starts with `arn:aws:eks:`
- ARN format is valid

**Example assertion:**
```hcl
assert {
  condition     = can(regex("^arn:aws:eks:", output.cluster_arn))
  error_message = "Cluster ARN should start with 'arn:aws:eks:'"
}
```

### 7. validate_kubernetes_version

**Purpose:** Validates Kubernetes version configuration

**What it tests:**
- Cluster can be created with different Kubernetes versions
- Version parameter is properly applied

**Test variables:**
```hcl
kubernetes_version = "1.34"
```

## ⚙️ Test Architecture

### Mock Provider Strategy

Tests use **mock providers** to simulate AWS resources without actual API calls:

```hcl
mock_provider "aws" {
  alias = "mock"

  mock_resource "aws_eks_cluster" {
    defaults = {
      id       = "test-cluster"
      name     = "cloud-solutions-test-cluster"
      endpoint = "https://EXAMPLE.gr7.us-east-1.eks.amazonaws.com"
      # ... more defaults
    }
  }
}
```

**Mocked Resources:**
- `aws_eks_cluster` - EKS control plane
- `aws_eks_node_group` - Worker nodes
- `aws_iam_role` - IAM roles
- `aws_iam_openid_connect_provider` - OIDC provider
- `aws_security_group` - Security groups
- `aws_launch_template` - Node launch templates
- `aws_cloudwatch_log_group` - CloudWatch logs
- `aws_eks_addon` - EKS add-ons

### Test Execution Flow

```
┌─────────────────────────────────┐
│  1. Load test file              │
│     eks.tftest.hcl              │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  2. Initialize mock provider    │
│     No real AWS connection      │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  3. Run each test scenario      │
│     - Set variables             │
│     - Execute plan              │
│     - Check assertions          │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  4. Report results              │
│     Pass/Fail summary           │
└─────────────────────────────────┘
```

### Test Isolation

Each test (`run` block):
- Executes independently
- Has its own variable values
- Does not affect other tests
- Cleans up automatically

## 🔧 Troubleshooting

### Command Not Found

**Error:**
```
terraform: command not found: test
```

**Solution:**
```bash
# Check Terraform version
terraform version

# Upgrade to 1.6.0 or later
# macOS
brew upgrade terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Mock Provider Errors

**Error:**
```
Error: mock_provider configuration is invalid
```

**Solution:**
- Verify test file syntax with `terraform fmt modules/eks/tests/eks.tftest.hcl`
- Check Terraform version is 1.6.0+
- Review mock provider block for typos

### Assertion Failures

**Error:**
```
run "validate_cluster_naming"... fail
  ✗ Cluster name should follow the pattern: {project_name}-{environment}-cluster
```

**Solution:**
- Review the module code in `modules/eks/main.tf`
- Check the naming logic matches expected pattern
- Verify test variables are correct
- Update test expectations if intentional change

### Tests Hang or Timeout

**Error:**
Tests run indefinitely without completing

**Solution:**
- Ensure you're not using real providers
- Check for syntax errors in test file
- Verify mock provider is properly configured
- Try running with `-verbose` flag for more details

### Wrong Directory

**Error:**
```
Error: No test files found
```

**Solution:**
```bash
# Ensure you're in the module directory
cd modules/eks

# Or use -chdir flag
terraform -chdir=modules/eks test
```

## 📚 Related Documentation

### Testing & Security
- [Checkov Security Scanning](CICD.md#security-scanning) - Automated security checks in CI/CD
- [CI/CD Pipeline](CICD.md) - Automated deployment workflows

### EKS Documentation
- [EKS Deployment Guide](EKS.md) - Complete EKS setup
- [EKS Module](../modules/eks/README.md) - Module documentation
- [EKS Test README](../modules/eks/tests/README.md) - Detailed test documentation

### External Resources
- [Terraform Testing](https://developer.hashicorp.com/terraform/language/tests) - Official documentation
- [Terraform 1.6 Release](https://www.hashicorp.com/blog/terraform-1-6-adds-a-test-framework-for-enhanced-code-validation) - Testing framework announcement

---

**Built with ❤️ for Cloud Solutions Inc.**
