# poc-platform-eks-base.

Responsible for:  

1. EKS baseline cluster control plane configuration.  
2. AWS managed node group for management-only services (management-x86-al2-mng).  
3. AWS managed addons (EKS addon services managed by AWS)
   - kube-proxy
   - aws-cni
   - coredns
   - aws-ebs-csi-driver
4. Common node role for cluster-wide management services (such as Karpenter).
5. Baseline kubernetes resources
   - poc-system namespace (used for test fixtures and services)
   - admin-clusterrolebinding (for admin oidc team members) 

### maintainer notes  

1. terraform apply includes taint of mnagement node group to trigger refresh onto current EKS optimized node patch level.  
   
2. post-terraform-apply-configuration script does the following:

Cluster identifiers are written to secretsmanager: (not _secret_ values)  
- kubeconfig for service account assume-role-auth attempt  
- cluster kuebrnetes api url  
- cluster public certificate  

Baseline kubernetes resources are applied:  
- poc-system namespace
- admin-clusterrolebinding tied to aws-engineering-poc/core-team claim
