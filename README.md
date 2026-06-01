# eks-argocd-project

Terraform project to provision an **EKS cluster** on AWS and install **ArgoCD** via Helm for GitOps-based deployments.

---

## Project Structure

```
eks-argocd-project/
├── terraform/
│   ├── main.tf              # VPC + EKS + ArgoCD Helm release
│   ├── variables.tf         # All input variables
│   ├── outputs.tf           # Useful post-apply outputs
│   └── terraform.tfvars     # Default values (ap-south-1, demo-eks)
├── helm/
│   ├── argocd-values.yaml           # ArgoCD Helm configuration
│   ├── argocd-apps/
│   │   └── demo-app.yaml            # ArgoCD Application manifest
│   └── charts/
│       └── demo-app/                # Sample Helm chart (nginx)
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               └── deployment.yaml
└── .gitignore
```

---

## What Gets Created

| Resource | Details |
|---|---|
| VPC | 10.0.0.0/16, 2 AZs, public + private subnets |
| NAT Gateway | Single (cost-saving) |
| EKS Cluster | v1.29, public endpoint |
| Node Group | 2× t3.medium (scales 1–3) |
| ArgoCD | Helm chart 7.3.4, namespace: argocd |
| Demo App | nginx, deployed via ArgoCD GitOps |

---

## Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.5.0
- kubectl
- Helm >= 3.x

---

## Step-by-Step Usage

### Step 1 — Clone the repo

```bash
git clone https://github.com/HireReady381/eks-argocd-project.git
cd eks-argocd-project
```

### Step 2 — Initialize Terraform

```bash
cd terraform/
terraform init
```

### Step 3 — Review the plan

```bash
terraform plan
```

### Step 4 — Apply (creates VPC + EKS + ArgoCD)

```bash
terraform apply
# Takes ~12–15 minutes
```

### Step 5 — Configure kubectl

```bash
aws eks update-kubeconfig --region ap-south-1 --name demo-eks
kubectl get nodes
```

### Step 6 — Verify ArgoCD pods

```bash
kubectl get pods -n argocd
```

### Step 7 — Access ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open: **https://localhost:8080**
Username: `admin`
Password:
```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d
```

### Step 8 — Deploy the demo app via ArgoCD

```bash
kubectl apply -f helm/argocd-apps/demo-app.yaml
```

ArgoCD will automatically sync and deploy the nginx demo app into the `demo-app` namespace.

---

## Cleanup

```bash
cd terraform/
terraform destroy
```

---

## Key Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | ap-south-1 | AWS region |
| `cluster_name` | demo-eks | EKS cluster name |
| `cluster_version` | 1.29 | Kubernetes version |
| `node_instance_type` | t3.medium | Worker node type |
| `argocd_chart_version` | 7.3.4 | ArgoCD Helm chart version |
