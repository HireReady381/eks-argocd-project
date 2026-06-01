# Override defaults here — safe to commit (no secrets)

aws_region         = "ap-south-1"
cluster_name       = "demo-eks"
cluster_version    = "1.29"
node_instance_type = "t3.medium"

vpc_cidr        = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

argocd_chart_version = "7.3.4"

tags = {
  Project     = "eks-argocd"
  ManagedBy   = "Terraform"
  Environment = "dev"
  Owner       = "DevOps"
}
