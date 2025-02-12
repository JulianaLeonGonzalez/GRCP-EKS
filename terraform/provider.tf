provider "aws" {
  region = var.region
}
provider "kubernetes" {
  config_path    = "~/.kube/config"
}
terraform {

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
  backend "s3" {
    bucket = "terraformgrpcmicroservice"
    key = "terraform-state/terraform.tfstate"
    region = "us-east-1"
   # dynamodb_table = ""
    encrypt = true
  }
}