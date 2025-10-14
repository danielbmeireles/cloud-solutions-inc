variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.12"
}

variable "argocd_domain" {
  description = "Domain name for ArgoCD (for ingress)"
  type        = string
  default     = "argocd.local"
}

variable "server_insecure" {
  description = "Run server without TLS (useful for development)"
  type        = bool
  default     = true
}

variable "server_service_type" {
  description = "Service type for ArgoCD server (ClusterIP, LoadBalancer, or NodePort)"
  type        = string
  default     = "ClusterIP"
}

variable "ingress_enabled" {
  description = "Enable ingress for ArgoCD server"
  type        = bool
  default     = false
}

variable "ingress_class_name" {
  description = "Ingress class name for ArgoCD"
  type        = string
  default     = "alb"
}

variable "ingress_annotations" {
  description = "Annotations for ArgoCD ingress"
  type        = map(string)
  default     = {}
}

variable "enable_certificate" {
  description = "Enable automatic SSL/TLS certificate via cert-manager"
  type        = bool
  default     = false
}

variable "certificate_issuer" {
  description = "cert-manager ClusterIssuer name for certificate generation"
  type        = string
  default     = "letsencrypt-prod"
}

variable "controller_resources" {
  description = "Resource limits for ArgoCD controller"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}

variable "repo_server_resources" {
  description = "Resource limits for ArgoCD repo server"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}

variable "server_resources" {
  description = "Resource limits for ArgoCD server"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "256Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
  }
}
