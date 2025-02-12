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
    bucket = "terraformgrpcmicroservice" # Nombre del bucket de S3
    key = "terraform-state/terraform.tfstate" # Ruta/path/key en el bucket de S3
    region = "us-east-1" # Región de AWS donde se encuentra el bucket
   # dynamodb_table = "" # Descomentar esta línea e indicar la tabla de DaynamoDB para habilitar el bloqueo de estado
    encrypt = true
  }
}