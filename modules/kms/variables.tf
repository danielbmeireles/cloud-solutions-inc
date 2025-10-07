variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Duration in days before KMS key is deleted after destruction"
  type        = number
  default     = 10
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Deletion window must be between 7 and 30 days."
  }
}

variable "node_group_arn" {
  description = "ARN of the EKS Node Group Role"
  type        = string
}
