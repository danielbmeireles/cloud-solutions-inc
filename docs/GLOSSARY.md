# 📖 Glossary <!-- omit in toc -->

Comprehensive glossary of terms, acronyms, and concepts used in the Cloud Solutions Inc. infrastructure.

## 📑 Table of Contents <!-- omit in toc -->

- [AWS Services](#aws-services)
- [Kubernetes & Container Terms](#kubernetes--container-terms)
- [Terraform Terms](#terraform-terms)
- [Networking Terms](#networking-terms)
- [Security & IAM Terms](#security--iam-terms)
- [DevOps & CI/CD Terms](#devops--cicd-terms)
- [Project-Specific Terms](#project-specific-terms)

## AWS Services

### ACM (AWS Certificate Manager)
AWS service that provides free SSL/TLS certificates with automatic renewal. Used for securing custom domains with HTTPS.

**See:** [ArgoCD Custom Domain Setup](ARGOCD.md#-custom-domain-setup-with-ssltls)

### ALB (Application Load Balancer)
Layer 7 load balancer that routes HTTP/HTTPS traffic to targets based on request content. Automatically provisioned by AWS Load Balancer Controller from Kubernetes Ingress resources.

**See:** [AWS Load Balancer Controller](AWS_LOAD_BALANCER_CONTROLLER.md)

### CloudWatch
AWS monitoring and observability service that collects metrics, logs, and events from AWS resources and applications.

**See:** [Architecture - Monitoring](ARCHITECTURE.md#-monitoring)

### EBS (Elastic Block Store)
Block storage volumes for EC2 instances. Used for persistent storage in EKS node groups.

**See:** [EKS Configuration](EKS.md)

### EC2 (Elastic Compute Cloud)
Virtual servers in AWS. EKS worker nodes run as EC2 instances.

**See:** [EKS Node Groups](EKS.md#node-groups)

### EFS (Elastic File System)
Fully managed NFS file system that can be shared across multiple EC2 instances or containers.

**See:** [Architecture - Infrastructure Components](ARCHITECTURE.md#infrastructure-components)

### EKS (Elastic Kubernetes Service)
AWS managed Kubernetes service that runs the Kubernetes control plane.

**See:** [EKS Documentation](EKS.md)

### IAM (Identity and Access Management)
AWS service for managing access to AWS resources through users, groups, roles, and policies.

**See:** [Security & IAM Terms](#security--iam-terms)

### IMDSv2 (Instance Metadata Service Version 2)
Enhanced version of EC2 metadata service with session-oriented authentication for improved security.

**See:** [EKS Security](EKS.md#-security-best-practices)

### KMS (Key Management Service)
AWS service for creating and managing encryption keys. Used for encrypting EKS secrets and EBS volumes.

**See:** [Architecture - Security](ARCHITECTURE.md#encryption)

### NLB (Network Load Balancer)
Layer 4 load balancer that routes TCP/UDP traffic based on IP protocol data.

**See:** [AWS Load Balancer Controller](AWS_LOAD_BALANCER_CONTROLLER.md)

### S3 (Simple Storage Service)
Object storage service. Used for storing Terraform state files.

**See:** [Bootstrap](BOOTSTRAP.md)

### SNS (Simple Notification Service)
Pub/sub messaging service for sending notifications. Used for CloudWatch alarms.

**See:** [Architecture - Monitoring](ARCHITECTURE.md#-monitoring)

### VPC (Virtual Private Cloud)
Isolated virtual network in AWS where resources are deployed.

**See:** [Architecture - Infrastructure Components](ARCHITECTURE.md#infrastructure-components)

## Kubernetes & Container Terms

### ArgoCD
GitOps continuous delivery tool for Kubernetes. Automatically syncs application state from Git repositories.

**See:** [ArgoCD Documentation](ARGOCD.md)

### Container
Lightweight, standalone executable package that includes everything needed to run software.

### Deployment
Kubernetes resource that manages a replicated set of Pods, providing declarative updates.

### GitOps
Operational framework using Git as single source of truth for declarative infrastructure and applications.

**See:** [ArgoCD](ARGOCD.md)

### Helm
Package manager for Kubernetes. Uses charts to define, install, and upgrade Kubernetes applications.

**See:** [Kubernetes Infrastructure](KUBERNETES.md)

### Ingress
Kubernetes resource that manages external access to services, typically HTTP/HTTPS.

**See:** [AWS Load Balancer Controller](AWS_LOAD_BALANCER_CONTROLLER.md)

### Namespace
Virtual cluster within a Kubernetes cluster for resource isolation.

### Node
Worker machine in Kubernetes cluster. In EKS, nodes are EC2 instances.

**See:** [EKS Node Groups](EKS.md#node-groups)

### Pod
Smallest deployable unit in Kubernetes. Can contain one or more containers.

### Service
Kubernetes resource that exposes an application running as a set of Pods.

### ServiceAccount
Kubernetes identity for Pods to authenticate with the cluster and external services.

**See:** [IRSA](#irsa-iam-roles-for-service-accounts)

## Terraform Terms

### Backend
Configuration defining where Terraform stores state files. Typically S3 + DynamoDB for locking.

**See:** [Bootstrap](BOOTSTRAP.md)

### Data Source
Read-only reference to existing infrastructure. Used to fetch information without managing resources.

**Example:** Remote state data source
```hcl
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "my-bucket"
    key    = "terraform.tfstate"
  }
}
```

### Module
Reusable container for multiple resources that are used together.

**See:** [Terraform Documentation](TERRAFORM.md#-module-reference)

### Output
Value exported from a Terraform module or configuration.

**See:** [Terraform Outputs](TERRAFORM.md#-configuration)

### Provider
Plugin that enables Terraform to interact with APIs (AWS, Kubernetes, Helm, etc.).

### Resource
Infrastructure component managed by Terraform (EC2 instance, VPC, etc.).

### State
File tracking resource metadata and current infrastructure state.

**See:** [Terraform State Management](TERRAFORM.md#-best-practices)

### Variable
Input parameter for Terraform configuration.

### Workspace
Named state container allowing multiple state files for same configuration.

**See:** [Terraform Best Practices](TERRAFORM.md#-best-practices)

## Networking Terms

### AZ (Availability Zone)
Isolated location within an AWS region. Infrastructure spans multiple AZs for high availability.

**See:** [Architecture](ARCHITECTURE.md)

### CIDR (Classless Inter-Domain Routing)
IP address range notation (e.g., 10.0.0.0/16).

**Example:** VPC CIDR 10.0.0.0/16 provides 65,536 IP addresses

### DNS (Domain Name System)
System translating domain names to IP addresses.

**See:** [ArgoCD Custom Domain](ARGOCD.md#-custom-domain-setup-with-ssltls)

### NAT Gateway
AWS service enabling instances in private subnets to access the internet.

**See:** [VPC Module](../modules/vpc/README.md)

### Private Subnet
Subnet without direct internet access. Used for application and database workloads.

### Public Subnet
Subnet with internet gateway route. Used for load balancers and NAT gateways.

### Route Table
Set of rules (routes) determining network traffic direction.

### Security Group
Virtual firewall controlling inbound and outbound traffic to AWS resources.

**See:** [EKS Security](EKS.md#-security-best-practices)

### Subnet
Range of IP addresses within a VPC.

### TLS (Transport Layer Security)
Cryptographic protocol for secure communication. Successor to SSL.

**See:** [ArgoCD SSL/TLS](ARGOCD.md#-custom-domain-setup-with-ssltls)

## Security & IAM Terms

### AssumeRole
IAM action allowing an entity to obtain temporary credentials for a different role.

### IAM Policy
JSON document defining permissions for AWS actions and resources.

**Example:**
```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::bucket/*"
}
```

### IAM Role
Identity with specific permissions that can be assumed by trusted entities.

**See:** [IRSA](#irsa-iam-roles-for-service-accounts)

### IRSA (IAM Roles for Service Accounts)
Mechanism providing IAM credentials to Kubernetes pods via ServiceAccount annotations.

**See:** [EKS IRSA](EKS.md#iam-roles-for-service-accounts-irsa)

**Example:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-role
```

### OIDC (OpenID Connect)
Authentication protocol. Used for GitHub Actions → AWS authentication and EKS → IAM integration.

**See:** [CI/CD OIDC Setup](CICD.md#-aws-authentication-setup)

### RBAC (Role-Based Access Control)
Kubernetes authorization mechanism restricting access based on roles.

**See:** [EKS Security](EKS.md#-security-best-practices)

### Trust Policy
IAM policy document defining which principals can assume a role.

**Example:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.region.amazonaws.com/id/OIDC_ID"
    },
    "Action": "sts:AssumeRoleWithWebIdentity"
  }]
}
```

## DevOps & CI/CD Terms

### CI/CD (Continuous Integration / Continuous Deployment)
Automated practice of integrating code changes and deploying to production.

**See:** [CI/CD Documentation](CICD.md)

### GitHub Actions
CI/CD platform integrated with GitHub for automating workflows.

**See:** [CI/CD Pipeline](CICD.md)

### IaC (Infrastructure as Code)
Managing infrastructure through machine-readable definition files.

**See:** [Terraform Documentation](TERRAFORM.md)

### Workflow
Automated process defined in GitHub Actions YAML file.

**See:** [CI/CD Workflows](CICD.md#-workflow-files)

## Project-Specific Terms

### Bootstrap
Initial setup process for creating Terraform S3 backend and DynamoDB table.

**See:** [Bootstrap Guide](BOOTSTRAP.md)

### Infrastructure Layer
First deployment layer managing AWS infrastructure (VPC, EKS, IAM, KMS, EFS, CloudWatch).

**State:** `{env}/infra/terraform.tfstate`

**See:** [Architecture - Two-Pipeline](ARCHITECTURE.md#️-two-pipeline-architecture)

### Kubernetes Layer
Second deployment layer managing Kubernetes resources (ArgoCD, AWS Load Balancer Controller).

**State:** `{env}/kubernetes/terraform.tfstate`

**See:** [Architecture - Two-Pipeline](ARCHITECTURE.md#️-two-pipeline-architecture)

### Remote State
Terraform state stored in S3, accessible to other Terraform configurations via data sources.

**See:** [Terraform Remote State](TERRAFORM.md#-configuration)

### Two-Pipeline Architecture
Project architecture separating infrastructure and Kubernetes deployments into independent pipelines with separate state files.

**Benefits:**
- Independent deployments and rollbacks
- Reduced blast radius
- Cleaner dependency management

**See:** [Architecture Overview](ARCHITECTURE.md)

## Acronym Quick Reference

| Acronym | Full Term | Category |
|---------|-----------|----------|
| ACM | AWS Certificate Manager | AWS Service |
| ALB | Application Load Balancer | AWS Service |
| ARN | Amazon Resource Name | AWS |
| AZ | Availability Zone | AWS/Networking |
| CI/CD | Continuous Integration/Deployment | DevOps |
| CIDR | Classless Inter-Domain Routing | Networking |
| DNS | Domain Name System | Networking |
| EBS | Elastic Block Store | AWS Service |
| EC2 | Elastic Compute Cloud | AWS Service |
| EFS | Elastic File System | AWS Service |
| EKS | Elastic Kubernetes Service | AWS Service |
| gRPC | gRPC Remote Procedure Call | Technology |
| IAM | Identity and Access Management | AWS Service |
| IaC | Infrastructure as Code | DevOps |
| IMDSv2 | Instance Metadata Service v2 | AWS |
| IRSA | IAM Roles for Service Accounts | AWS/Kubernetes |
| KMS | Key Management Service | AWS Service |
| NLB | Network Load Balancer | AWS Service |
| OIDC | OpenID Connect | Security |
| RBAC | Role-Based Access Control | Kubernetes/Security |
| S3 | Simple Storage Service | AWS Service |
| SNS | Simple Notification Service | AWS Service |
| TLS | Transport Layer Security | Security |
| VPC | Virtual Private Cloud | AWS Service |

## Related Documentation

- [Architecture](ARCHITECTURE.md) - Infrastructure overview
- [EKS Documentation](EKS.md) - Kubernetes cluster guide
- [Terraform Reference](TERRAFORM.md) - IaC documentation
- [Troubleshooting](TROUBLESHOOTING.md) - Problem resolution

---

**Built with ❤️ for Cloud Solutions Inc.**
