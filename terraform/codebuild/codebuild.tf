
data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "grpc_registry" {
  name                 = "grpc_registry"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
           Effect = "Allow",
            Principal = {
             AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/codebuild-role"
           },
           Action = "sts:AssumeRole"
         },
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-policy-adn"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "*",
        Resource = "*"
      },
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Resource  = aws_iam_role.codebuild_role.arn
      }
    ]
  })
}

data "aws_iam_policy" "eks_access" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_iam_role_policy_attachment" "eks_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = data.aws_iam_policy.eks_access.arn
}

resource "aws_iam_policy_attachment" "codebuild_ecr_access" {
  name       = "codebuild-ecr-access"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}


resource "aws_codebuild_project" "grpc_codebuild" {
  name          = "grpc-codebuild"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    privileged_mode = true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name = "IMAGE_NAME"
      value = "grpc-app"
    }
    environment_variable {
      name = "AWS_REGION"
      value = var.region
    }
    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "EKS_CLUSTER"
      value = var.eks_cluster_name
    }
    environment_variable {
      name  = "ECR_REPOSITORY"
      value = aws_ecr_repository.grpc_registry.name
    }
    environment_variable {
      name  = "EKS_KUBECTL_ROLE_ARN"
      value = aws_iam_role.codebuild_role.arn
    }

  }
  source {
    type            = "GITHUB"
    location        = "https://github.com/JulianaLeonGonzalez/GRCP-EKS.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }
}



