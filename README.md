# EKS + Helm + ArgoCD — GitOps Practice Project

A complete hands-on project to learn **EKS**, **Helm**, and **ArgoCD** by deploying a payment microservice using full GitOps automation.

> 🎥 Built for the YouTube tutorial series by [@HireReady381](https://github.com/HireReady381)

---

## What You Will Build

```
Developer pushes code
        ↓
GitHub (source of truth)
        ↓
ArgoCD detects change (every 3 min)
        ↓
Helm renders chart → kubectl apply
        ↓
EKS rolling update → zero downtime
```

---

## Project Structure

```
eks-argocd-project/
├── eksctl/
│   └── cluster.yaml              # EKS cluster definition (eksctl)
├── terraform/
│   ├── main.tf                   # VPC + EKS + ArgoCD via Terraform
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── helm/
│   ├── argocd-values.yaml        # ArgoCD Helm configuration
│   ├── argocd-apps/
│   │   └── demo-app.yaml         # ArgoCD Application manifest
│   └── charts/
│       └── payment-service/      # Payment service Helm chart
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│               └── deployment.yaml
├── docs/
│   └── SETUP.md                  # Prerequisites installation guide
└── README.md
```

---

## Prerequisites

| Tool    | Version  | Install guide          |
|---------|----------|------------------------|
| AWS CLI | >= 2.x   | See docs/SETUP.md      |
| eksctl  | latest   | See docs/SETUP.md      |
| kubectl | >= 1.29  | See docs/SETUP.md      |
| Helm    | >= 3.x   | See docs/SETUP.md      |

AWS IAM user needs these policies — see `docs/SETUP.md` for full list.

---

## Step-by-Step Practice Guide

### Step 1 — Clone this repo

```bash
git clone https://github.com/HireReady381/eks-argocd-project.git
cd eks-argocd-project
```

---

### Step 2 — Get your VPC and subnet IDs

```bash
# List your VPCs
aws ec2 describe-vpcs --query "Vpcs[*].[VpcId,CidrBlock]" --output table

# List subnets in your VPC (replace VPC_ID)
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=YOUR_VPC_ID" \
  --query "Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,MapPublicIpOnLaunch]" \
  --output table
```

Pick 2 public subnets (MapPublicIpOnLaunch = True) from different AZs.

---

### Step 3 — Update cluster.yaml

```bash
nano eksctl/cluster.yaml
```

Replace these values:
- `vpc-REPLACE_YOUR_VPC_ID` → your VPC ID
- `subnet-REPLACE_AZ1` → subnet in AZ-a
- `subnet-REPLACE_AZ2` → subnet in AZ-b
- `region: ap-south-1` → your region (if different)

---

### Step 4 — Create EKS cluster

```bash
eksctl create cluster -f eksctl/cluster.yaml
```

⏱️ Takes 15–20 minutes. When done you will see:
```
✔  EKS cluster "argocd-demo" in "ap-south-1" region is ready
```

---

### Step 5 — Verify cluster

```bash
aws eks update-kubeconfig --region ap-south-1 --name argocd-demo
kubectl get nodes
kubectl get pods -A
```

Expected: nodes with `STATUS = Ready`

---

### Step 6 — Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Watch pods (wait until all Running)
kubectl get pods -n argocd -w
```

---

### Step 7 — Access ArgoCD UI

**Terminal 1 — keep open:**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**Terminal 2 — get password:**
```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

Open browser: `https://localhost:8080`
- Username: `admin`
- Password: output from above

---

### Step 8 — Deploy payment-service via ArgoCD

```bash
kubectl apply -f helm/argocd-apps/demo-app.yaml
```

Watch in ArgoCD UI:
```
Missing → OutOfSync → Syncing → Healthy ✅
```

Verify in cluster:
```bash
kubectl get pods -n payment-app
kubectl get svc -n payment-app
```

---

### Step 9 — Test GitOps (the fun part)

#### Test 1: AutoSync — change image tag
```bash
# Edit helm/charts/payment-service/values.yaml
# Change: tag: "1.25" → tag: "1.26"
git add .
git commit -m "feat: upgrade to nginx 1.26"
git push
# Watch ArgoCD UI — auto deploys in ~3 minutes
```

#### Test 2: SelfHeal — manual change gets reverted
```bash
# Manually scale to 4 replicas
kubectl scale deployment payment-service --replicas=4 -n payment-app
kubectl get pods -n payment-app   # shows 4 pods
# Wait 3 minutes — ArgoCD reverts back to 2
kubectl get pods -n payment-app   # back to 2 pods
```

#### Test 3: Rollback
```bash
# Option A — Helm rollback
helm rollback payment-service 1 -n payment-app

# Option B — Git revert (GitOps way)
git revert HEAD
git push
```

---

## Cleanup — Important!

```bash
# Delete EKS cluster (stops billing immediately)
eksctl delete cluster --region=ap-south-1 --name=argocd-demo

# Then terminate your EC2 instance from AWS console
```

---

## Cost Estimate

| Resource            | Cost/hour |
|---------------------|-----------|
| EKS control plane   | ~$0.10    |
| m7i-flex.large node | ~$0.10    |
| EC2 t3.micro (jump) | ~$0.012   |
| **Total**           | ~$0.21/hr |

For a 2-hour practice session: **~$0.42 (~₹35)**

---

## Key Concepts Covered

| Concept | Tool | What you learn |
|---|---|---|
| Managed Kubernetes | EKS | Control plane, node groups, kubeconfig |
| Package management | Helm | Charts, templates, values, rollback |
| GitOps | ArgoCD | Sync, selfHeal, prune, drift detection |
| IaC | Terraform | VPC, EKS, Helm provider |
| CI/CD | eksctl | Cluster lifecycle management |

---

## Interview Questions Practised

After completing this project you can answer:
- What is the difference between EKS and self-managed Kubernetes?
- How does ArgoCD detect and fix configuration drift?
- What is selfHeal and prune in ArgoCD?
- How do you do a zero-downtime deployment with Helm + EKS?
- What is the GitOps deployment flow end to end?

---

## Author

**Sandeep** | Senior DevOps/DevSecOps Engineer
- GitHub: [@HireReady381](https://github.com/HireReady381)
- Twitter/X: [@DLearner59955](https://twitter.com/DLearner59955)

---

⭐ Star this repo if it helped you!
