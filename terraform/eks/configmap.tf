/*
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = var.eks_cluster_name
  }

  data = {
    mapRoles = <<EOF
- rolearn: arn:aws:iam::908642484012:role/grpc-cluster-worker
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: arn:aws:iam::908642484012:role/codebuild-role
  username: admin
  groups:
    - system:masters
    - eks-console-dashboard-full-access-group
EOF
  }
}
 */