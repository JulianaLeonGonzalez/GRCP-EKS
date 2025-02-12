variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type = string
}

variable "region" {
  description = "AWS region to deploy to"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry name for the container image"
  type        = string
  default = "grpc-registry"
}

variable "codebuild_project" {
  description = "CodeBuild project name"
  type        = string
  default = "grpc-registry"
}