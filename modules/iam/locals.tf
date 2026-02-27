locals {
  frontend_ec2_role_tags = merge(
    var.common_tags,
    {
      "Name" : "ec2-ecr-s3-role"
    }
  )

  frontend_ec2_policy_tags = merge(
    var.common_tags,
    {
      "Name" : "ec2-ecr-s3-policy"
    }
  )
}