# Terraform Remote State Bootstrap Instructions

This document provides instructions for bootstrapping a Terraform remote state backend using an S3 bucket. The provided script automates the creation of the necessary S3 bucket with appropriate configurations.

## 📋 Prerequisites

- AWS CLI installed and configured
- AWS credentials with permissions to create S3 buckets
- Appropriate IAM permissions:
  - `s3:CreateBucket`
  - `s3:PutBucketVersioning`
  - `s3:PutEncryptionConfiguration`
  - `s3:PutPublicAccessBlock`

## 📚️ Usage

### Default Configuration

Run the script with default settings (bucket name will include your AWS account ID):

```bash
./bootstrap-terraform-backend.sh
```

### Custom Configuration

Override defaults using environment variables:

```bash
export TF_STATE_BUCKET="my-custom-terraform-state-bucket"
export AWS_REGION="eu-west-1"
./bootstrap-terraform-backend.sh
```

## 🕌 What the Script Creates

**S3 Bucket** for storing Terraform state files with:
  - Versioning enabled (for state history)
  - Server-side encryption (AES256)
  - Public access blocked
  - Region-specific configuration (if applicable)

## 🦶 Next Steps

After running the bootstrap script:

1. Copy the backend configuration output by the script
2. Add it to your Terraform configuration (e.g., `backend.tf`)
3. Run `terraform init` to initialize the backend
4. If migrating existing state, Terraform will prompt you to copy it

## 🏋️ Example Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-123456789012"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    use_lockfile   = true
    encrypt        = true
  }
}
```

## 😵‍💫 Troubleshooting

- **Bucket name already taken**: S3 bucket names are globally unique. Use `TF_STATE_BUCKET` to specify a different name.
- **Permissions error**: Ensure your AWS credentials have the required IAM permissions listed above.
- **Region mismatch**: Ensure `AWS_REGION` matches your desired region.
