variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type = string
}

variable "region" {
  description = "aws region to deploy to"
  type        = string
}