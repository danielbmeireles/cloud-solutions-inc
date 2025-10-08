variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "cloud-solutions"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# EKS Configuration
variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# Node Group Configuration
variable "node_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 20
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

# EKS Addon Versions
variable "vpc_cni_addon_version" {
  description = "Version of the VPC CNI addon"
  type        = string
  default     = "v1.18.1-eksbuild.3"
}

variable "coredns_addon_version" {
  description = "Version of the CoreDNS addon"
  type        = string
  default     = "v1.11.1-eksbuild.9"
}

variable "kube_proxy_addon_version" {
  description = "Version of the kube-proxy addon"
  type        = string
  default     = "v1.30.0-eksbuild.3"
}

variable "ebs_csi_addon_version" {
  description = "Version of the EBS CSI driver addon"
  type        = string
  default     = "v1.31.0-eksbuild.1"
}

# Monitoring
variable "alarm_email" {
  description = "Email address for CloudWatch alarms"
  type        = string
  default     = ""
}
