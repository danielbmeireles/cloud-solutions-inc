# 🚀 CI/CD Pipeline

CI/CD is implemented using GitHub Actions for automated testing and deployment.

The GitHub Actions workflow provides:

1. **Validation**: Format check and terraform validate on all PRs
2. **Planning**: Automatic plan with PR comments showing changes
3. **Deployment**: Automatic apply on merge to main branch
4. **Outputs**: Deployment summary with cluster details

## 📄 Workflow File

Located at `.github/workflows/terraform-deploy.yml`

## 🔐 AWS Authentication Setup

The pipeline uses OIDC (OpenID Connect) for secure authentication with AWS, eliminating the need for long-lived credentials.

### 🔗 Setting Up OIDC Connection Between GitHub and AWS

#### 1️⃣ Create the OIDC Identity Provider in AWS

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

#### 2️⃣ Create IAM Role for GitHub Actions

Create a trust policy file `github-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

Create the IAM role:

```bash
aws iam create-role \
  --role-name GitHubActionsRole \
  --assume-role-policy-document file://github-trust-policy.json
```

#### 3️⃣ Attach Required Permissions

Attach the necessary policies for Terraform operations:

```bash
# For full admin access (development/testing)
aws iam attach-role-policy \
  --role-name GitHubActionsRole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# For production, create a custom policy with minimal required permissions
```

#### 4️⃣ Configure GitHub Repository

Add the following as GitHub repository variables/secrets:

**Variables**:
- `AWS_REGION`: Your AWS region (e.g., `us-east-1`)
- `TF_STATE_BUCKET`: S3 bucket name for Terraform state

**Secrets**:
- `AWS_ROLE_ARN`: The ARN of the IAM role created above (e.g., `arn:aws:iam::123456789012:role/GitHubActionsRole`)

#### 5️⃣ Verify the Configuration

The workflow uses the `aws-actions/configure-aws-credentials@v4` action which automatically handles OIDC authentication. When a workflow runs, GitHub generates a short-lived OIDC token that AWS exchanges for temporary credentials.

### ✨ Benefits of OIDC Authentication

- ✅ No long-lived credentials stored in GitHub
- ✅ Automatic credential rotation
- ✅ Fine-grained access control per repository/branch
- ✅ Enhanced security posture
- ✅ Audit trail through AWS CloudTrail

---

**Built with ❤️ for Cloud Solutions Inc.**
