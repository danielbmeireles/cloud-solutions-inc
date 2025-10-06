# CI/CD Pipeline

CI/CD is implemented using GitHub Actions for automated testing and deployment.

The GitHub Actions workflow provides:

1. **Validation**: Format check and terraform validate on all PRs
2. **Planning**: Automatic plan with PR comments showing changes
3. **Deployment**: Automatic apply on merge to main branch
4. **Outputs**: Deployment summary with cluster details

## Workflow File

Located at `.github/workflows/terraform-deploy.yml`

**Required GitHub Secrets**:
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `AWS_REGION`: AWS region
- `TF_STATE_BUCKET`: S3 bucket name for Terraform state

---

**Built with ❤️ for Cloud Solutions Inc.**
