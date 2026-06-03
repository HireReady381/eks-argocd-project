# Prerequisites Setup Guide

## Tools to install on your Ubuntu server

### AWS CLI
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

### kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
kubectl version --client
```

### eksctl
```bash
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin/
eksctl version
```

### Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

## AWS IAM Policies required for user

Attach these policies to your IAM user:
- AmazonEC2FullAccess
- AmazonVPCFullAccess
- AmazonEKSClusterPolicy
- AmazonEKSWorkerNodePolicy
- IAMFullAccess
- AWSCloudFormationFullAccess
- Custom EKSFullAccess (eks:*)

## Configure AWS credentials
```bash
aws configure
# Enter: Access Key, Secret Key, Region (ap-south-1), Format (json)
aws sts get-caller-identity   # verify
```
