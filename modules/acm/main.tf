# ACM Certificate Module
# Creates and validates SSL/TLS certificates for use with ALB

# Request ACM certificate
resource "aws_acm_certificate" "cert" {
  count = var.create_certificate ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.domain_name}-certificate"
    }
  )
}

# DNS validation records (to be added manually to DNS provider)
# These outputs will show what records you need to add
resource "aws_acm_certificate_validation" "cert" {
  count = var.create_certificate && var.wait_for_validation ? 1 : 0

  certificate_arn = aws_acm_certificate.cert[0].arn

  # Note: This will wait for manual DNS validation
  # You must add the DNS records to your DNS provider

  timeouts {
    create = "60m"
  }
}
