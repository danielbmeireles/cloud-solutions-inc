# ACM Certificate Variables

variable "create_certificate" {
  description = "Whether to create an ACM certificate"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for the certificate (e.g., argocd.meireles.dev)"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names for the certificate (e.g., for wildcard or multiple subdomains)"
  type        = list(string)
  default     = []
}

variable "wait_for_validation" {
  description = "Whether to wait for certificate validation (requires DNS records to be added)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the certificate"
  type        = map(string)
  default     = {}
}
