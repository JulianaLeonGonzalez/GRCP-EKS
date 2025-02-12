
variable "region" {
  description = "AWS region to deploy to"
  default = "us-east-1"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  default = "grpc-cluster"
  type = string
}

variable "public_instances" {
  description = "Desired number of public instances available for the EKS cluster. Max:3"
  default = 1
  type = number
}

variable "private_instances" {
  description = "Desired number of private instances available for the EKS cluster. Max:3"
  default = 1
  type = number
}