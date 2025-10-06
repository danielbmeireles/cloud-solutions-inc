# Architecture Overview <!-- omit in toc -->

This document describes the architecture and design decisions for the Cloud Solutions Inc. infrastructure.

## Table of Contents <!-- omit in toc -->

- [Infrastructure Components](#infrastructure-components)
- [Key Design Decisions](#key-design-decisions)
- [Modules](#modules)

## Infrastructure Components

This infrastructure implements a highly available, multi-AZ architecture on AWS with the following components:

### Compute Resources

- **Amazon EKS Cluster**: Managed Kubernetes control plane for orchestrating containerized applications
- **EKS Node Group**: Auto-scaling worker nodes running on EC2 instances
- **Auto Scaling**: Dynamic node scaling based on workload demands
- **Kubernetes Version**: 1.31 (configurable)

#### Kubernetes Add-ons

- **VPC CNI**: Native VPC networking for Kubernetes pods
- **CoreDNS**: Cluster DNS service
- **kube-proxy**: Network proxy for Kubernetes services
- **EBS CSI Driver**: Persistent volume support using Amazon EBS
- **AWS Load Balancer Controller**: Integration with AWS ALB/NLB (IAM role configured)

### Network Layer

- **VPC**: Isolated network environment with custom CIDR block
- **Multi-AZ Design**: Resources distributed across 3 availability zones for high availability
- **Public Subnets**: Host NAT gateways and optionally Load Balancers
- **Private Subnets**: Host EKS worker nodes for enhanced security
- **NAT Gateways**: Enable outbound internet access for private resources
- **VPC Flow Logs**: Network traffic monitoring for security and troubleshooting

### Storage

- **S3 Bucket**: Object storage with versioning, encryption, and lifecycle policies
  - Automatic transition to Infrequent Access storage after 30 days
  - Glacier archival after 90 days
  - Encrypted at rest with AES-256
- **EFS File System**: Shared persistent storage for containers
  - Encrypted at rest
  - Lifecycle management to Infrequent Access storage
  - Mount targets in each availability zone
  - Ready for EFS CSI Driver integration
- **EBS Volumes**: Persistent block storage via EBS CSI Driver

### Monitoring and Logging

- **CloudWatch Logs**: Centralized logging for EKS control plane and applications
- **CloudWatch Dashboard**: Real-time visualization of cluster metrics
- **SNS Notifications**: Email alerts for critical issues (optional)
- **Control Plane Logging**: API, audit, authenticator, controller manager, and scheduler logs

### Security Features

#### Network Security
- **Security Groups**: Fine-grained network access control
  - EKS control plane isolated with managed security group
  - Worker nodes in private subnets
  - EFS only accessible from worker nodes
  - ALB security groups restrict traffic to HTTP/HTTPS
- **Private Subnets**: Worker nodes isolated from direct internet access
- **VPC Flow Logs**: Network traffic monitoring for security auditing

#### Identity and Access Management
- **IAM Roles**: Least-privilege access with IRSA (IAM Roles for Service Accounts)
  - OIDC provider configured for pod-level IAM roles
  - Pre-configured roles for AWS Load Balancer Controller and EBS CSI Driver
  - Separate IAM roles for cluster and node groups
- **IMDSv2**: Enforced on all EC2 instances for enhanced metadata security

#### Encryption at Rest
All data is encrypted at rest using industry-standard encryption:
- **Kubernetes Secrets**: Encrypted using AWS KMS with automatic key rotation
  - Custom KMS key: `${project_name}-${environment}-eks-key`
  - 10-day deletion window for key recovery
- **EBS Volumes**: All node volumes encrypted with dedicated KMS key
  - Custom KMS key: `${project_name}-${environment}-ebs-key`
  - Uses gp3 volumes for better performance
  - Automatic key rotation enabled
- **S3 Bucket**: Server-side encryption with AES-256
  - All objects encrypted by default
  - Versioning enabled for data protection
- **EFS File System**: Encrypted at rest using AWS-managed encryption
  - Automatic encryption of all data and metadata

#### Encryption in Transit
- **EKS API Server**: All communications use TLS 1.2+
- **Node-to-Control Plane**: Encrypted communication via AWS PrivateLink
- **Application Traffic**: HTTPS/TLS supported via AWS Load Balancer Controller
- **S3 Transfer**: SSL/TLS enforced for all data transfers
- **EFS Mount**: Data encrypted in transit using TLS

## Key Design Decisions

1. **EKS over Self-Managed Kubernetes**: AWS-managed control plane eliminates operational overhead
2. **Multi-AZ**: High availability across 3 availability zones
3. **Private Node Groups**: Enhanced security by isolating worker nodes
4. **Managed Node Groups**: Simplified node lifecycle management and updates
5. **IRSA Support**: Pod-level IAM roles for fine-grained permissions
6. **EKS Add-ons**: Managed versions of critical Kubernetes components
7. **End-to-End Encryption**: KMS encryption for secrets and EBS, encryption in transit for all communications
8. **IMDSv2 Enforcement**: Enhanced EC2 metadata security on all nodes
9. **Modular Design**: Reusable modules for different environments
10. **Infrastructure as Code**: Version-controlled, repeatable deployments
11. **CI/CD Integration**: Automated testing and deployment pipeline

## Modules

The infrastructure is organized into reusable modules:


| Name                                        | Description                                                          |
| ------------------------------------------- | -------------------------------------------------------------------- |
| [kms](../modules/kms/main.tf)               | Centralized encryption key management with automatic rotation        |
| [vpc](../modules/vpc/main.tf)               | Networking infrastructure (VPC, subnets, NAT gateways, route tables) |
| [eks](../modules/eks/main.tf)               | EKS cluster, node groups, OIDC provider, and IAM roles               |
| [alb](../modules/alb/main.tf)               | Security groups for AWS Load Balancer Controller                     |
| [storage](../modules/storage/main.tf)       | S3 buckets and EFS file systems with encryption                      |
| [monitoring](../modules/monitoring/main.tf) | CloudWatch logs, dashboards, and SNS topics                          |

---

**Built with ❤️ for Cloud Solutions Inc.**
