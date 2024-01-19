#!/usr/bin/env bash
set -eo pipefail

cluster_role=$1

instance_name=$(jq -er .instance_name "$cluster_role".auto.tfvars.json)
export AWS_ACCOUNT_ID=$(jq -er .aws_account_id "$cluster_role".auto.tfvars.json)
export AWS_ASSUME_ROLE=$(jq -er .aws_assume_role "$cluster_role".auto.tfvars.json)
export AWS_REGION=$(jq -er .aws_region "$cluster_role".auto.tfvars.json)
export AWS_ACCESSS_KEY_ID_ORIG=$AWS_ACCESSS_KEY_ID
export AWS_SECRET_ACCESSS_KEY_ORIG=$AWS_SECRET_ACCESSS_KEY

ROLE_SESSION_NAME="poc-platform-eks-base-$(date +%s)"
aws sts assume-role --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ASSUME_ROLE --role-session-name "$ROLE_SESSION_NAME" > assumed-role-output.json

export AWS_ACCESS_KEY_ID=$(cat assumed-role-output.json | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat assumed-role-output.json | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat assumed-role-output.json | jq -r ".Credentials.SessionToken")

# update kubeconfig based on assume-role
aws eks update-kubeconfig --name "$instance_name" \
--region "$AWS_REGION" \
--role-arn arn:aws:iam::"${AWS_ACCOUNT_ID}":role/"${AWS_ASSUME_ROLE}" --alias "$instance_name" \
--kubeconfig "~/.kube/config"

# apply eks-base cluster resources
# poc-system namespace
kubectl apply -f tpl/poc-system-namespace.yaml

# oidc core-team clusterrolebinding
kubectl apply -f tpl/admin-clusterrolebinding.yaml
