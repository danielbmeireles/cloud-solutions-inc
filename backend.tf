# Backend configuration for Terraform state

terraform {
  backend "s3" {
    bucket       = "cloud-solutions-terraform-state"
    key          = "production/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
