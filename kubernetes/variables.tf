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

variable "state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "cloud-solutions-terraform-state"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "cloud-solutions"
}

# AWS Load Balancer Controller Configuration
variable "install_aws_load_balancer_controller" {
  description = "Whether to install AWS Load Balancer Controller via Helm"
  type        = bool
  default     = true
}

variable "aws_load_balancer_controller_chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "1.14.0"
}

# ArgoCD Configuration
variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "8.5.10"
}

variable "argocd_domain" {
  description = "Domain name for ArgoCD (used for ingress)"
  type        = string
  default     = "argocd.local"
}

variable "argocd_server_insecure" {
  description = "Run ArgoCD server without TLS (useful for development)"
  type        = bool
  default     = true
}

variable "argocd_server_service_type" {
  description = "Service type for ArgoCD server (ClusterIP, LoadBalancer, or NodePort)"
  type        = string
  default     = "ClusterIP"
}

variable "argocd_ingress_enabled" {
  description = "Enable ingress for ArgoCD server"
  type        = bool
  default     = true
}

variable "argocd_ingress_class_name" {
  description = "Ingress class name for ArgoCD"
  type        = string
  default     = "alb"
}

variable "argocd_ingress_annotations" {
  description = "Annotations for ArgoCD ingress"
  type        = map(string)
  default = {
    "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
    "alb.ingress.kubernetes.io/target-type" = "ip"
  }
}

# ArgoCD High Availability Configuration
variable "argocd_server_replicas" {
  description = "Number of replicas for ArgoCD server"
  type        = number
  default     = 2
}

variable "argocd_repo_server_replicas" {
  description = "Number of replicas for ArgoCD repo server"
  type        = number
  default     = 2
}

variable "argocd_controller_replicas" {
  description = "Number of replicas for ArgoCD application controller"
  type        = number
  default     = 1
}

variable "argocd_enable_ha" {
  description = "Enable high availability features (pod anti-affinity and disruption budgets)"
  type        = bool
  default     = true
}

# ACM Certificate Configuration

variable "acm_certificate_enabled" {
  description = "Enable ACM certificate creation via Terraform for ArgoCD domain"
  type        = bool
  default     = false
}

variable "acm_subject_alternative_names" {
  description = "Additional domain names for the ACM certificate (e.g., for wildcard or multiple subdomains)"
  type        = list(string)
  default     = []
}

variable "acm_wait_for_validation" {
  description = "Whether to wait for ACM certificate validation (requires DNS records to be added manually)"
  type        = bool
  default     = false
}
