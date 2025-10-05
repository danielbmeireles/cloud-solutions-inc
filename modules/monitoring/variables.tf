variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarms"
  type        = string
  default     = ""
}
