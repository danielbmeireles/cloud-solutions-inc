# ACM Certificate Outputs

output "certificate_arn" {
  description = "ARN of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.cert[0].arn : null
}

output "certificate_id" {
  description = "ID of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.cert[0].id : null
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.cert[0].domain_name : null
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.cert[0].status : null
}

output "domain_validation_options" {
  description = "Domain validation options (CNAME records to add to DNS)"
  value       = var.create_certificate ? aws_acm_certificate.cert[0].domain_validation_options : []
}

output "validation_record_fqdns" {
  description = "FQDNs of validation records to add to DNS (formatted for easy reference)"
  value = var.create_certificate ? [
    for dvo in aws_acm_certificate.cert[0].domain_validation_options : {
      domain              = dvo.domain_name
      name                = dvo.resource_record_name
      type                = dvo.resource_record_type
      value               = dvo.resource_record_value
      squarespace_host    = replace(dvo.resource_record_name, ".${var.domain_name}", "")
      squarespace_host_v2 = trimsuffix(dvo.resource_record_name, ".")
    }
  ] : []
}
