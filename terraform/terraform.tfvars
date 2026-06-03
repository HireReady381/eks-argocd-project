aws_region         = "ap-south-1"
cluster_name       = "argocd-demo"
cluster_version    = "1.32"
node_instance_type = "m7i-flex.large"
argocd_chart_version = "7.3.4"

tags = {
  Project     = "eks-argocd"
  ManagedBy   = "Terraform"
  Environment = "dev"
  Owner       = "DevOps"
}
