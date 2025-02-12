data "aws_instance" "app_node" {
  depends_on = [aws_eks_node_group.main]
  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.main.node_group_name]
  }
}

output "node_id" {
  value = data.aws_instance.app_node.id
}