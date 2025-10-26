# Data Sources

# Data source to get infrastructure state from remote backend
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "${var.environment}/infra/terraform.tfstate"
    region = var.aws_region
  }
}
