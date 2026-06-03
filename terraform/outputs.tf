output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "configure_kubectl" {
  description = "Run this to update kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "argocd_port_forward" {
  description = "Access ArgoCD UI"
  value       = "kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

output "argocd_get_password" {
  description = "Get ArgoCD admin password"
  value       = "kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d"
}
