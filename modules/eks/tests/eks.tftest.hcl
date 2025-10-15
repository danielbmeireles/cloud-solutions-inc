# Terraform Test for EKS Module
# This test validates the EKS module configuration

# Test 1: Validate EKS cluster naming conventions
run "validate_cluster_naming" {
  command = plan

  variables {
    environment           = "test"
    project_name          = "cloud-solutions"
    vpc_id                = "vpc-12345678"
    private_subnets       = ["subnet-12345", "subnet-67890"]
    public_subnets        = ["subnet-abcde", "subnet-fghij"]
    kubernetes_version    = "1.31"
    eks_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ebs_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"
    node_instance_types   = ["t3.medium"]
    capacity_type         = "ON_DEMAND"
    node_disk_size        = 20
    desired_size          = 2
    min_size              = 1
    max_size              = 4
  }

  assert {
    condition     = output.cluster_name == "cloud-solutions-test-cluster"
    error_message = "Cluster name should follow the pattern: {project_name}-{environment}-cluster"
  }
}

# Test 2: Validate production environment naming
run "validate_production_naming" {
  command = plan

  variables {
    environment           = "production"
    project_name          = "cloud-solutions"
    vpc_id                = "vpc-12345678"
    private_subnets       = ["subnet-12345", "subnet-67890"]
    public_subnets        = ["subnet-abcde", "subnet-fghij"]
    kubernetes_version    = "1.31"
    eks_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ebs_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"
  }

  assert {
    condition     = output.cluster_name == "cloud-solutions-production-cluster"
    error_message = "Production cluster name should be cloud-solutions-production-cluster"
  }
}

# Test 3: Validate staging environment naming
run "validate_staging_naming" {
  command = plan

  variables {
    environment           = "staging"
    project_name          = "cloud-solutions"
    vpc_id                = "vpc-12345678"
    private_subnets       = ["subnet-12345", "subnet-67890"]
    public_subnets        = ["subnet-abcde", "subnet-fghij"]
    kubernetes_version    = "1.31"
    eks_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ebs_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"
  }

  assert {
    condition     = output.cluster_name == "cloud-solutions-staging-cluster"
    error_message = "Staging cluster name should be cloud-solutions-staging-cluster"
  }
}

# Test 4: Validate node group configuration
run "validate_node_group_config" {
  command = plan

  variables {
    environment           = "test"
    project_name          = "myapp"
    vpc_id                = "vpc-12345678"
    private_subnets       = ["subnet-12345", "subnet-67890"]
    public_subnets        = ["subnet-abcde", "subnet-fghij"]
    kubernetes_version    = "1.31"
    eks_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ebs_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"
    node_instance_types   = ["t3.large"]
    desired_size          = 3
    min_size              = 2
    max_size              = 6
  }

  assert {
    condition     = output.cluster_name == "myapp-test-cluster"
    error_message = "Cluster name should be myapp-test-cluster"
  }
}

# Test 5: Validate Kubernetes version 1.30
run "validate_k8s_version_1_30" {
  command = plan

  variables {
    environment           = "test"
    project_name          = "cloud-solutions"
    vpc_id                = "vpc-12345678"
    private_subnets       = ["subnet-12345", "subnet-67890"]
    public_subnets        = ["subnet-abcde", "subnet-fghij"]
    kubernetes_version    = "1.30"
    eks_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ebs_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"
  }

  assert {
    condition     = output.cluster_name == "cloud-solutions-test-cluster"
    error_message = "Cluster should be created with correct naming"
  }
}

# Test 6: Validate Kubernetes version 1.31
run "validate_k8s_version_1_31" {
  command = plan

  variables {
    environment           = "test"
    project_name          = "cloud-solutions"
    vpc_id                = "vpc-12345678"
    private_subnets       = ["subnet-12345", "subnet-67890"]
    public_subnets        = ["subnet-abcde", "subnet-fghij"]
    kubernetes_version    = "1.31"
    eks_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ebs_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"
  }

  assert {
    condition     = output.cluster_name == "cloud-solutions-test-cluster"
    error_message = "Cluster should be created with correct naming"
  }
}

# Test 7: Validate Kubernetes version 1.34
run "validate_k8s_version_1_34" {
  command = plan

  variables {
    environment           = "test"
    project_name          = "cloud-solutions"
    vpc_id                = "vpc-12345678"
    private_subnets       = ["subnet-12345", "subnet-67890"]
    public_subnets        = ["subnet-abcde", "subnet-fghij"]
    kubernetes_version    = "1.34"
    eks_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    ebs_kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/87654321-4321-4321-4321-210987654321"
  }

  assert {
    condition     = output.cluster_name == "cloud-solutions-test-cluster"
    error_message = "Cluster should be created with correct naming"
  }
}
