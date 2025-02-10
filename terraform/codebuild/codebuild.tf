
data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "grpc_registry" {
  name                 = "grpc_registry"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = false
  }
}

data "aws_iam_policy_document" "build_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "build-role" {
  name               = "codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.build_assume_role.json
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild-policy-adn"
  role = aws_iam_role.build-role.id

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
        Resource  = "${aws_iam_role.build-role.arn}"
      }
    ]
  })
}



resource "aws_iam_policy" "build-ecr" {
  name = "ECRPOLICY"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
    ],
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_policy" "eks-access" {
  name = "EKS-access"
  policy = jsonencode({
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "eks:DescribeCluster"
        ],
        "Resource": "*"
      }
    ],
    "Version": "2012-10-17",
  } )
}

resource "aws_iam_role_policy_attachment" "eks" {
  role = aws_iam_role.build-role.name
  policy_arn = aws_iam_policy.eks-access.arn
}
resource "aws_iam_role_policy_attachment" "ecr" {
  role = aws_iam_role.build-role.name
  policy_arn = aws_iam_policy.build-ecr.arn
}
resource "aws_iam_policy_attachment" "codebuild_s3_access" {
  name       = "codebuild-s3-access"
  roles      = [aws_iam_role.build-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "codebuild_ecr_access" {
  name       = "codebuild-ecr-access"
  roles      = [aws_iam_role.build-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}


resource "aws_codebuild_project" "grpc_codebuild" {
  name          = "grpc-codebuild"
  build_timeout = "10"
  service_role  = aws_iam_role.build-role.arn

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
      value = aws_iam_role.build-role.arn
    }

  }
  source {
    type            = "GITHUB"
    location        = "https://github.com/JulianaLeonGonzalez/GRCP-EKS.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
  }
}



