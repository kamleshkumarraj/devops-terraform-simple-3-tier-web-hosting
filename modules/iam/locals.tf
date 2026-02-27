locals {
  frontend_ec2_role_tags = merge(
    var.common_tags,
    {
      "Name" : "frontend-ec2-ecr-role"
    }
  )

  frontend_ec2_policy_tags = merge(
    var.common_tags,
    {
      "Name" : "frontend-ec2-ecr-policy"
    }
  )

  backend_ec2_role_tags = merge(
    var.common_tags,
    {
      "Name" : "backend-ec2-ecr-s3-role"
    }
  )

  backend_ec2_policy_tags = merge(
    var.common_tags,
    {
      "Name" : "backend-ec2-ecr-s3-policy"
    }
  )
}