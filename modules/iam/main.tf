resource "aws_iam_role" "ec2_role_ecommerce_frontend" {
  name = "ec2-ecr-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.frontend_ec2_role_tags
}

resource "aws_iam_policy" "ec2_policy_access_ecr" {
  name        = "ec2-ecr-policy"
  description = "Allow EC2 to access ECR and upload to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ECR Login Permission
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },

      # ECR Pull/Push
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = var.ecr_repository_arn
      },

    ]
  })
  tags = local.frontend_ec2_policy_tags
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role_ecommerce_frontend.name
  policy_arn = aws_iam_policy.ec2_policy_access_ecr.arn
}

output "frontend_ec2_access_ecr_role" {
  value = aws_iam_role.ec2_role_ecommerce_frontend.name
}