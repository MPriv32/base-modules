data "aws_partition" "current" {}

data "terraform_remote_state" "account" {
  backend = "s3"

  config = {
    bucket = "org-tf-state--732ef4af"
    key    = "prod/account-setup.tfstate"
    region = "us-west-2"
    encrypt = true
    profile = "oddball"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  name             = "prod-app"
  tags             = { Environment = "prod" }
  kms_key_arn      = data.terraform_remote_state.account.outputs.kms_key_arn
  enable_immutable_tags = true
  lifecycle_days   = 90
  scan_on_push     = true
}