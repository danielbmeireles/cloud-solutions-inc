# KMS Module
module "kms" {
  source = "./modules/kms"

  project_name            = var.project_name
  environment             = var.environment
  deletion_window_in_days = 10
  node_group_arn          = module.eks.node_group_role_arn
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  project_name       = var.project_name
}

# EKS Cluster Module
module "eks" {
  source = "./modules/eks"

  environment        = var.environment
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnet_ids
  public_subnets     = module.vpc.public_subnet_ids
  kubernetes_version = var.kubernetes_version

  node_instance_types = var.node_instance_types
  capacity_type       = var.capacity_type
  node_disk_size      = var.node_disk_size
  desired_size        = var.desired_size
  min_size            = var.min_size
  max_size            = var.max_size

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_enabled_log_types            = var.cluster_enabled_log_types

  vpc_cni_addon_version    = var.vpc_cni_addon_version
  coredns_addon_version    = var.coredns_addon_version
  kube_proxy_addon_version = var.kube_proxy_addon_version
  ebs_csi_addon_version    = var.ebs_csi_addon_version
  efs_csi_addon_version    = var.efs_csi_addon_version

  # KMS encryption keys
  eks_kms_key_arn = module.kms.eks_key_arn
  ebs_kms_key_arn = module.kms.ebs_key_arn
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  environment      = var.environment
  project_name     = var.project_name
  vpc_id           = module.vpc.vpc_id
  eks_cluster_name = module.eks.cluster_name
}

# EFS Module
module "efs" {
  source = "./modules/efs"

  environment                = var.environment
  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  private_subnets            = module.vpc.private_subnet_ids
  eks_node_security_group_id = module.eks.cluster_security_group_id
}

# CloudWatch Module
module "cloudwatch" {
  source = "./modules/cloudwatch"

  environment      = var.environment
  project_name     = var.project_name
  eks_cluster_name = module.eks.cluster_name
  alarm_email      = var.alarm_email
}
