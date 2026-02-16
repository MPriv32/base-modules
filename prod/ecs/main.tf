data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "org-tf-state--732ef4af"
    key    = "prod/account-setup.tfstate"
    region = "us-west-2"
    encrypt = true
    profile = "oddball"
  }
}

module "ecs" {
  source = "../../modules/ecs"

  name               = "my-app"
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  public_subnet_ids  = values(data.terraform_remote_state.network.outputs.public_subnet_ids)
  private_subnet_ids = values(data.terraform_remote_state.network.outputs.private_subnet_ids)
  endpoint_security_group_id = data.terraform_remote_state.network.outputs.endpoint_security_group_id
  container_image    = "${var.account_id}.dkr.ecr.us-west-2.amazonaws.com/prod-app:latest"
  region             = var.aws_region
  tags               = { Environment = "dev" }
}
