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

module "ec2" {
  source            = "../../modules/ec2"
  name              = "scanner"
  ami_id            = "ami-0320940581663281e"
  instance_type     = "t3.micro"
  private_subnet_id = data.terraform_remote_state.network.outputs.private_subnet_ids["us-west-2a"]
  vpc_id            = data.terraform_remote_state.network.outputs.vpc_id
  endpoint_security_group_id = data.terraform_remote_state.network.outputs.endpoint_security_group_id
  tags              = { Environment = "dev" }
}