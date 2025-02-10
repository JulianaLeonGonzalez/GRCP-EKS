# VPC for EKS
module "vpc_for_eks" {
  source = "./vpc"
  eks_cluster_name = var.cluster_name
  vpc_tag_name = "${var.cluster_name}-vpc"
}

module "codebuild" {
  source = "./codebuild"
  eks_cluster_name = var.cluster_name
  region = var.region
}

# EKS Cluster
module "eks_cluster_and_worker_nodes" {
  source = "./eks"
  vpc_id = module.vpc_for_eks.vpc_id
  cluster_sg_name = "${var.cluster_name}-cluster-sg"
  nodes_sg_name = "${var.cluster_name}-node-sg"
  eks_cluster_name = var.cluster_name
  eks_cluster_subnet_ids = flatten([module.vpc_for_eks.public_subnet_ids, module.vpc_for_eks.private_subnet_ids])
  pvt_desired_size = 1
  pvt_max_size = 1
  pvt_min_size = 1
  pblc_desired_size = 1
  pblc_max_size = 1
  pblc_min_size = 1
  endpoint_private_access = true
  endpoint_public_access = true
  node_group_name = "${var.cluster_name}-node-group"
  private_subnet_ids = module.vpc_for_eks.private_subnet_ids
  public_subnet_ids = module.vpc_for_eks.public_subnet_ids
}