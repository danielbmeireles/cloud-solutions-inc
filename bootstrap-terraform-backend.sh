#!/bin/bash

# Terraform Remote State Bootstrap Script
# This script creates an S3 bucket for Terraform remote state management
# For details of how to use this script, see the docs/BOOTSTRAP.md file

set -e

# Disable client-side paging for AWS CLI
export AWS_PAGER=""

# Configuration
BUCKET_NAME="${TF_STATE_BUCKET:-terraform-state-$(aws sts get-caller-identity --query Account --output text)}"
ENVIRONMENT="${TF_ENVIRONMENT:-development}"
REGION="${AWS_REGION:-eu-west-1}"

echo "=== Terraform Backend Bootstrap ==="
echo "Bucket: $BUCKET_NAME"
echo "Environment: $ENVIRONMENT"
echo "Region: $REGION"

# Create S3 bucket
echo ""
echo "Creating S3 bucket for state storage..."
echo ""
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo ""
    echo "Bucket \"$BUCKET_NAME\" already exists"
    echo ""
else
    if [ "$REGION" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$REGION"
    else
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION"
    fi
    echo ""
    echo "Bucket created successfully"
    echo ""
fi

# Enable versioning
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable encryption
echo "Enabling server-side encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo ""
echo "=== Bootstrap Complete ==="
echo "Add this backend configuration to the corresponding environment folder:"
echo ""
echo "    # tfbackend.hcl"
echo "    bucket         = \"$BUCKET_NAME\""
echo "    key            = \"$ENVIRONMENT/terraform.tfstate\""
echo "    region         = \"$REGION\""
echo "    use_lockfile   = true"
echo "    encrypt        = true"
echo ""
