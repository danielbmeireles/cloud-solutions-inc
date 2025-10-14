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

variable "argocd_enable_certificate" {
  description = "Enable automatic SSL/TLS certificate for ArgoCD via cert-manager"
  type        = bool
  default     = false
}

variable "argocd_certificate_issuer" {
  description = "cert-manager ClusterIssuer name for ArgoCD certificate generation"
  type        = string
  default     = "letsencrypt-prod"
}
