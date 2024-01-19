#!/usr/bin/env bash
set -eo pipefail

cluster_role=$1

instance_name=$(jq -er .instance_name "$cluster_role".auto.tfvars.json)
#export AWS_REGION=us-east-1

# generate custom .teller.yml to write cluster identifiers
cat <<EOF > .teller.yml
project: poc-platform-eks-base

carry_env: true

opts:
  region: us-east-1

providers:
  aws_secretsmanager:
    env:
      CLUSTER_URL:
        path: poc/kubernetes/${instance_name}
        field: cluster-url

      CLUSTER_PUBLIC_CERTIFICATE_AUTHORITY_DATA:
        path: poc/kubernetes/${instance_name}
        field: cluster-public-certificate-authority-data

      KUBECONFIG_BASE64:
        path: poc/kubernetes/${instance_name}
        field: kubeconfig-base64

EOF

cat ~/.kube/config

# write kubeconfig to AWS secrets manager
teller put KUBECONFIG_BASE64="$(cat ~/.kube/config | base64)" --providers aws_secretsmanager -c .teller.yml

# # write cluster url and pubic certificate to AWS secrets manager
teller put CLUSTER_URL="$(terraform output -raw cluster_url)" --providers aws_secretsmanager -c .teller.yml
teller put CLUSTER_PUBLIC_CERTIFICATE_AUTHORITY_DATA="$(terraform output -raw cluster_public_certificate_authority_data)" --providers aws_secretsmanager -c .teller.yml
