output "alb_security_group_id" {
  description = "Security group ID for ALBs"
  value       = aws_security_group.alb.id
}
