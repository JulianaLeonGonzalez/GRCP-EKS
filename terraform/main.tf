#This is the main file where we are calling all the modules

#This module creates the necessary networking resources for the eks cluster
module "vpc_for_eks" {
  source = "./networking"
  eks_cluster_name = var.cluster_name
  vpc_tag_name = "${var.cluster_name}-vpc"
}

#This module creates an codebuild project for deploying the microservices
module "codebuild" {
  source = "./codebuild"
  eks_cluster_name = var.cluster_name
  region = var.region
}

#This module creates an EKS Cluster
module "eks_cluster_and_worker_nodes" {
  source = "./eks"
  vpc_id = module.vpc_for_eks.vpc_id
  cluster_sg_name = "${var.cluster_name}-cluster-sg"
  nodes_sg_name = "${var.cluster_name}-node-sg"
  eks_cluster_name = var.cluster_name
  eks_cluster_subnet_ids = flatten([module.vpc_for_eks.public_subnet_ids, module.vpc_for_eks.private_subnet_ids])
  pvt_desired_size = var.private_instances
  pvt_max_size = 3
  pvt_min_size = 1
  pblc_desired_size = var.public_instances
  pblc_max_size = 3
  pblc_min_size = 1
  endpoint_private_access = true
  endpoint_public_access = true
  node_group_name = "${var.cluster_name}-node-group"
  private_subnet_ids = module.vpc_for_eks.private_subnet_ids
  public_subnet_ids = module.vpc_for_eks.public_subnet_ids
}

#This module creates the ALB for exposing the EKS microservices
/*
module "alb"{
  source = "./alb"
  node_id = module.eks_cluster_and_worker_nodes.node_id
  vpc_id = module.vpc_for_eks.vpc_id
  public_subnet_ids = module.vpc_for_eks.public_subnet_ids
  public_sg_id= module.vpc_for_eks.public_subnet_security_group_id
}
 */