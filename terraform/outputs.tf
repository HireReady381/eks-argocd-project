output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = module.eks.cluster_version
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs (worker nodes)"
  value       = module.vpc.private_subnets
}

output "configure_kubectl" {
  description = "Command to update kubeconfig for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_port_forward" {
  description = "Port-forward command to access ArgoCD UI locally"
  value       = "kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

output "argocd_get_password" {
  description = "Command to retrieve the ArgoCD initial admin password"
  value       = "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d"
}
