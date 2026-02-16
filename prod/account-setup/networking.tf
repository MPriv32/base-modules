# Dynamically fetch available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "networking" {
  source = "../../modules/networking"

  name     = "demo"
  region  = var.aws_region
  vpc_cidr = "10.0.0.0/16"

  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]


  enable_nat       = true
  enable_flow_logs = false

  create_backend_s3       = true
  backend_bucket_name     = "org-tf-state--${random_id.suffix.hex}"
  backend_force_destroy   = false
  backend_object_lock_days = 30
  backend_enable_kms      = false

  create_ecr_endpoints  = true

  tags = {
    Environment = "prod"
    CreatedBy   = "Terraform"
  }
}