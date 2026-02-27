resource "aws_iam_role" "ec2_role_ecommerce_frontend" {
  name = var.frontend_ec2_role_name

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

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-s3-profile"
  role = aws_iam_role.ec2_role_ecommerce_frontend.name
}

output "frontend_ec2_access_ecr_role" {
  value = aws_iam_instance_profile.ec2_profile.name
}


// The above code defines an IAM role for EC2 instances that allows them to access ECR and S3. It creates a policy with the necessary permissions and attaches it to the role. Finally, it creates an instance profile that can be associated with EC2 instances to grant them the defined permissions.
resource "aws_iam_role" "ec2_role_ecommerce_backend" {
  name = var.backend_ecr_s3_access_role_name

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

  tags = local.backend_ec2_role_tags
}

resource "aws_iam_policy" "ec2_policy_access_ecr_s3" {
  name        = "ec2-ecr-s3-policy"
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

      // access on s3 bucket for uploads
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
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
        Resource = var.ecr_repository_arn_backend
      },

    ]
  })
  tags = local.backend_ec2_policy_tags
}

resource "aws_iam_role_policy_attachment" "attach_policy_backend" {
  role       = aws_iam_role.ec2_role_ecommerce_backend.name
  policy_arn = aws_iam_policy.ec2_policy_access_ecr_s3.arn
}

resource "aws_iam_instance_profile" "ec2_profile_backend" {
  name = "ec2-ecr-s3-profile-backend"
  role = aws_iam_role.ec2_role_ecommerce_backend.name
}

output "backend_ec2_access_ecr_role" {
  value = aws_iam_instance_profile.ec2_profile_backend.name
}
