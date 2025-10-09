terraform {
  required_version = ">= 1.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "CloudSolutionsInc"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

provider "kubernetes" {
  alias                  = "k8s_placeholder"
  host                   = "https://placeholder"
  cluster_ca_certificate = base64decode("placeholder")
  token                  = "placeholder"
}

provider "helm" {
  alias = "helm_placeholder"
  kubernetes = {
    host                   = "https://placeholder"
    cluster_ca_certificate = base64decode("placeholder")
    token                  = "placeholder"
  }
}
