set -eo pipefail

cluster_role=$1

instance_name=$(jq -er .instance_name "$cluster_role".auto.tfvars.json)
management_node_group_name=$(jq -er .management_node_group_name "$cluster_role".auto.tfvars.json)
export AWS_ACCOUNT_ID=$(jq -er .aws_account_id "$cluster_role".auto.tfvars.json)
export AWS_ASSUME_ROLE=$(jq -er .aws_assume_role "$cluster_role".auto.tfvars.json)
export AWS_REGION=$(jq -er .aws_region "$cluster_role".auto.tfvars.json)

echo "DEBUG:"
echo "instance_name = ${instance_name}"
echo "management_node_group_name = ${management_node_group_name}"
echo "AWS_REGION = ${AWS_REGION}"

# this setting results in the nodes in the management node being replaced with the latest EKS-optimized AMI
# for the eks version deployed. This is a zero-downtime refresh.
echo -n "Apply taint to managed node group"
terraform taint "module.eks.module.eks_managed_node_group[\"${management_node_group_name}\"].aws_eks_node_group.this[0]"
                