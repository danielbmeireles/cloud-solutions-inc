# AWS Configuration
aws_region   = "eu-west-1"
environment  = "production"
project_name = "cloud-solutions"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# EKS Cluster Configuration
kubernetes_version = "1.34"

# Restrict access to the Kubernetes API server (optional)
# cluster_endpoint_public_access_cidrs = ["YOUR_IP/32"]

# EKS Control Plane Logging
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

# EKS Node Group Configuration
node_instance_types = ["t3.medium"] # Options: t3.small, t3.medium, t3.large, m5.large, etc.
capacity_type       = "SPOT"        # Options: ON_DEMAND, SPOT
node_disk_size      = 20            # Disk size in GiB

# Node Group Scaling
desired_size = 2 # Initial number of nodes
min_size     = 1 # Minimum number of nodes
max_size     = 4 # Maximum number of nodes (auto-scaling)

# EKS Addon Versions (update as needed)
vpc_cni_addon_version    = "v1.20.1-eksbuild.3"
coredns_addon_version    = "v1.12.3-eksbuild.1"
kube_proxy_addon_version = "v1.34.0-eksbuild.2"
ebs_csi_addon_version    = "v1.49.0-eksbuild.1"

# Monitoring and Alerting (Optional)
# Uncomment to receive email alerts for critical issues
alarm_email = "cloud-solutions@meireles.dev"
