terraform {

  backend "s3" {
    bucket  = "aws-mini-project-hosting-tf-state-file"
    key     = "dev/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
    use_lockfile = true
  }
}
