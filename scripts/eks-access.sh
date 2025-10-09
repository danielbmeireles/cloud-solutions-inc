#!/bin/bash

# EKS Cluster Access Configuration Script
# This script configures access entries and policies for an EKS cluster

set -e

# Disable client-side paging for AWS CLI
export AWS_PAGER=""

# Configuration
CLUSTER_NAME="${EKS_CLUSTER_NAME}"
SSO_ROLE_ARN="${EKS_SSO_ROLE_ARN}"
REGION="${AWS_REGION:-eu-west-1}"
POLICY_ARN="arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

echo "=== EKS Access Configuration ==="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Principal ARN: $SSO_ROLE_ARN"

# Check if cluster exists
echo ""
echo "Checking if cluster exists..."
if ! aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" > /dev/null 2>&1; then
    echo "Error: Cluster '$CLUSTER_NAME' not found in region '$REGION'"
    exit 1
fi
echo "Cluster found"

# Create access entry
echo ""
echo "Creating access entry..."
if aws eks describe-access-entry \
    --cluster-name "$CLUSTER_NAME" \
    --principal-arn "$SSO_ROLE_ARN" \
    --region "$REGION" 2>/dev/null; then
    echo "Access entry already exists"
else
    aws eks create-access-entry \
        --cluster-name "$CLUSTER_NAME" \
        --principal-arn "$SSO_ROLE_ARN" \
        --type STANDARD \
        --region "$REGION"
    echo "Access entry created"
fi

# Associate access policy
echo ""
echo "Associating cluster admin policy..."
if aws eks list-associated-access-policies \
    --cluster-name "$CLUSTER_NAME" \
    --principal-arn "$SSO_ROLE_ARN" \
    --region "$REGION" 2>/dev/null | grep -q "$POLICY_ARN"; then
    echo "Policy already associated"
else
    aws eks associate-access-policy \
        --cluster-name "$CLUSTER_NAME" \
        --principal-arn "$SSO_ROLE_ARN" \
        --policy-arn "$POLICY_ARN" \
        --access-scope type=cluster \
        --region "$REGION"
    echo "Policy associated"
fi

# Update kubeconfig
echo ""
echo "Updating kubeconfig..."
aws eks update-kubeconfig \
    --region "$REGION" \
    --name "$CLUSTER_NAME"

echo ""
echo "=== Configuration Complete ==="
echo "You can now use kubectl to access the cluster"
echo ""
